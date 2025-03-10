--Q1. Most Senior Employee based on Job Title?

SELECT * from employee
ORDER BY levels desc
LIMIT 1

-- Q2. Which Country has Most Invoices?

SELECT * FROM invoice

SELECT COUNT(*) as c, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY c DESC
LIMIT 1

-- Q3. What are top 3 values of Total Invoice

SELECT total FROM invoice
ORDER BY total desc
limit 3

-- 	Q4. Which City has the best customers? Client wants to throw a promotional music festival in the city.
-- Client basically wants a query that returns one city that has the highest number of invoice totals.
-- Both city names and sum of all invoice totals.

SELECT SUM(total) as invoice_total, billing_city 
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC


-- Q5. Who is the best customer? The person who has spent the most money will be declared as the best customer.

SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) as total
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC
LIMIT 1


-- Q6. Write Query to return the email, first name, last name and Genre of all Rock music listeners.
-- Also return list ordered alphabetically by email starting with A

SELECT DISTINCT email, first_name, last_name
FROM customer 
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
   SELECT track_id FROM track
   JOIN genre ON track.genre_id = genre.genre_id
   WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

--Q7. Artist who has played most rock music from the dataset. 
--Find artist name and total track count of top 10 rock bands.


SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;


--Q8. Return all the track names that have a song length longer than the average song length.
--Return the Name and Milliseconds for each track and Order By the song length with longest songs listed first.

SELECT name, milliseconds
FROM track
WHERE milliseconds > (
      SELECT AVG(milliseconds) AS avg_track_length
	  FROM track)
	  ORDER BY milliseconds DESC;

-- Q9. How much amount is spent by each customer on artists? Give query to return customer name, artist name and total spent

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)

SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC


--Q10. Now we need to find most popular Genre Country 
--Write a query that returns each country along the top genre.

WITH popular_genre AS
(
SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity)DESC) AS RowNo
FROM invoice_line
JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
JOIN customer ON customer.customer_id = invoice.customer_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
GROUP BY 2,3,4
ORDER BY 2 ASC, 1 DESC

)

SELECT * FROM popular_genre WHERE RowNo <= 1


--- Q3. Customer that has spent the most on  music for each country.
-- also query that returns the country along with top consumer and how much they have spent.
-- for countries the top amount spent, for customer who spent this amount.

WITH RECURSIVE 
	customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;

