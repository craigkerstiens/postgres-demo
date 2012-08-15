# Postgres Demos

This repo is intended to provide an example schema, data, and guide for getting started with SQL and some Postgres specific features. 

## Setup

1. First provision a database
2. git clone git@github.com:craigkerstiens/postgres-demo.git
3. Import the data

     PGPASSWORD=<PASS> pg_restore --verbose --clean --no-acl --no-owner -h <HOST> -U <USER> -d <DBNAME> -p <PORT> ./data.dump
    
## Schema

    # \d products
	                                   Table "public.products"
	   Column    |          Type          |                       Modifiers                       
	-------------+------------------------+-------------------------------------------------------
	 id          | integer                | not null default nextval('products_id_seq'::regclass)
	 title       | character varying(255) | 
	 description | text                   | 
	 price       | numeric(10,2)          |
	
	# \d users
	                                     Table "public.users"
	   Column   |            Type             |                     Modifiers                      
	------------+-----------------------------+----------------------------------------------------
	 id         | integer                     | not null default nextval('users_id_seq'::regclass)
	 first_name | character varying(50)       | 
	 last_name  | character varying(50)       | 
	 email      | character varying(255)      | 
	 data       | hstore                      | 
	 created_at | timestamp without time zone | 
	 updated_at | timestamp without time zone |
	
	# \d purchases
	
	                                      Table "public.purchases"
	   Column    |            Type             |                       Modifiers                        
	-------------+-----------------------------+--------------------------------------------------------
	 id          | integer                     | not null default nextval('purchases_id_seq'::regclass)
	 user_id     | integer                     | 
	 items       | numeric(10,2)[]             | 
	 occurred_at | timestamp without time zone |
	
### hStore

### Array

### Example Queries

    # SELECT sum(total(items)) from purchases;
	   sum    
	----------
	 86288.90
	(1 row)
	
	