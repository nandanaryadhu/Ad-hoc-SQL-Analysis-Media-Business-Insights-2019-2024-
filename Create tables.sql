city_id: Unique identifier for each city.
city: City name.
state: State in which the city resides.
tier: Tier classification (e.g., Tier 1, Tier 2, Tier 3).

drop table dim_city ;

create table dim_city ;
(
city_id varchar(45) not null unique,
city_name varchar(45),
state varchar(45),
tier varchar(45) 
primary key (city_id)
) ;

select * from dim_city ;

raw_ad_category: Raw input label from ad revenue data.
standard_ad_category: Cleaned and standardized category.
category_group: Broader sector grouping (e.g., Public Sector, Commercial Brands).
example_brands: Sample advertisers under the category.

drop table dim_ad_category ;

create table dim_ad_category
(
ad_category_id varchar(45) not null unique,
standard_ad_category varchar(45),
category_group varchar(45),
example_brands varchar(45),
primary key(ad_category_id)) ;

select * from dim_ad_category ;

edition_ID
City_ID
Language
State
Month
Copies Sold
copies_returned
Net_Circulation


drop table fact_print ;

create table fact_print
(
edition_ID varchar(45) not null,
City_ID  varchar(45) not null,
Language_ varchar(45),
State varchar(45),
date_ date,
Copies_Sold int,
copies_returned int,
net_circulation int ) ;


select * from fact_print ;

edition_id
ad_category
quarter
ad_revenue
currency
comments

drop table fact_revenue ;

create table fact_revenue
(
edition_ID varchar(45) not null,
ad_category  varchar(45),
quarter_ varchar(45),
ad_revenue int,
currency varchar(45),
comments varchar(45) ) ;


select * from fact_revenue ;

city_id
quarter
literacy_rate
smartphone_penetration
internet_penetration

drop table city_readiness ;

create table city_readiness
(
city_id varchar(45) not null,
quarter_ varchar(45),
literacy_rate decimal(2,2),
smartphone_penetration decimal(2,2),
internet_penetration decimal(2,2) ) ;


select * from city_readiness ;

platform
launch_month
ad_category_id
dev_cost
marketing_cost
users_reached
downloads_or_accesses
avg_bounce_rate
cumulative_feedback_from_customers
city_id

drop table fact_pilot ;

create table fact_pilot
(
platform varchar(45),
launch_month date,
ad_category_id varchar(45),
dev_cost int,
marketing_cost int,
users_reached int,
downloads_or_accesses int,
avg_bounce_rate decimal(2,2),
cumulative_feedback_from_customers varchar(45),
city_id varchar(45)
 ) ;


select * from fact_pilot ;
