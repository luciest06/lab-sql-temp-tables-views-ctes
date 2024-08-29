-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
DROP VIEW rental_info;

CREATE VIEW rental_info AS
SELECT cust.customer_id, CONCAT(cust.first_name,' ',cust.last_name) AS name, cust.email, COUNT(r.rental_id) AS rental_count FROM sakila.customer AS cust
JOIN sakila.rental AS r
ON cust.customer_id = r.customer_id
GROUP BY cust.customer_id;

SELECT * FROM rental_info;

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE customer_total_payment
SELECT ri.customer_id, ri.name, ri.email, ri.rental_count, SUM(p.amount) AS total_paid FROM sakila.payment as p
JOIN rental_info AS ri
ON p.customer_id = ri.customer_id
GROUP BY ri.customer_id;

SELECT * FROM customer_total_payment;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.
WITH cte_customer_summary_report AS (SELECT name, email, rental_count, total_paid FROM customer_total_payment)
SELECT * FROM cte_customer_summary_report
ORDER BY total_paid DESC;

-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
WITH cte_customer_summary_report AS (SELECT name, email, rental_count, total_paid FROM customer_total_payment)
SELECT *,ROUND((total_paid/rental_count),2) AS average_payment_per_rental FROM cte_customer_summary_report
ORDER BY total_paid DESC;
