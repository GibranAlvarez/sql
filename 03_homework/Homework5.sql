-- Cross Join
/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */

DROP TABLE IF EXISTS total_by_customer;
	
CREATE TEMP TABLE total_by_customer AS
	SELECT 
	DISTINCT vi.product_id,
	p.product_name,
	v.vendor_name, 
	c.customer_id,
	c.customer_first_name,
	c.customer_last_name,
	vi.original_price,
	(vi.original_price * 5) AS product_by_5
		FROM product AS p 
		CROSS JOIN vendor_inventory AS vi
		USING(product_id)
		CROSS JOIN vendor as v
		USING(vendor_id)
		CROSS JOIN customer as c; --this cross join is only to extract and the names of the customers and to check that each one of them is being sold 5 items

SELECT 
	vendor_name,
	product_name,
	original_price,
	SUM(total_by_customer.product_by_5) AS total_by_product
FROM total_by_customer
GROUP BY product_name
ORDER BY vendor_name;
--The query should give us the total_by_product which is = original_price * 5 (as specified) * 26 (number of customers)

-- INSERT
/*1.  Create a new table "product_units". 
This table will contain only products where the `product_qty_type = 'unit'`. 
It should use all of the columns from the product table, as well as a new column for the `CURRENT_TIMESTAMP`.  
Name the timestamp column `snapshot_timestamp`. */

DROP TABLE IF EXISTS product_units;

CREATE TABLE product_units AS
SELECT *
FROM product
WHERE product_qty_type = 'unit';

ALTER TABLE product_units ADD snapshot_timestamp CURRENT_TIMESTAMP;


/*2. Using `INSERT`, add a new row to the product_units table (with an updated timestamp). 
This can be any product you desire (e.g. add another record for Apple Pie). */

INSERT INTO product_units
VALUES(30,'Guatemalan insanity peppers - Organic','1 lb',1,'unit',NULL);

-- DELETE
/* 1. Delete the older record for the whatever product you added. 

HINT: If you don't specify a WHERE clause, you are going to have a bad time.*/

DELETE FROM product_units
WHERE product_id = 30;

-- UPDATE
/* 1.We want to add the current_quantity to the product_units table. 
First, add a new column, current_quantity to the table using the following syntax.

ALTER TABLE product_units
ADD current_quantity INT;

Then, using UPDATE, change the current_quantity equal to the last quantity value from the vendor_inventory details.

HINT: This one is pretty hard. 
First, determine how to get the "last" quantity per product. 
Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 
Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 
Finally, make sure you have a WHERE statement to update the right row, 
	you'll need to use product_units.product_id to refer to the correct row within the product_units table. 
When you have all of these components, you can run the update statement. */

ALTER TABLE product_units
ADD current_quantity INT;

--FIRST 
DROP TABLE IF EXISTS last_quantity_table;
CREATE TEMP TABLE last_quantity_table AS
SELECT 
	MAX(market_date),
	product_id,
	quantity
FROM vendor_inventory
GROUP BY product_id;

--SECOND
UPDATE product_units
SET current_quantity = coalesce(current_quantity, 0);

--THIRD
UPDATE product_units
SET current_quantity = last_quantity_table.quantity		
FROM last_quantity_table
WHERE product_units.product_id = last_quantity_table.product_id;