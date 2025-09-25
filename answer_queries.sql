-- 1st question

with cte as
(
select city_id, date_, net_circulation,
lag(net_circulation,1) over(partition by city_id order by city_id, date_) as prev_month_NC, ((lag(net_circulation,1) over(partition by city_id order by city_id, date_)) - net_circulation) as drop_NC
from fact_print 
order by city_id
)
select city_name, cte.* from cte 
join dim_city using(city_id)
where prev_month_NC is not null order by drop_nc desc limit 3; 

## 2nd question

with cte as(
SELECT ad_category, quarter_,
case
when SUBSTRING_INDEX(quarter_, '-', 1) like "%Q%" then SUBSTRING_INDEX(quarter_, '-', 1)
else SUBSTRING_INDEX(quarter_, '-', -1) end as qtr,
case
when SUBSTRING_INDEX(quarter_, '-', 1) not like "%Q%" then SUBSTRING_INDEX(quarter_, '-', 1)
else SUBSTRING_INDEX(quarter_, '-', -1) end as year,
ad_revenue, currency,
case
when currency = "EUR" then ad_revenue*104
when currency = "USD" then ad_revenue*88
else ad_revenue end as revenue_INR
FROM fact_revenue),

cte2 as(
 select ad_category, year, sum(revenue_INR) as Category_yearly_revenue
 from cte
 group by ad_category, year)
 
 select standard_ad_category, cte2.*, sum(category_yearly_revenue) over(partition by year) as yearly_total_revenue,
 category_yearly_revenue / sum(category_yearly_revenue) over(partition by year)*100 as yearly_revenue_percent
 from cte2
 join dim_ad_category c on c.ad_category_id=cte2.ad_category;
 
 
 ## 3rd question
 
 with cte as
 (
 select city_id, sum(copies_sold), sum(net_circulation), sum(net_circulation)/sum(copies_sold)*100 as print_efficiency,
 rank() over(order by sum(net_circulation)/sum(copies_sold)*100 desc) as efficiency_rank
 from fact_print
 where year(date_) = 2024
 group by city_id
 )
select c.city_name, cte.*
from cte
join dim_city c using(city_id) 
 order by efficiency_rank limit 5; 
 
 ## Question 4
 
 with cte1 as
 (
 select city_id, quarter_,
 internet_penetration as Q1_IP
 from city_readiness
 where quarter_ like "2021%Q1"
 ),
 cte2 as
 (
 select city_id, quarter_,
 internet_penetration as Q4_IP
 from city_readiness
 where quarter_ like "2021%Q4"
 )
 
 select cte1.city_id, city_name, Q1_IP, Q4_IP, Q4_IP-Q1_IP as improvement_IP
 from cte1
 join cte2
 on cte1.city_id=cte2.city_id
 join dim_city c on cte1.city_id = c.city_id
 order by improvement_IP desc; 
 
 ## Q5

 With Print_Rev_data as(
 with Print_data as
 (
select edition_ID, city_id, year(date_) as year, sum(net_circulation) as yearly_NC
from fact_print
group by edition_ID, city_id, year(date_)
),
revenue_data as
(with sub_revenue as 
	(
SELECT edition_ID, quarter_,
case
when SUBSTRING_INDEX(quarter_, '-', 1) like "%Q%" then SUBSTRING_INDEX(quarter_, '-', 1)
else SUBSTRING_INDEX(quarter_, '-', -1) end as qtr,
case
when SUBSTRING_INDEX(quarter_, '-', 1) not like "%Q%" then SUBSTRING_INDEX(quarter_, '-', 1)
else SUBSTRING_INDEX(quarter_, '-', -1) end as year,
ad_revenue, currency,
case
when currency = "EUR" then ad_revenue*104
when currency = "USD" then ad_revenue*88
else ad_revenue end as revenue_INR
FROM fact_revenue
)
select edition_ID, year, sum(revenue_INR) as yearly_Rev
from sub_revenue
group by edition_ID, year 
)

select p.edition_id , p.city_id, p.year, yearly_NC, yearly_Rev,
lag(yearly_NC,1) over(partition by p.edition_id order by p.edition_id, year ) as LY_NC,
lag(yearly_Rev,1) over(partition by p.edition_id order by p.edition_id, year ) as LY_Rev,
if (yearly_NC < lag(yearly_NC,1) over(partition by p.edition_id order by p.edition_id, year ), 0, 1) as NC_dropped,
if (yearly_Rev < lag(yearly_Rev,1) over(partition by p.edition_id order by p.edition_id, year ), 0, 1) as Rev_dropped,
if (yearly_NC < lag(yearly_NC,1) over(partition by p.edition_id order by p.edition_id, year ) and yearly_Rev < lag(yearly_Rev,1) over(partition by p.edition_id order by p.edition_id, year ) , 0, 1) as Both_NC_REV_dropped
from print_data p
join revenue_data r using (edition_id, year)
order by edition_id, year
)

select c.city_name , pr.*, if(pr2.a > 0, "No", "YES") as NC_flag, if(pr2.b > 0, "No", "YES") as Rev_flag, if(pr2.c > 0, "No", "YES") as NC_Rev_flag
from print_rev_data pr
join dim_city c using(city_id)
join (select city_id, sum(NC_dropped) as a,sum(rev_dropped) as b, sum(both_NC_rev_dropped) as c 
from print_rev_data where LY_NC is not null
group by city_id ) as pr2 on pr2.city_id=pr.city_id
where LY_NC is not null
order by city_name, year;

## Question 6

with cte1 as
(
select city_id, round(avg(city_Readiness_score),2) as readiness_score
from 
(
select *, Round((literacy_rate+smartphone_penetration+internet_penetration)/3,2) as City_readiness_score
from city_readiness 
where quarter_ like "%2021%" ) as abc
group by city_id
),
cte2 as
(
select city_id, sum(users_reached) as reached_count, sum(downloads_or_accesses) as download_count, round(avg(avg_bounce_rate),2) as bounce_rate
from fact_pilot 
group by city_id
),
cte3 as
(
 select c.city_name, cte2.*, cte1.readiness_score,
 dense_rank() over(order by cte1.readiness_score desc) as readiness_rank,
 dense_rank() over(order by cte2.reached_count asc) as engagement_rank 
 from cte1
 join cte2 on cte1.city_id = cte2.city_id
 join dim_city c on cte1.city_id = c.city_id
 order by engagement_rank desc
 )
 select *,
 case
 when readiness_rank <= 3 and engagement_rank <= 3 then "Outlier"
 else "Not an Outlier" end as Outlier_Flag
 from cte3
 where engagement_rank < 4 order by readiness_rank limit 1;






 








