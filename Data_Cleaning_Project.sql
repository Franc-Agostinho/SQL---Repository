-- DATA CLEANING

# We are going over the following data cleaning steps:

-- 1 Remove Duplicates
-- 2 Standardize the data
-- 3 Treat Null or Blank Values
-- 4 Add/Remove colmuns


SELECT *
FROM dirty_cafe_sales
LIMIT 10;

# We start by creating a staging table as to not alter the raw data

CREATE TABLE cafe_staging
LIKE dirty_cafe_sales;

# This creates all the columns in the staging table as they are in the main table
# We just need to insert the data as follows

INSERT cafe_staging
SELECT *
FROM dirty_cafe_sales;

# now the staging table is populated with the raw data ready to be altered

SELECT *
FROM cafe_staging;

# To avoid problems going further we are going to rename the columns in our staging table

ALTER TABLE cafe_staging
RENAME COLUMN `Transaction ID` to transaction_id,
RENAME COLUMN Item to item,
RENAME COLUMN Quantity to quantity,
RENAME COLUMN `Total Spent` to total_spent,
RENAME COLUMN `Payment Method` to payment_method,
RENAME COLUMN `Transaction Date` to transaction_date;

# A quick check

SELECT *
FROM cafe_staging;



-- 1 Remove Duplicates

# Removing duplicates in this table is easy.
# This is due to the presence of the unique Transaction ID column
# which allows us to identify each row

SELECT transaction_id AS id, COUNT(transaction_id) as num
FROM cafe_staging
GROUP BY transaction_id
ORDER BY num DESC;

# Since the num column is in descending order and the first item has num = 1
# this means there are NO duplicate items. 


-- 2 Standardize Data

# A quick overview of the table shows that
# there are blank, Error and unkown values 
# in several columns
# By the data on the table we can only replace these (hopefuly)
# in the items quantity and total_spent 
# Thus, we replace these strings by blank values in other columns


#################### DATE

SELECT *
FROM cafe_staging
WHERE transaction_date = 'ERROR' 
 OR transaction_date = 'UNKNOWN';

# with the current data, it is highly unlikely, that we can fill the values of transaction date
# We set it all to blank so we can update the table to date type

UPDATE cafe_staging
SET transaction_date = ''
WHERE transaction_date = 'ERROR' 
	OR transaction_date = 'UNKNOWN'
;

# with the blank values we can convert to date

UPDATE cafe_staging
SET transaction_date = CONVERT(transaction_date, DATE)
WHERE transaction_date != ''
;

# Actually, the data was already in date format so this altered none of the rows

SELECT *
FROM cafe_staging;

#################### LOCATION

UPDATE cafe_staging
SET location = ''
WHERE location = 'ERROR'
 OR location = 'UNKNOWN'
;

#################### PAYMENT METHOD

UPDATE cafe_staging
SET payment_method = ''
WHERE payment_method = 'ERROR'
 OR payment_method = 'UNKNOWN'
;

# Check if there are still ERRORs or UNKNOWNs

SELECT payment_method, location, transaction_date
FROM cafe_staging
WHERE payment_method = 'ERROR' OR payment_method = 'UNKNOWN'
	OR location = 'ERROR' OR location = 'UNKNOWN'
    OR transaction_date = 'ERROR' OR transaction_date = 'UNKNOWN'
;

# As expected, it gives us an empty query

-- 3 Treat Null or Blank Values

# Since we forgot to do this before we do it now:

ALTER TABLE cafe_staging
RENAME COLUMN `Price Per Unit` to price_per_unit;

# WE now want to fill the blanks and errors/unknowns in the item table
# We turn these to NULL for easier writting

UPDATE cafe_staging
SET item = NULL
WHERE item = ''
 OR item = 'ERROR'
 OR payment_method = 'UNKNOWN'
;

# We now do a self join to populate the nulls in the item column

SELECT cafe_1.item,
cafe_1.price_per_unit,
cafe_2.item,
cafe_2.price_per_unit
FROM cafe_staging AS cafe_1
JOIN cafe_staging AS cafe_2
	ON cafe_1.price_per_unit=cafe_2.price_per_unit
    AND cafe_1.transaction_id != cafe_2.transaction_id
WHERE	cafe_1.item is NULL
;

SELECT *
FROM cafe_staging
WHERE price_per_unit = 3;




SELECT item, price_per_unit
FROM cafe_staging;










































