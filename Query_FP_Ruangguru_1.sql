--------- Create Tabel ---------------
DROP TABLE if EXISTS distribution_centers;
DROP TABLE if EXISTS inventory_items;
DROP TABLE if EXISTS events;

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