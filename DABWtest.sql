create database SMOOTHIES;

create table smoothies.public.fruit_options
( FRUIT_ID number, 
FRUIT_NAME text(25)
);

select * from smoothies.public.fruit_options;

create file format smoothies.public.two_headerrow_pct_delim
  type = CSV,
  skip_header = 2,
  field_delimiter = '%',
  trim_space = TRUE
;

SELECT $1, $2, $3, $4, $5
FROM @SMOOTHIES.PUBLIC.MY_UPLOADED_FILES/fruits_available_for_smoothies.txt
(FILE_FORMAT => smoothies.public.two_headerrow_pct_delim);

COPY INTO smoothies.public.fruit_options
FROM @smoothies.public.my_uploaded_files
FILES = ('fruits_available_for_smoothies.txt')
FILE_FORMAT = (FORMAT_NAME = smoothies.public.two_headerrow_pct_delim)
ON_ERROR = ABORT_STATEMENT
VALIDATION_MODE = RETURN_ERRORS
PURGE = TRUE;

COPY INTO smoothies.public.fruit_options
FROM (SELECT $2 as fruit_id, $1 as fruit_name
FROM @SMOOTHIES.PUBLIC.MY_UPLOADED_FILES/fruits_available_for_smoothies.txt
(FILE_FORMAT => smoothies.public.two_headerrow_pct_delim)
)
FILE_FORMAT = (FORMAT_NAME = smoothies.public.two_headerrow_pct_delim)
ON_ERROR = ABORT_STATEMENT
PURGE = TRUE;

select * from smoothies.public.fruit_options;

create table smoothies.public.orders
(ingredients varchar(200)
);

select * from smoothies.public.orders;
--insert into smoothies.public.orders(ingredients) values ('Orange Mango  Elderberries Guava Kiwi');

truncate table smoothies.public.orders;

delete from smoothies.public.orders where name_on_order='igor';

alter table smoothies.public.orders add column NAME_ON_ORDER varchar(100);

alter table smoothies.public.orders add column ORDER_FILLED BOOLEAN DEFAULT FALSE;

update smoothies.public.orders set order_filled = true where name_on_order is null;


create sequence order_seq
    start = 1
    increment = 2
    comment = 'Provide a Unique id for each smoothie order';

truncate table smoothies.public.orders;

alter table SMOOTHIES.PUBLIC.ORDERS 
add column order_uid integer --adds the column
default smoothies.public.order_seq.nextval  --sets the value of the column to sequence
constraint order_uid unique enforced; --makes sure there is always a unique value in the column


create or replace table smoothies.public.orders (
       order_uid integer default smoothies.public.order_seq.nextval,
       order_filled boolean default false,
       name_on_order varchar(100),
       ingredients varchar(200),
       constraint order_uid unique (order_uid),
       order_ts timestamp_ltz default current_timestamp()
);

select * from SMOOTHIES.PUBLIC.ORDERS ;


set mystery_bag='What is in here?';

select $mystery_bag;

set mystery_bag='This bag is empty!';

select $mystery_bag;

create function sum_mystery_bag_vars (var1 number,var2 number,var3 number)
    returns number as 'select var1+var2+var3';

select sum_mystery_bag_vars (12,23,25);

set a=2;
set b=5;
set c=4;
select sum_mystery_bag_vars ($a,$b,$c);

set this = -10.5;
set that = 2;
set the_other = 1000 ;
select sum_mystery_bag_vars ($this,$that,$the_other);

create function NEUTRALIZE_WHINING (var1 text)
    returns text as 'select initcap(var1)';

select NEUTRALIZE_WHINING('aRe yOU rEADY');

alter table smoothies.public.fruit_options add column SEARCH_ON varchar(100);

select * from SMOOTHIES.PUBLIC.fruit_options ;

update SMOOTHIES.PUBLIC.fruit_options set search_on='Apple' where FRUIT_NAME = 'Apples';
update SMOOTHIES.PUBLIC.fruit_options set search_on='Blueberry' where FRUIT_NAME = 'Blueberries';
update SMOOTHIES.PUBLIC.fruit_options set search_on='Jackfruit' where FRUIT_NAME = 'Jackfruit';
update SMOOTHIES.PUBLIC.fruit_options set search_on='Raspberry' where FRUIT_NAME = 'Raspberries';
update SMOOTHIES.PUBLIC.fruit_options set search_on='Strawberry' where FRUIT_NAME = 'Strawberries';
update SMOOTHIES.PUBLIC.fruit_options set search_on='Ximenia (Hog Plum)' where FRUIT_NAME = 'Ximenia';
update SMOOTHIES.PUBLIC.fruit_options set search_on=FRUIT_NAME where search_on is null;
update SMOOTHIES.PUBLIC.fruit_options set search_on='Dragonfruit' where FRUIT_NAME = 'Dragon Fruit';
