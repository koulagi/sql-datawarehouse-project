--Advance Analytics

--1. Change-over-time
--aggregate[Measure] By [DateDimension]

	--Analyze sales over time
	SELECT 
	YEAR(order_date) as order_year,
	MONTH(order_date) as order_month,
	SUM(sales_amount) as total_sales,
	COUNT(DISTINCT customer_key) as total_customers,
	SUM(quantity) as total_quantity
	FROM gold.fact_sales
	WHERE order_date is NOT NULL
	GROUP BY YEAR(order_date),MONTH(order_date)
	ORDER BY YEAR(order_date),MONTH(order_date)

	SELECT 
	DATETRUNC(MONTH, order_date) AS order_date,
	SUM(sales_amount) as total_sales,
	COUNT(DISTINCT customer_key) as total_customers,
	SUM(quantity) as total_quantity
	FROM gold.fact_sales
	WHERE order_date is NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
	ORDER BY DATETRUNC(MONTH, order_date)

--2.Cummulative Analysis
--aggregate[cummulativeMeasure] By [DateDimension]
	
	--Total sales per month and the running total of sales over time
	SELECT
	order_date,
	total_sales,
	--Default window frame between unbounded preceding and current row
	SUM(total_sales) OVER(PARTITION BY order_date ORDER BY order_date) AS running_total_sales,
	AVG(avg_price) OVER(ORDER BY order_date) AS moving_average_price
	FROM(
		SELECT
		DATETRUNC(month,order_date) as order_date,
		SUM(sales_amount) AS total_sales,
		AVG(price) AS avg_price
		FROM gold.fact_sales
		WHERE order_date is NOT NULL
		GROUP BY DATETRUNC(MONTH, order_date)
	)t

--3.Performance Analysis
--Comparing current value to target value
--Current[Measure] - Target[Measure]

	--Analyze the yearly performance of products by comparing each product's sales to both its
	--average sales & the previous year's sales.
	WITH yearly_product_sales AS(
	SELECT
	YEAR(f.order_date) AS order_year,
	p.product_name,
	SUM(f.sales_amount) AS current_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	WHERE f.order_date is NOT NULL
	GROUP BY
	YEAR(f.order_date),
	p.product_name
	)

	SELECT
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
	current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS diff_avg,
	CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Average'
		 WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Average'
		 ELSE 'Average'
	END avg_change,
	LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS py_sales,
	current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_year,
	CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		 WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		 ELSE 'No Change'
	END year_change
	FROM yearly_product_sales
	ORDER BY product_name,order_year
