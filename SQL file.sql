CREATE DATABASE music;

USE music;

SELECT * FROM customer;
SELECT * FROM genre;
SELECT * FROM playlist;
SELECT * FROM media_type;
SELECT * FROM album2;
SELECT * FROM artist;
SELECT * FROM employee;
SELECT * FROM invoice;
SELECT * FROM track;
SELECT * FROM invoice_line;



SELECT first_name, last_name, title
FROM employee
ORDER BY levels DESC
LIMIT 1;

SELECT billing_country AS Country, COUNT(invoice_id) AS Invoices
FROM invoice
GROUP BY billing_country
ORDER BY count(invoice_id) DESC;

SELECT ROUND(total,2) AS Total_Invoice, billing_country AS Country
FROM invoice
ORDER BY total DESC
LIMIT 3;

SELECT billing_city as City, ROUND(SUM(total),2) as Invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY count(total) DESC
LIMIT 1;






SELECT 
  customer.first_name AS first_name, 
  customer.last_name AS last_name, 
  ROUND(SUM(invoice.total),2) AS Amount_spent
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1;


SELECT DISTINCT email, first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id= invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN (
    SELECT track_id FROM track
    JOIN genre ON track.genre_id = genre.genre_id
    WHERE genre.name LIKE 'ROCK'
)
ORDER BY email;


SELECT artist.name AS Artist_name, COUNT(artist.artist_id) AS Total_tracks
FROM track
JOIN album2 ON track.album_id = album2.album_id
JOIN artist ON album2.artist_id = artist.artist_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'ROCK'
GROUP BY artist.artist_id, artist.name
ORDER BY Total_tracks DESC
LIMIT 10;


SELECT name AS Track_name, milliseconds
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds) 
	FROM track
)
ORDER BY milliseconds DESC;





WITH best_selling_artist AS (
   SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS Total_sales
   FROM invoice_line
   JOIN track ON invoice_line.track_id = track.track_id
   JOIN album2 ON track.album_id = album2.album_id
   JOIN artist ON album2.artist_id = artist.artist_id
   GROUP BY 1,2
   ORDER BY 3 DESC
   LIMIT 1
)
SELECT 
    customer.customer_id, 
    customer.first_name, 
    customer.last_name, 
    best_selling_artist.artist_name, 
    ROUND(SUM(invoice_line.quantity*invoice_line.unit_price),2) AS Total_spent
FROM invoice
JOIN customer ON invoice.customer_id= customer.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN album2 ON track.album_id = album2.album_id
JOIN best_selling_artist ON best_selling_artist.artist_id = album2.artist_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name, best_selling_artist.artist_name
ORDER BY Total_spent DESC;



WITH customer_with_country AS (
    SELECT customer.country, customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) AS amount_spent,
    ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY SUM(invoice.total) DESC) AS Row_no
    FROM customer
    JOIN invoice ON customer.customer_id = invoice.customer_id
	GROUP BY 1, 2, 3, 4
    ORDER BY 1 ASC, amount_spent DESC
)
SELECT *
FROM customer_with_country
WHERE Row_no <= 1;

 
