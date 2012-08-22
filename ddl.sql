CREATE TABLE products (
    id integer NOT NULL,
    title character varying(255),
    description text,
    price numeric(10,2)
);

CREATE SEQUENCE products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE products_id_seq OWNED BY products.id;

CREATE TABLE purchases (
    id integer NOT NULL,
    user_id integer,
    items decimal(10,2) [100][1],
	occurred_at timestamp
);

CREATE SEQUENCE purchases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE purchases_id_seq OWNED BY purchases.id;

CREATE TABLE users (
    id integer NOT NULL,
    first_name character varying(50),
    last_name character varying(50),
    email character varying(255),
	data hstore,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    last_login timestamp without time zone
);

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE users_id_seq OWNED BY users.id;

COPY products (id, title, description, price) FROM stdin;
1	Django Pony	The Django Pony	50.00
2	Pink Pony	A Pink Pony	299.99
3	Ruby Gem	All the Rubies!	49.50
4	Purple Gem	Its purple...	9.99
5	Cooking 101	Cookbook for getting started	9.99
6	Cooking 102	Cookbook for getting started	15.00
7	Cooking 401	Cookbook for getting started	29.99
8	Heroku Dyno	A single process on heroku	36.00
\.

CREATE EXTENSION hstore;

CREATE OR REPLACE FUNCTION total(decimal(10,2)[][]) RETURNS decimal(10,2) AS $$
DECLARE
  s decimal(10,2) := 0;
  x decimal[];
BEGIN
  FOREACH x SLICE 1 IN ARRAY $1
  LOOP
    s := s + (x[2] * x[3]);
  END LOOP;
  RETURN s;
END;
$$ LANGUAGE plpgsql;

