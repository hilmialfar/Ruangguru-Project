-- Rata-rata durasi product terjual berdasarkan kategori
select product_category, avg(age(sold_at,created_at)) as lama_waktu_jual 
from inventory_items
group by product_category
order by lama_waktu_jual asc
-------------------------------------------------------

-- Jumlah stok product yang belum terjual berdasarkan kategori
select product_category, count(product_name) as quantity
from (select product_category, product_name, age(sold_at,created_at)
	  from inventory_items WHERE age(sold_at,created_at) IS NULL) A
group by A.product_category
order by quantity desc limit 5
-------------------------------------------------------

-- Jumlah stok product yang terjual berdasarkan kategori
select product_category, count(product_name) as quantity
from (select product_category, product_name, age(sold_at,created_at)
	  from inventory_items WHERE age(sold_at,created_at) IS NOT NULL) A
group by A.product_category
order by quantity desc
-------------------------------------------------------

-- Total stok product berdasarkan kategori
select product_category, count(product_name) as quantity 
from inventory_items
group by product_category
order by quantity desc

-------------------------------------------------------
-- rata-rata harga produk saat produksi berdasarkan kategori
select product_category, ROUND(avg(cost)) as avg_cost
from inventory_items
group by product_category
order by avg_cost desc

--------------------------------------------------------
-- Jumlah produk setiap brand
select brand, count(distinct name) from products
group by brand
order by count(distinct name) desc

--------------------------------------------------------
select distinct(product_name), product_brand from inventory_items
where product_brand is null

select name, brand from products
where brand IS NULL
order by name asc

--------------------------------------------------
select extract(year from created_at), 
extract(quarter from created_at), 
count(distinct id) as qty_product_out
from (select id, created_at, sold_at
	  from inventory_items WHERE sold_at IS NOT NULL) A
group by extract(year from created_at), extract(quarter from created_at)
order by extract(year from created_at)
-------------------------------------------------------------------------
select count(distinct id) from inventory_items

-------------------------------------------------------------------------
select product_distribution_center_id,
	case
		when sold_at is not null then 'Out of Distribution Center'
		else 'Stored in Distribution Center'
		end as "Product_Status",
	count(id) as "total_product"
from
	inventory_items
group by product_distribution_center_id, "Product_Status"
order by product_distribution_center_id
-------------------------------------------------------------------------
select
	case
		when age(sold_at,created_at) is NULL then 'Ga laku'
		when age(sold_at,created_at) > '1 month' then 'Lama'
		when age(sold_at,created_at) > '14 days' then 'Lumayan'
		else 'Bentar'
		end as "Distribution_Status",
	count(id) as "total_product"
from
	inventory_items
group by "Distribution_Status"
order by "total_product" desc
----------------------------------------------------------------------
select age(sold_at,created_at) from inventory_items
---------------------------------------------------------------------
select count(id) from inventory_items
where age(sold_at,created_at) < '1 days'
----------------------------------------------------------------------
select *
from inventory_items as A
left join events as B
 on A.id = B.id;
---------------------------------------------------------------------

select A.*, 
	age(A.sold_at, A.created_at) as time_dif, 
	(A.product_retail_price-A.cost) as profit,
	B.*
from inventory_items as A
	left join distribution_centers as B
	on A.product_distribution_center_id = B.id
order by A.created_at asc

----------------------------------------------------------------------
--------- Create Tabel ---------------
DROP TABLE if EXISTS distribution_centers;
DROP TABLE if EXISTS inventory_items;
DROP TABLE if EXISTS events;
DROP TABLE if EXISTS order_items;

CREATE TABLE distribution_centers
(
	id INT NOT NULL,
	name VARCHAR(100),
	latitude NUMERIC,
	longitude NUMERIC,
	PRIMARY KEY(id)
);

CREATE TABLE inventory_items
(
	id INT NOT NULL,
	product_id INT,
	created_at TIMESTAMP WITHOUT TIME ZONE,
	sold_at TIMESTAMP WITHOUT TIME ZONE,
	cost NUMERIC,
	product_category VARCHAR(100),
	product_name VARCHAR(1000),
	product_brand VARCHAR(100),
	product_retail_price NUMERIC,
	product_department VARCHAR(100),
	product_sku VARCHAR(1000),
	product_distribution_center_id INT,
	PRIMARY KEY(id),
	CONSTRAINT distribution_centers_pkey
		FOREIGN KEY(product_distribution_center_id)
			REFERENCES distribution_centers(id)
);

CREATE TABLE events
(
	id INT NOT NULL,
	user_id INT,
	sequence_number INT,
	session_id VARCHAR(1000),
	created_at TIMESTAMP WITHOUT TIME ZONE,
	ip_address VARCHAR(100),
	city VARCHAR(100),
	state VARCHAR(100),
	postal_code VARCHAR(100),
	browser VARCHAR(100),
	traffic_source VARCHAR(100),
	uri VARCHAR(1000),
	event_type VARCHAR(100),
	PRIMARY KEY(id)
);

CREATE TABLE order_items
(
	id INT NOT NULL,
	order_id INT,
	user_id INT,
	product_id INT,
	inventory_item_id INT,
	status VARCHAR(1000),
	created_at TIMESTAMP WITHOUT TIME ZONE,
	shipped_at TIMESTAMP WITHOUT TIME ZONE,
	delivered_at TIMESTAMP WITHOUT TIME ZONE,
	returned_at TIMESTAMP WITHOUT TIME ZONE,
	sale_price NUMERIC,
	PRIMARY KEY(id)
);


--------- Import CSV Using PgAdmin ---------------
--------- Read All Table -----------------------------
select * from distribution_centers		
select * from inventory_items
select * from events

--------- Number of Row All Table -----------------------------
select count(id) from distribution_centers
select count(id) from inventory_items		
select count(id) from events

--------- Convert timestamp to date ---------------------------
ALTER TABLE public.inventory_items
    ALTER COLUMN created_at TYPE date,
	ALTER COLUMN sold_at TYPE date;

-------- inventory_items Table Left Join with distribution_centers Table ---------
select A.*,
	B.name as distribution_centers_name, B.latitude, B.longitude
from inventory_items as A
	left join distribution_centers as B
	on A.product_distribution_center_id = B.id
order by A.created_at asc