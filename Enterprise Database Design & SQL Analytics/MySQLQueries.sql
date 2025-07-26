USE movie_theater_chain;

/* Sum of sales per location */
SELECT location_id AS locations,
	COUNT(sale_id) AS total_sales, 
	SUM(quantity * price) AS total_sale_amt
FROM sale_details 
	JOIN item
		ON sale_details.item_id = item.item_id
	JOIN theater
		ON sale_details.theater_id = theater.theater_id
GROUP BY location_id;

/* Sum of movie tickets per location */
SELECT location_id AS locations,
	SUM(quantity) AS total_movie_tickets
FROM theater
	JOIN sale_details
		ON theater.theater_id = sale_details.theater_id
WHERE item_id IN ('3000', '3001', '3002')
GROUP BY location_id;

/* Food and soda sales per location */
SELECT location_id AS locations,
	SUM(price * quantity) AS total_concession_stand_sale
FROM item i
	JOIN sale_details sd
		ON i.item_id = sd.item_id
	JOIN sales s
		ON sd.sale_id = s.sale_id
WHERE NOT i.item_id BETWEEN 3000 AND 3004
GROUP BY location_id;

/* Total sales each employee made */
SELECT s.employee_id,
	s.location_id AS location,
	COUNT(*) AS total_sales_made,
	CONCAT(e.first_name, ' ', e.last_name) AS employee_name
FROM employee e
	JOIN sales s
		ON e.employee_id = s.employee_id
GROUP BY s.employee_id
ORDER BY s.employee_id;

-- Percent of customers who ordered concessions
SELECT (
	SELECT COUNT(DISTINCT sale_id) FROM sale_details WHERE NOT item_id BETWEEN 3000 AND 3004
    )
    / COUNT(DISTINCT sale_id) AS concessions_per_customer
FROM sale_details;

-- Average number of theaters per location
SELECT FLOOR(COUNT(*)/ COUNT(DISTINCT location_id)) AS avg_theaters_per_location
FROM theater;

-- Sales per item
SELECT i.item_id, name, SUM(price * quantity) AS total_sales
FROM item i
	JOIN sale_details sd
		ON i.item_id = sd.item_id
GROUP BY i.item_id
ORDER BY total_sales DESC;

-- Employee distribution
SELECT title, COUNT(employee_id) AS count
FROM position p 
	JOIN employee e
		ON p.position_id = e.position_id
GROUP BY title
ORDER BY count;