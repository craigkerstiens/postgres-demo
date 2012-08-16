# Postgres Demos

This repo is intended to provide an example schema, data, and guide for getting started with SQL and some Postgres specific features. 

## Setup

1. First provision a database ([in the cloud](https://postgres.heroku.com/) or [locally](http://postgresapp.com/))
2. `git clone git@github.com:craigkerstiens/postgres-demo.git`
3. Import the data ([for steps on heroku](https://devcenter.heroku.com/articles/import-data-heroku-postgres#from-postgres))::

     pg_restore --verbose --clean --no-acl --no-owner -h ./data.dump

    
## Schema

Below is the basic layout of the tables. Its a pretty simple schema in that there are users, products and purchases. There's a few specific items to Postgres within the schema which are walked through below. For the tables themselves:

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

[hStore](http://www.postgresql.org/docs/9.1/static/hstore.html) is a key-value store within Postgres. It allows some of the flexibility of schemaless, with the data guarantees that come with a reliable battle tested relational datastore in Postgres. hStore in this example data is used for various user information that is optional and may or may not be captured. This would allow us to quickly experiment with capturing certain demographic information to determine if we should target certain segments, then if needed better integrate this into our schema.

For further reading on hStore:

* [Postgres Docs](http://www.postgresql.org/docs/9.1/static/hstore.html)
* [Using hStore in Django](http://www.craigkerstiens.com/2012/06/14/schemaless-django/)
* [Using hStore in Rails](http://schneems.com/post/19298469372/you-got-nosql-in-my-postgres-using-hstore-in-rails)
* [Heroku support of hStore](https://postgres.heroku.com/blog/past/2012/3/14/introducing_keyvalue_data_storage_in_heroku_postgres/)

### Array

[Arrays](http://www.postgresql.org/docs/9.1/static/arrays.html) have long been a datatype in Postgres since [7.1](http://www.postgresql.org/docs/7.1/static/arrays.html). When it comes to a relational database, arrays are just like, well arrays in anything else. You have an array of a datatype and are able to store data into it and access it by its index. In the example dataset we use arrays as if it were the shopping cart for our purchase. This saves us from having to manage two tables for the purchase in this example app. 

### Example Queries

A large part of the data in this datatypes is highlighted in both the data stored, but also in the flexibility of retrieving the data using this various datatypes. To highlight the first example lets take a look at computing the total of all purchases for all time. 

Since purchases have an array of all the items, the quantity and price we have a [UDF](http://www.postgresql.org/docs/9.1/static/xfunc.html) to compute the total for a given row. This UDF looks like:

    CREATE OR REPLACE FUNCTION total(decimal(10,2)[][]) RETURNS decimal(10,2) AS $$
	DECLARE
	  s decimal(10,2) := 0;
	  x decimal[];
	BEGIN
	  FOREACH x SLICE 1 IN ARRAY $1
	  LOOP
	    s := s + (x[1] * x[2] * x[3]);
	  END LOOP;
	  RETURN s;
	END;
	$$ LANGUAGE plpgsql;
	
To use this function to compute all the totals of purchases we simply sum the result of the totals:

    # SELECT sum(total(items)) from purchases;
	   sum    
	----------
	 86288.90
	(1 row)
	
Additionally, we've stored the sex of users that we have it for. In this case it may be an optional field, or something we've only recently started tracking. We're using an hStore on the users table for this in a column called data. For this case its sex, but essentially we're using it for any generic data we want to associate with a user. Based on this we can compute the total of purchases for Males, Females and unknown with:
	
	
	# SELECT coalesce(users.data->'sex', 'Unknown'), sum(total(items)) from users, purchases where purchases.user_id = users.id group by users.data->'sex';
	 coalesce |   sum    
	----------+----------
	 Unknown  | 26826.60
	 F        | 32824.79
	 M        | 26637.51
	(3 rows)

Or more simply we can get the total purchases for each female with:	
	
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
