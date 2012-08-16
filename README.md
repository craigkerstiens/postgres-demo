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
	
	
	# SELECT coalesce(users.data->'sex', 'Unknown'), sum(total(items)) from users, purchases where purchases.user_id = users.id group by users.data->'sex';
	 coalesce |   sum    
	----------+----------
	 Unknown  | 26826.60
	 F        | 32824.79
	 M        | 26637.51
	(3 rows)
	
	
	# SELECT email, sum(total(items)) from users, purchases where purchases.user_id = users.id and users.data->'sex' ='F' group by 1 order by 2 desc;
	            email             |   sum   
	------------------------------+---------
	 Dalton.Junge@yahoo.com       | 6974.65
	 Kymberly.Junior@aol.com      | 6434.00
	 Wendie.Emmerich@gmail.com    | 4221.17
	 Renda.Bonacci@gmail.com      | 4122.44
	 Victor.Hendon@gmail.com      | 3789.39
	 Missy.Rollinson@gmail.com    | 2054.77
	 Nathanial.Mayon@gmail.com    | 1843.26
	 Hans.Selden@aol.com          | 1499.85
	 Divina.Dossey@yahoo.com      |  993.73
	 Mohammad.Monteith@yahoo.com  |  429.99
	 Evelina.Akey@aol.com         |  229.87
	 Leonard.Gilpatrick@yahoo.com |  101.93
	 Rubie.Sisemore@gmail.com     |   89.82
	 Shari.Rapozo@gmail.com       |   39.92
	(14 rows)