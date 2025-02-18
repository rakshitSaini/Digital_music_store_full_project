

/*Digital music store data known as chinook database is very poplular database with combination of tables 
skills used in this  Joins,  CTEs,Temp Tables, Windows Functions, Aggregate Functions, Creating Views
*/

use chinook;
show tables;




-- 1. Top 5 Customers by Total Purchase

SELECT c.customerid,CONCAT(c.firstname, ' ', c.lastname) AS name,SUM(total) AS total
FROM customer c
JOIN invoice i 
ON c.customerid = i.customerid
GROUP BY 1 , 2
ORDER BY total DESC
LIMIT 5;





-- 2. Total Sales per Artist

SELECT a.artistid,a.name,SUM(il.unitprice * il.quantity) AS total_sales
FROM artist a
JOIN album ab 
ON a.artistid = ab.artistid
JOIN track t 
ON ab.albumid = t.albumid
JOIN invoiceline il 
ON t.trackid = il.trackid
GROUP BY 1 , 2
ORDER BY 3 DESC;





-- 3. Genre Popularity – Tracks Sold per Genre-- 

SELECT g.name,COUNT(g.genreid) AS total
FROM genre g
JOIN track t 
ON g.genreid = t.genreid
JOIN invoiceline il 
ON t.trackid = il.trackid
GROUP BY 1
ORDER BY 2 DESC;





-- 4. Monthly Sales Trend with Running Total 

SELECT  DATE_FORMAT(InvoiceDate, '%Y-%m') AS Month,
    SUM(Total) AS MonthlySales,
    SUM(SUM(Total)) OVER (ORDER BY DATE_FORMAT(InvoiceDate, '%Y-%m')) AS RunningTotalSales
FROM Invoice
GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
ORDER BY Month;





-- 5. Customers Who Spent Above the Average 

SELECT DISTINCT
    CONCAT(c.firstname, ' ', c.lastname) AS name,
    SUM(i.total) AS sum_total
FROM customer c
JOIN invoice i 
ON c.customerid = i.customerid
GROUP BY name
HAVING sum_total > (SELECT AVG(total) FROM invoice)
ORDER BY sum_total;





-- 6. Artist Performance Ranking
create view  ArtistPerformanceRanking as 
select a.artistid,a.name,
		sum(il.unitprice*il.quantity) as total_sales,
		row_number() over(order by sum(il.unitprice*il.quantity) desc) as artist_rank
from artist a
join album ab 
on a.artistid=ab.artistid
join track t  
on ab.albumid=t.albumid
join invoiceline il 
on t.trackid = il.trackid
group by 1,2
order by 3 desc;

select * from ArtistPerformanceRanking;




-- top 5 artists by total sales, including a monthly breakdown of their revenue
create view top5_artist_with_monthlyBreakdown as 
with Artists as (                                          -- to retrieve the top 5 artists with monthly brakdown, created a temp table with cte and it has top 5 artists with most revenue 
select a.artistid,a.name,
		sum(il.unitprice*il.quantity) as total_sales
from artist a
join album ab 
on a.artistid=ab.artistid
join track t  
on ab.albumid=t.albumid
join invoiceline il 
on t.trackid = il.trackid
group by 1,2
limit 5)
select a.artistid,a.name,                                  -- and here by using the month and group by, managed to made it possible and also added a running total for clarification 
month(i.invoicedate) as month,
		sum(il.unitprice*il.quantity) as total_sales
       , sum(sum(il.unitprice*il.quantity)) over (partition by artistid order by month(i.invoicedate) ) as running_total
 from artist a
join album ab 
on a.artistid=ab.artistid
join track t  
on ab.albumid=t.albumid
join invoiceline il 
on t.trackid = il.trackid
join invoice i 
on il.invoiceid=i.invoiceid 
where a.artistid in (select artistid from artists)
group by 1,2,3
order by 1,month;                                            -- created a view to get it back if there is any change in databse 