#we have created all the tables now load data in all tables via table data import wizard
#after loading all the data into tables we will answer all the questions -


# Q.1 - Who is the senior most employee based on job title?

select employee_id, 
concat(first_name," ", last_name) as emp_name,
title
from employee 
where levels = "L7"; #L7 in the top post level


#Q.2 Which countries have the most Invoices?

select count(*) as Total_invoices, 
billing_country as Country
from invoice
group by Country
order by Total_invoices desc
limit 1;


#Q.3 What are top 3 values of total invoice?

select total from invoice
order by total desc
limit 3;

#Q.4 Which city has the best customers?
#We would like to throw a promotional Music Festival in the city we made the most money. 
#Write a query that returns one city that has the highest sum of invoice totals. 
#Return both the city name & sum of all invoice totals.

select round(sum(total), 2) as Total_bill,
billing_city
from invoice
group by billing_city
order by Total_bill desc
limit 1;


#Q.5 Who is the best customer? 
#The customer who has spent the most money will be declared the best customer.
#Write a query that returns the person who has spent the most money

select c.customer_id, 
concat(first_name, " ", last_name) as Customer_name,
sum(i.total) as Total_bill 
from customer as c
join invoice as i 
on c.customer_id = i.customer_id
group by c.customer_id, Customer_name
order by Total_bill desc
limit 1;


#Q. 6 Write query to return the email, first name, last name, & Genre.id of all Rock Music listeners.
# Return your list ordered alphabetically by email starting with A

select distinct c.email, c.first_name, c.last_name
from customer as c
join invoice as i on c.customer_id = i.customer_id
join invoice_line as l on i.invoice_id = l.invoice_id
where track_id in (
select t.track_id from track as t
join genre as g on t.genre_id = g.genre_id
where g.name = "Rock")
order by email;


#Q.7 Let's invite the artists who have written the most rock music in our dataset.
# Write a query that returns the Artist name and total track count of the top 10 rock bands

select distinct a.name, COUNT(a.artist_id) AS number_of_songs from artist as a
join album on a.artist_id = album.artist_id
join track as t on album.album_id = t.album_id
where track_id in (
select track_id from track as t
join genre as g on t.genre_id = g.genre_id 
where g.name = "Rock")
group by a.name;



#Q.8 Return all the track names that have a song length longer than the average song length. 
#Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

select name, sum(milliseconds) as length
from track
where milliseconds > (select avg(milliseconds) from track)
group by name
order by length desc;


#Q.9 Find how much amount spent by each customer on artists? 
#Write a query to return customer name, artist name and total spent

select concat(c.first_name, " ",c.last_name) as customer_name, 
a.name as artist_name, 
sum(i.total) as total_spent
from customer as c
join invoice as i on c.customer_id = i.customer_id
join invoice_line as l on i.invoice_id = l.invoice_id
join track as t on l.track_id = t.track_id
join album on t.album_id = album.album_id
join artist as a on album.artist_id = a.artist_id
group by customer_name, artist_name
order by total_spent desc;


#Q, 10 We want to find out the most popular music Genre for each country.
#We determine the most popular genre as the genre with the highest amount of purchases.
#Write a query that returns each country along with the top Genre.
#For countries where the maximum number of purchases is shared return all Genres

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;



#Q.11 Write a query that determines the customer that has spent the most on music for each country.
# Write a query that returns the country along with the top customer and how much they spent. 
#For countries where the top amount spent is shared, provide all customers who spent this amount

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;