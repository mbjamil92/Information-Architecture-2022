DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `updateDimensionsProc`()
BEGIN
SET @@SESSION.sql_mode = 'ALLOW_INVALID_DATES';
#Update Date Dimension
SET FOREIGN_KEY_CHECKS=0;
TRUNCATE TABLE  dav6100_db_2_dw.date;
INSERT INTO dav6100_db_2_dw.date(date_string, date_year,date_month, date_day, date_quarter, date_weekday, date_week) 
SELECT  distinct
ord_disp_dt as 'Date String',
YEAR(str_to_date(ord_disp_dt,'%m/%d/%Y')) as Year,
MONTH(str_to_date(ord_disp_dt,'%m/%d/%Y')) as Month,
Day(str_to_date(ord_disp_dt,'%m/%d/%Y')) as Day,
Quarter(str_to_date(ord_disp_dt,'%m/%d/%Y')) as Quarter,
WeekDay(str_to_date(ord_disp_dt,'%m/%d/%Y')) as WeekDay,
Week(str_to_date(ord_disp_dt,'%m/%d/%Y')) as Week
FROM dav6100_db_2.t_ord_order
ORDER BY YEAR,MONTH, DAY;

INSERT INTO dav6100_db_2_dw.date(date_key,date_string) VALUES (-1, 'NO DATE AVAILABLE');

#Update Orders Dimension
TRUNCATE TABLE  dav6100_db_2_dw.orders;
INSERT INTO dav6100_db_2_dw.orders(order_id, order_amount)
SELECT order_id, order_amount
FROM(SELECT
CASE WHEN ord_id = '' THEN 'UNKNOWN ORDER' 
ELSE ord_id  END as 'order_id', 
(CASE WHEN SUM(ord_item_amt) = 1000 THEN 'LESS THAN 1000' 
WHEN SUM(ord_item_amt) =1000  AND SUM(ord_item_amt) =3000  THEN 'BETWEEN 1000 AND 3000' 
WHEN SUM(ord_item_amt) =3000  AND SUM(ord_item_amt) =6000  THEN 'BETWEEN 3000 AND 6000' 
WHEN SUM(ord_item_amt) =6000  AND SUM(ord_item_amt) =10000  THEN 'BETWEEN 6000 AND 10000' 
WHEN SUM(ord_item_amt) =10000  THEN 'GREATER THAN 10000'  END ) AS 'order_amount'
FROM dav6100_db_2.t_ord_item 
GROUP BY ord_id order by order_id DESC) as a
WHERE order_id NOT IN ('UNKNOWN ORDER')
ORDER BY CAST(order_id AS SIGNED INTEGER);

INSERT INTO dav6100_db_2_dw.orders(order_key,order_id, order_amount)
SELECT -1, order_id, order_amount
FROM(SELECT
CASE WHEN ord_id = '' THEN 'UNKNOWN ORDER' 
ELSE ord_id  END as 'order_id', 
(CASE WHEN SUM(ord_item_amt) = 1000 THEN 'LESS THAN 1000' 
WHEN SUM(ord_item_amt) =1000  AND SUM(ord_item_amt) =3000  THEN 'BETWEEN 1000 AND 3000' 
WHEN SUM(ord_item_amt) =3000  AND SUM(ord_item_amt) =6000  THEN 'BETWEEN 3000 AND 6000' 
WHEN SUM(ord_item_amt) =6000  AND SUM(ord_item_amt) =10000  THEN 'BETWEEN 6000 AND 10000' 
WHEN SUM(ord_item_amt) =10000  THEN 'GREATER THAN 10000'  END ) AS 'order_amount'
FROM dav6100_db_2.t_ord_item 
GROUP BY ord_id order by order_id DESC) as a
WHERE order_id IN ('UNKNOWN ORDER');

#alter to type2 dimension
alter table dav6100_db_2_dw.orders add column order_status varchar(200) default null;
alter table dav6100_db_2_dw.orders add column eff_date varchar(200) default null;
alter table dav6100_db_2_dw.orders add column end_date varchar(200) default null;

#updating the orders tables
update dav6100_db_2_dw.orders a 
set order_status = (select status_code from dav6100_db_2.t_ord_order b where a.order_id = b.ord_id),
eff_date = (select ord_disp_dt from dav6100_db_2.t_ord_order b where a.order_id = b.ord_id),
end_date = null;

#Update Product Dimension
TRUNCATE TABLE  dav6100_db_2_dw.product;
INSERT INTO dav6100_db_2_dw.product(product_id, item_id, product_description, product_category) 
SELECT DISTINCT prod_id AS 'product_id',
item_id as 'item_id',
prod_desc as 'product_description',
comm_cd  as 'product_category'
FROM dav6100_db_2.r_prod
ORDER BY CAST(product_id AS SIGNED INTEGER);

INSERT INTO dav6100_db_2_dw.product(product_key,product_id, item_id)
VALUES(-1, 'UNKNOWN PRODUCT', 'UNKNOWN ITEM');

#Update Supplier Dimension
TRUNCATE TABLE dav6100_db_2_dw.supplier;
INSERT INTO dav6100_db_2_dw.supplier(supplier_id, supplier_name, supplier_status, supplier_country)
SELECT DISTINCT sup_id as 'supplier_id',
sup_name_en as 'supplier_name' ,
dav6100_db_2.r_base_stat.status_label_en as 'supplier_status',
dav6100_db_2.r_ctry.country_label_en as 'supplier_country'
FROM dav6100_db_2.t_sup_supplier 
JOIN dav6100_db_2.r_base_stat on dav6100_db_2.t_sup_supplier.status_code = dav6100_db_2.r_base_stat.status_code
AND dav6100_db_2.r_base_stat.tdesc_name = 't_sup_supplier'
JOIN dav6100_db_2.r_ctry on dav6100_db_2.t_sup_supplier.country_code = dav6100_db_2.r_ctry.country_code
ORDER BY CAST(supplier_id AS SIGNED INTEGER);

INSERT INTO dav6100_db_2_dw.supplier(supplier_key, supplier_id)
VALUES(-1, 'UNKNOWN SUPPLIER');

INSERT INTO dav6100_db_2_dw.supplier(supplier_id, supplier_name, supplier_status, supplier_country)
SELECT DISTINCT sup_id, 'UNKNOWN NAME', 'UNKNOWN STATUS', 'UNKNOWN COUNTRY' 
FROM dav6100_db_2.t_ord_item
WHERE sup_id NOT IN (SELECT DISTINCT sup_id FROM dav6100_db_2.t_sup_supplier);

SET FOREIGN_KEY_CHECKS=1;
END //