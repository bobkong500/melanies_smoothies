alter database SAMPLE_COOL_DATA rename to snowflake_sample_data;


--Check the range of values in the Market Segment Column
select distinct c_mktsegment
from snowflake_sample_data.tpch_sf1.customer;

--Find out which Market Segments have the most customers
select c_mktsegment, count(*)
from snowflake_sample_data.tpch_sf1.customer
group by c_mktsegment
order by count(*);

-- Nations Table
select n_nationkey, n_name, n_regionkey
from snowflake_sample_data.tpch_sf1.nation;


-- Regions Table
select r_regionkey, r_name
from snowflake_sample_data.tpch_sf1.region;


-- Join the Tables and Sort
select r_name as region, n_name as nation
from snowflake_sample_data.tpch_sf1.nation
join snowflake_sample_data.tpch_sf1.region
on n_regionkey = r_regionkey
order by r_name, n_name asc;

--Group and Count Rows Per Region
select r_name as region, count(n_name) as num_countries
from snowflake_sample_data.tpch_sf1.nation
join snowflake_sample_data.tpch_sf1.region
on n_regionkey = r_regionkey
group by r_name;

grant usage
on function UTIL_DB.PUBLIC.GRADER(VARCHAR, BOOLEAN, NUMBER, NUMBER, VARCHAR)
to role SYSADMIN;


use role SYSADMIN;
create database INTL_DB;
use schema INTL_DB.PUBLIC;

use role SYSADMIN;
create warehouse INTL_WH 
with 
warehouse_size = 'XSMALL' 
warehouse_type = 'STANDARD' 
auto_suspend = 600 --600 seconds/10 mins
auto_resume = TRUE;
use warehouse INTL_WH;

create or replace table intl_db.public.INT_STDS_ORG_3166 
(iso_country_name varchar(100), 
 country_name_official varchar(200), 
 sovreignty varchar(40), 
 alpha_code_2digit varchar(2), 
 alpha_code_3digit varchar(3), 
 numeric_country_code integer,
 iso_subdivision varchar(15), 
 internet_domain_code varchar(10)
);


create or replace file format util_db.public.PIPE_DBLQUOTE_HEADER_CR 
  type = 'CSV' --use CSV for any flat file
  compression = 'AUTO' 
  field_delimiter = '|' --pipe or vertical bar
  record_delimiter = '\r' --carriage return
  skip_header = 1  --1 header row
  field_optionally_enclosed_by = '\042'  --double quotes
  trim_space = FALSE;

  show stages in account; 

create or replace stage util_db.public.aws_s3_bucket
  url = 's3://uni-cmcw';

  list @util_db.public.aws_s3_bucket;

copy into intl_db.public.INT_STDS_ORG_3166 
from @util_db.public.aws_s3_bucket
files = ('ISO_Countries_UTF8_pipe.csv')
file_format = ( format_name='PIPE_DBLQUOTE_HEADER_CR' );


select count(*) as found, '249' as expected 
from INTL_DB.PUBLIC.INT_STDS_ORG_3166; 

select count(*) as OBJECTS_FOUND
from INTL_DB.INFORMATION_SCHEMA.TABLES 
where table_schema='PUBLIC'
and table_name= 'INT_STDS_ORG_3166';

select  
iso_country_name
,country_name_official,alpha_code_2digit
,r_name as region
from INTL_DB.PUBLIC.INT_STDS_ORG_3166 i
left join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n
on upper(i.iso_country_name)= n.n_name
left join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r
on n_regionkey = r_regionkey;


create view intl_db.public.NATIONS_SAMPLE_PLUS_ISO 
( iso_country_name
  ,country_name_official
  ,alpha_code_2digit
  ,region) AS
  select  
iso_country_name
,country_name_official,alpha_code_2digit
,r_name as region
from INTL_DB.PUBLIC.INT_STDS_ORG_3166 i
left join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION n
on upper(i.iso_country_name)= n.n_name
left join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.REGION r
on n_regionkey = r_regionkey;
;
select * from intl_db.public.NATIONS_SAMPLE_PLUS_ISO;


create table intl_db.public.CURRENCIES 
(
  currency_ID integer, 
  currency_char_code varchar(3), 
  currency_symbol varchar(4), 
  currency_digital_code varchar(3), 
  currency_digital_name varchar(30)
)
  comment = 'Information about currencies including character codes, symbols, digital codes, etc.';

create table intl_db.public.COUNTRY_CODE_TO_CURRENCY_CODE 
  (
    country_char_code varchar(3), 
    country_numeric_code integer, 
    country_name varchar(100), 
    currency_name varchar(100), 
    currency_char_code varchar(3), 
    currency_numeric_code integer
  ) 
  comment = 'Mapping table currencies to countries';


create file format util_db.public.CSV_COMMA_LF_HEADER
  type = 'CSV' 
  field_delimiter = ',' 
  record_delimiter = '\n' -- the n represents a Line Feed character
  skip_header = 1 
;


copy into intl_db.public.CURRENCIES 
from @util_db.public.aws_s3_bucket
files = ('currencies.csv')
file_format = ( format_name='CSV_COMMA_LF_HEADER');

list @util_db.public.aws_s3_bucket;

select count(*) as found, '151' as expected 
from INTL_DB.PUBLIC.CURRENCIES;

copy into intl_db.public.COUNTRY_CODE_TO_CURRENCY_CODE 
from @util_db.public.aws_s3_bucket
files = ('country_code_to_currency_code.csv')
file_format = ( format_name='CSV_COMMA_LF_HEADER');


select count(*) as found, '265' as expected 
from INTL_DB.PUBLIC.COUNTRY_CODE_TO_CURRENCY_CODE;

create view intl_db.public.simple_currency 
(cty_code,cur_code) AS
  select country_char_code as cty_code,currency_char_code as cur_code
  from INTL_DB.PUBLIC.COUNTRY_CODE_TO_CURRENCY_CODE;

select * from intl_db.public.simple_currency 


USE ROLE ORGADMIN;
SELECT SYSTEM$ENABLE_GLOBAL_DATA_SHARING_FOR_ACCOUNT('NJB09707');
SELECT SYSTEM$IS_GLOBAL_DATA_SHARING_ENABLED_FOR_ACCOUNT('VQB78647');

select current_account();


alter view intl_db.public.NATIONS_SAMPLE_PLUS_ISO
set secure; 

alter view intl_db.public.SIMPLE_CURRENCY
set secure; 