/* =========================================================
    TASK 01 :- DATABASE & NORMALIZED SCHEMA
   ========================================================= */

DROP DATABASE IF EXISTS quickkart_db;

CREATE DATABASE IF NOT EXISTS quickkart_db;

USE quickkart_db;



CREATE TABLE stores (
    store_id VARCHAR(30) PRIMARY KEY,
    city VARCHAR(100) NOT NULL,
    zone VARCHAR(100) NOT NULL,
    opening_date DATE NOT NULL,
    parent_hub_id VARCHAR(30)
);
LOAD DATA INFILE "D:\\PROJECTS\\QuickKart_DarkStore\\cleaned_dataset\\stores.csv" INTO TABLE stores
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 lines;




CREATE TABLE products (
    sku_id VARCHAR(30) PRIMARY KEY,
    sku_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    sub_category VARCHAR(100) NOT NULL,
    brand VARCHAR(100) NOT NULL,
    mrp DECIMAL(10,2) NOT NULL CHECK (mrp >= 0),
    shelf_life_days INT NOT NULL CHECK (shelf_life_days >= 0)
);
LOAD DATA INFILE "D:\\PROJECTS\\QuickKart_DarkStore\\cleaned_dataset\\products.csv" INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 lines;




CREATE TABLE riders (
    rider_id VARCHAR(30) PRIMARY KEY,
    store_id VARCHAR(30) NOT NULL,
    join_date DATE NOT NULL,
    shift VARCHAR(50) NOT NULL,
    vehicle_type VARCHAR(50),
    
	FOREIGN KEY (store_id) REFERENCES stores(store_id)
);
LOAD DATA INFILE "D:\\PROJECTS\\QuickKart_DarkStore\\cleaned_dataset\\riders.csv" INTO TABLE riders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 lines;




CREATE TABLE orders (
    order_id VARCHAR(30) PRIMARY KEY,
    customer_id VARCHAR(30) NOT NULL,
    store_id VARCHAR(30) NOT NULL,
    order_ts DATETIME NOT NULL,
    rider_id VARCHAR(30) NOT NULL,
    delivered_ts DATETIME NULL,
    promised_mins INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    payment_mode VARCHAR(50) NULL,
    
	FOREIGN KEY (store_id) REFERENCES stores(store_id),
	FOREIGN KEY (rider_id) REFERENCES riders(rider_id)
) ;
LOAD DATA INFILE "D:\\PROJECTS\\QuickKart_DarkStore\\cleaned_dataset\\orders.csv" INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 lines
(order_id,customer_id,store_id,order_ts,rider_id,@v_delivered_ts,promised_mins,status,payment_mode)
SET delivered_ts = IF(@v_delivered_ts='', NULL, @v_delivered_ts);




CREATE TABLE order_items (
	line_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(30) NOT NULL,
    sku_id VARCHAR(30) NOT NULL,
    qty INT NOT NULL CHECK (qty > 0),
    mrp DECIMAL(10,2) NOT NULL CHECK (mrp >= 0),
    discount_pct DECIMAL(6,2) NOT NULL,
    fulfilled_flag TINYINT NOT NULL CHECK (fulfilled_flag IN (0, 1)),

	FOREIGN KEY (order_id) REFERENCES orders(order_id),
	FOREIGN KEY (sku_id) REFERENCES products(sku_id)
) ;
LOAD DATA INFILE 'D:\\PROJECTS\\QuickKart_DarkStore\\cleaned_dataset\\order_items.csv' 
INTO TABLE order_items 
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(order_id,sku_id,qty,mrp,discount_pct,fulfilled_flag);




CREATE TABLE daily_stock_snapshot (
    snapshot_date DATE NOT NULL,
    store_id VARCHAR(30) NOT NULL,
    sku_id VARCHAR(30) NOT NULL,
    closing_qty INT NOT NULL,
    received_qty INT NOT NULL,

    PRIMARY KEY (snapshot_date, store_id, sku_id),
	FOREIGN KEY (store_id) REFERENCES stores(store_id),
	FOREIGN KEY (sku_id) REFERENCES products(sku_id)
) ;
LOAD DATA INFILE "D:\\PROJECTS\\QuickKart_DarkStore\\cleaned_dataset\\daily_stock_snapshot.csv" INTO TABLE daily_stock_snapshot
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 lines;






/* =========================================================
   TASK 02 :- BASIC DATA PROFILING
   ========================================================= */

SHOW TABLES;

SELECT 'stores' AS table_name, COUNT(*) AS total_rows FROM stores
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'riders', COUNT(*) FROM riders
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'daily_stock_snapshot', COUNT(*) FROM daily_stock_snapshot;

SELECT order_id, COUNT(*) AS occurences FROM orders GROUP BY order_id HAVING occurences > 1;

SELECT DISTINCT city FROM stores;
SELECT DISTINCT zone FROM stores;

SELECT DISTINCT shift FROM riders;
SELECT DISTINCT vehicle_type FROM riders;

SELECT DISTINCT status FROM orders;
SELECT DISTINCT payment_mode FROM orders;

SELECT * FROM order_items WHERE qty = 0;






/* =========================================================
   TASK 03 :- COMPOSITE INDEXS WITH EXPLAIN
   ========================================================= */

/* EXPERIMENT 1: STORE-WISE ORDER ANALYSIS */

/* Before index */
EXPLAIN
SELECT
    store_id,
    COUNT(*) AS total_orders
FROM orders
WHERE store_id = 'STORE010'
  AND order_ts >= '2026-01-01 00:00:00'
  AND order_ts <  '2026-02-01 00:00:00'
GROUP BY store_id;
/* -> Group aggregate: count(0)  (cost=0.287 rows=0.111) -> Filter: ((orders.order_ts >= TIMESTAMP'2026-01-01 00:00:00') and (orders.order_ts < TIMESTAMP'2026-02-01 00:00:00'))  (cost=0.261 rows=0.111) -> Index lookup on orders using store_id (s... */


/* Create composite index */
CREATE INDEX idx_orders_store_date
ON orders(store_id, order_ts);


/* After index */
EXPLAIN 
SELECT
    store_id,
    COUNT(*) AS total_orders
FROM orders
WHERE store_id = 'STORE010'
  AND order_ts >= '2026-01-01 00:00:00'
  AND order_ts <  '2026-02-01 00:00:00'
GROUP BY store_id;
/* -> Group aggregate: count(0)  (cost=1.44 rows=1) -> Filter: ((orders.store_id = 'STORE010') and (orders.order_ts >= TIMESTAMP'2026-01-01 00:00:00') and (orders.order_ts < TIMESTAMP'2026-02-01 00:00:00'))  (cost=1.21 rows=1) -> Covering index ...*/



/* EXPERIMENT 2: RIDER DELIVERY ANALYSIS */

/* Before index */
EXPLAIN
SELECT
    rider_id,
    order_id,
    delivered_ts
FROM orders
WHERE rider_id = 'RIDER001'
  AND delivered_ts IS NOT NULL
ORDER BY delivered_ts;

/* -> Sort: orders.delivered_ts  (cost=0.34 rows=1) -> Filter: (orders.delivered_ts is not null)  (cost=0.34 rows=1) -> Index lookup on orders using rider_id (rider_id = 'RIDER001')  (cost=0.34 rows=1) */
 
 
 /* Create composite index */
CREATE INDEX idx_orders_rider_delivery
ON orders(rider_id, delivered_ts);


/* After index */
EXPLAIN
SELECT
    rider_id,
    order_id,
    delivered_ts
FROM orders
WHERE rider_id = 'RIDER001'
  AND delivered_ts IS NOT NULL
ORDER BY delivered_ts;
/*-> Filter: ((orders.rider_id = 'RIDER001') and (orders.delivered_ts is not null))  (cost=1.21 rows=1) -> Covering index range scan on orders using idx_orders_rider_delivery over (rider_id = 'RIDER001' AND NULL < delivered_ts)  (cost=1.21 rows=1) */
 

 
 /* VERIFY INDEXS */
 SHOW INDEX FROM orders;






/* =========================================================
   TASK 04 :- RANGE PARTITIONING ORDERS BY MONTH
   ========================================================= */

SELECT
	MAX(order_ts) AS last_order_date,
	MIN(order_ts) AS first_order_date
FROM orders;


SELECT 
	DATE_FORMAT(order_ts, "%Y-%m") AS order_month,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY DATE_FORMAT(order_ts, "%Y-%m")
ORDER BY order_month; 


CREATE TABLE orders_partitioned (
    order_id VARCHAR(30) NOT NULL,
    customer_id VARCHAR(30) NOT NULL,
    store_id VARCHAR(30) NOT NULL,
    order_ts DATETIME NOT NULL,
    rider_id VARCHAR(30),
    delivered_ts DATETIME,
    promised_mins INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    payment_mode VARCHAR(50),

    PRIMARY KEY (order_id, order_ts)
)
PARTITION BY RANGE COLUMNS(order_ts)
(
	PARTITION p_before_202504 VALUES LESS THAN ('2025-04-01'),
	PARTITION p_202504 VALUES LESS THAN ('2025-05-01'),
    PARTITION p_202505 VALUES LESS THAN ('2025-06-01'),
    PARTITION p_202506 VALUES LESS THAN ('2025-07-01'),
    PARTITION p_202507 VALUES LESS THAN ('2025-08-01'),
    PARTITION p_202508 VALUES LESS THAN ('2025-09-01'),
    PARTITION p_202509 VALUES LESS THAN ('2025-10-01'),
    PARTITION p_202510 VALUES LESS THAN ('2025-11-01'),
    PARTITION p_202511 VALUES LESS THAN ('2025-12-01'),
    PARTITION p_202512 VALUES LESS THAN ('2026-01-01'),
    PARTITION p_202601 VALUES LESS THAN ('2026-02-01'),
    PARTITION p_202602 VALUES LESS THAN ('2026-03-01'),
    PARTITION p_202603 VALUES LESS THAN ('2026-04-01'),
    PARTITION p_202604 VALUES LESS THAN ('2026-05-01'),
    PARTITION p_202605 VALUES LESS THAN ('2026-06-01'),
    PARTITION p_202606 VALUES LESS THAN ('2026-07-01'),
    PARTITION p_202607 VALUES LESS THAN ('2026-08-01'),
    PARTITION p_202608 VALUES LESS THAN ('2026-09-01'),
    PARTITION p_202609 VALUES LESS THAN ('2026-10-01'),
    PARTITION p_future VALUES LESS THAN (MAXVALUE)
);


INSERT INTO orders_partitioned SELECT * FROM orders;


SELECT 'orders' AS orders, COUNT(*) AS total_row FROM orders
UNION ALL
SELECT 'orders_partitioned' AS orders_partitioned, COUNT(*) AS total_row FROM orders_partitioned;


EXPLAIN 
SELECT * FROM orders_partitioned WHERE order_ts >= '2026-01-01' AND order_ts < '2026-02-01';
/*-> Filter: ((orders_partitioned.order_ts >= TIMESTAMP'2026-01-01 00:00:00') and (orders_partitioned.order_ts < TIMESTAMP'2026-02-01 00:00:00'))  (cost=2278 rows=2486)-> Table scan on orders_partitioned  (cost=2278 rows=22378) */
 
 
EXPLAIN 
SELECT * FROM orders WHERE order_ts >= '2026-01-01' AND order_ts < '2026-02-01';
/* -> Filter: ((orders.order_ts >= TIMESTAMP'2026-01-01 00:00:00') and (orders.order_ts < TIMESTAMP'2026-02-01 00:00:00'))  (cost=40320 rows=44177) -> Table scan on orders  (cost=40320 rows=397672)*/






/* =========================================================
   TASK 05 :- WINDOW FUNCTIONS (RANK, LAG, 7-DAY ROLLING)
   ========================================================= */

/* Worst 5 store-hour combinations */
with StoreHourlyPerformance as (
	select
		*,
        round(100*total_on_time_deliverd_orders/total_deliverd_orders,2) as on_time_delivered_percentage
    from (
		select
			store_id,
			hour(order_ts) as order_hour,
			count(order_id) as total_deliverd_orders,
			sum(case when delivered_ts <= date_add(order_ts, interval promised_mins minute) then 1 else 0 end) as total_on_time_deliverd_orders
		from orders
		group by store_id, hour(order_ts)
		order by store_id, hour(order_ts)) as ans
),
RankedStores as (
	select
		*,
        dense_rank() over(order by on_time_delivered_percentage) as performance_rank
	from StoreHourlyPerformance
)
select * from RankedStores order by performance_rank limit 5;



/* Rider delivery gaps */
with RiderDeliveries as (
	select 	
		rider_id, 
        order_id, 
        store_id, 
        delivered_ts,
        lag(delivered_ts) over(partition by rider_id order by delivered_ts) as previous_delivered_ts
	from orders
    where delivered_ts is not null
)
select 
	*,
    ceil(timestampdiff(second, previous_delivered_ts, delivered_ts)/60) as deliverey_gap_minutes
from RiderDeliveries 
order by rider_id, delivered_ts;



/* rolling 7 days stock out */
with Rolling7Days as (
select 
	*,
    sum(stockout_flag) over(partition by store_id, sku_id order by snapshot_date range between interval 6 day preceding and current row) as stockout_days_last_7_records
from (
	select 
		*, 
		case when closing_qty = 0 then 1 else 0 end as stockout_flag
	from daily_stock_snapshot) as ans
)
select * from Rolling7Days order by stockout_days_last_7_records desc limit 20;






/* =========================================================
   TASK 06 :- DAILY STORE REPORT-STORED PROCEDURE
   ========================================================= */
   
delimiter //
create procedure 
Daily_Store_Report (in s_id varchar(200), in report_date date)
begin
with report as (
	with ans1 as (
		select 
			store_id,
			date(order_ts) as reporting_date,
            time(min(order_ts)) as first_order_ts,
            time(max(order_ts)) as last_order_ts,
			count(distinct customer_id) as total_unique_customer,
			count(order_id) as total_orders,
			count(case when delivered_ts is not null and delivered_ts <= date_add(order_ts, interval promised_mins minute) then 1 else null end) as total_on_time_delivered_orders
		from orders where store_id = s_id and date(order_ts) = report_date
		group by store_id, date(order_ts)
        ),
	ans2 as (
		select 
			store_id,
			date(order_ts) as reporting_date,
			count(distinct sku_id) as total_product_sold,
            sum(qty) as total_quantity_sold,
			round(sum(mrp*qty*(1-discount_pct)),2) as total_revenue 
		from order_items as oi
		join orders as o on oi.order_id = o.order_id
		where store_id = s_id and date(order_ts) = report_date
        group by store_id, date(order_ts)
        )
	select 
		a1.store_id,
        a1.reporting_date,
        first_order_ts,
        last_order_ts,
        total_orders,
        total_revenue,
        total_unique_customer,
        total_product_sold,
        total_quantity_sold,
        total_on_time_delivered_orders,
        round(100*total_on_time_delivered_orders/total_orders,2) as on_time_percentage
	from ans1 as a1 
    left join ans2 as a2 on a1.reporting_date = a2.reporting_date and a1.store_id = a2.store_id
)
select * from report;
end //
delimiter ;

call Daily_Store_Report('DS003', '2026-08-29');






/* =========================================================
   TASK 07 :- BEFORE / AFTER INSERT TRIGGERS
   ========================================================= */

/* before insert trigger */
drop trigger if exists validate_order_before_insert;

delimiter // 
create trigger validate_order_before_insert 
before insert on orders 
for each row 
begin 
    if NEW.order_id is null or trim(NEW.order_id)='' then 
        signal sqlstate '45000' set message_text = 'order_id cannot be null'; 

    elseif NEW.customer_id is null or trim(NEW.customer_id)='' then 
        signal sqlstate '45000' set message_text = 'customer_id cannot be null'; 

	elseif NEW.store_id is null or trim(NEW.store_id)='' then 
        signal sqlstate '45000' set message_text = 'store_id cannot be null';

    elseif NEW.order_ts is null or trim(NEW.order_ts)='' then 
        signal sqlstate '45000' set message_text = 'order_ts cannot be null'; 

	elseif NEW.rider_id is null or trim(NEW.rider_id)='' then 
		signal sqlstate '45000' set message_text = 'rider_id cannot be null';

	elseif NEW.delivered_ts is null or trim(NEW.delivered_ts)='' then 
        signal sqlstate '45000' set message_text = 'delivered_ts cannot be null';

    elseif NEW.delivered_ts < NEW.order_ts then 
        signal sqlstate '45000' set message_text = 'delivered_ts cannot be before order_ts'; 

	elseif NEW.promised_mins <= 0 then 
        signal sqlstate '45000' set message_text = 'promised_mins must be greater than 0';

	elseif NEW.status is null or trim(NEW.status)='' then 
        signal sqlstate '45000' set message_text = 'status cannot be null'; 

	elseif NEW.payment_mode is null or trim(NEW.payment_mode)='' then 
        signal sqlstate '45000' set message_text = 'payment_mode cannot be null'; 

    end if; 
end // 
delimiter ;

/*--------------------validation--------------------
    insert into orders values('','C033785','DS016','2025-04-01 05:06:19','R00536','2025-04-01 05:15:19',15,'Cancelled', 'UPI')	            
    Error Code: 1644. order_id cannot be null

    insert into orders values('QK0000010',NULL,'DS016','2025-04-01 05:06:19','R00536','2025-04-01 05:15:19',15,'Cancelled', 'UPI')	        
    Error Code: 1644. customer_id cannot be null

    insert into orders values('QK0000010','C033785','DS016','2025-04-01 05:06:19','R00536','2025-04-01 05:00:19',15,'Cancelled', 'UPI')	    
    Error Code: 1644. delivered_ts cannot be before order_ts

    insert into orders values('QK0000010','C033785','DS016','2025-04-01 05:06:19','R00536','2025-04-01 05:00:19',-1,'Cancelled', 'UPI')	    
    Error Code: 1644. delivered_ts cannot be before order_ts

    insert into orders values('QK0000010','C033785','DS016','2025-04-01 05:06:19','R00536','2025-04-01 05:00:19',-10,'Cancelled', 'UPI')	
    Error Code: 1644. delivered_ts cannot be before order_ts

    insert into orders values('QK0000010','C033785','DS016','2025-04-01 05:06:19','R00536','2025-04-01 05:20:19',-10,'Cancelled', 'UPI')	
    Error Code: 1644. promised_mins must be greater than 0

    insert into orders values('QK0000010','C033785','DS016','2025-04-01 05:06:19','R00536','2025-04-01 05:20:19',15,'Cancelled', '')	    
    Error Code: 1644. payment_mode cannot be null
--------------------------------------------------*/



/* +----------------------audit trigger----------------------+ */
create table if not exists order_audit(
	audit_id bigint auto_increment primary key,
    order_id varchar(30),
    customer_id varchar(30),
    store_id varchar(30),
    order_ts datetime,
    action_type varchar(30),
    audit_timestamp timestamp default current_timestamp
);

drop trigger if exists audit_order_after_insert;

delimiter //
create trigger audit_order_after_insert 
after insert on orders 
for each row
begin
	insert into order_audit(order_id, customer_id, store_id, order_ts, action_type)
    values(NEW.order_id, NEW.customer_id, NEW.store_id, NEW.order_ts,'INSERT');
end // 
delimiter ;






/* =========================================================
   TASK 08 :- STOCK TRANSFER TRANSACTION - PROCEDURE
   ========================================================= */

drop procedure if exists PerformStockTransfer;

delimiter //
create procedure PerformStockTransfer(
		in transfer_date date,
		in source_store varchar(30), 
		in destination_store varchar(30), 
		in transfer_sku varchar(30),
		in quantity int
	)
begin
    declare v_source_updated int default 0;
    declare v_destination_updated int default 0;

    start transaction;

    savepoint before_stock_transfer;

    update daily_stock_snapshot
    set closing_qty = closing_qty - quantity 
    where snapshot_date = transfer_date and 
        store_id = source_store and 
        sku_id = transfer_sku
        and closing_qty >= quantity;
        
    set v_source_updated = row_count();

    update daily_stock_snapshot
    set closing_qty = closing_qty + quantity 
    where snapshot_date = transfer_date and 
        store_id = destination_store and 
        sku_id = transfer_sku;
        
    set v_destination_updated = row_count();
	
    if v_source_updated=1 and v_destination_updated=1 then 
        commit;
    else
        rollback to savepoint before_stock_transfer;
        commit;
    end if;
    
    select 
	    * 
    from daily_stock_snapshot 
    where 
        snapshot_date = transfer_date 
        and store_id in(source_store, destination_store) 
        and sku_id = transfer_sku;

end //
delimiter ;

call PerformStockTransfer('2026-09-30', 'DS003', 'DS001', 'SKU00047', 7);


select 
	* 
from daily_stock_snapshot 
where 
snapshot_date = '2026-09-30'        
and store_id in('DS003', 'DS001') 
and sku_id = 'SKU00047';


