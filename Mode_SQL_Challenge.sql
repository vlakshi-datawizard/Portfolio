-- Returns first 100 rows from sqlchallenge1.region
SELECT * FROM sqlchallenge1.region LIMIT 100;

-- Returns first 100 rows from sqlchallenge1.orders
SELECT * FROM sqlchallenge1.orders LIMIT 100;

select count( *) from sqlchallenge1.accounts;
select count(*) from sqlchallenge1.sales_reps;
select count(*)from sqlchallenge1.orders;
select count(*)from sqlchallenge1.region;

-- account name with the longest website url
select website,length(website)from sqlchallenge1.accounts
order by length(website) DESC;

-- how many sales rep have the letter e in the names
select count(*) from sqlchallenge1.sales_reps
where name ilike'%e%' or name ilike 'e%' or name ilike '%e';

-- what is alphabetically first account name that contains &
select * from sqlchallenge1.accounts 
where name ilike '%&%' or name ilike '&%' or name ilike'%&'
order by name;

-- what is the id of the sales rep that sold the last order in may 2015
select *from sqlchallenge1.orders 
where extract(year from occurred_at)=2015 and extract(month from occurred_at)=05
order by occurred_at desc;
select * from sqlchallenge1.accounts
where id=2351;

-- how many sales rep represent the north east region
select count(* )from sqlchallenge1.sales_reps
where region_id=1;

-- which region has the lowest proportion of sales reps to accounts

select sub.region_id, cast( count(distinct sub.sales_rep_id)as float)/cast (count(sub.id) as float) from 
(select a.id,a.sales_rep_id,r.region_id
from sqlchallenge1.accounts a join sqlchallenge1.sales_reps r on a.sales_rep_id=r.id)sub
group by sub.region_id
order by 1;

-- Among sales reps Tia Amto,Delilah Krum and Soraya Fulton which one had accounts with the 
-- greatest quantity ordered in september 2016
select r.name,sub.total_quantity from
(select a.sales_rep_id,sum(o.total ) as total_quantity from sqlchallenge1.orders o
join sqlchallenge1.accounts a on o.account_id=a.id
where extract(year from o.occurred_at)=2016 and  extract(month from o.occurred_at)=09
group by a.sales_rep_id) sub
join sqlchallenge1.sales_reps r on sub.sales_rep_id=r.id
where r.name in('Tia Amato','Delilah Krum','Soraya Fulton');

-- of accounts served by sales reps in north east ,one account has never bought any posters name the company
select account_id ,poster_qty from sqlchallenge1.orders 
where poster_qty=0;

select r.region_id,sub.poster_qty,sub.name,sub.sales_rep_id from
(select o.account_id,o.poster_qty, a.sales_rep_id,a.name from sqlchallenge1.orders o
join sqlchallenge1.accounts a on o.account_id=a.id) sub
join  sqlchallenge1.sales_reps r on sub.sales_rep_id=r.id
where region_id=1;

select sub.account_name,sub.sales_rep_id,o.poster_qty from
(select a.id as account_id,a.name as account_name,a.sales_rep_id,r.name
from sqlchallenge1.accounts a join sqlchallenge1.sales_reps r on a.sales_rep_id=r.id
where r.region_id=1) sub
join sqlchallenge1.orders o on sub.account_id=o.account_id
where o.poster_qty=0;

select account_id,sum(poster_qty) from sqlchallenge1.orders 
group by account_id
order by sum(poster_qty);

select sales_rep_id,id,name from sqlchallenge1.accounts where id =1011 or id=3891;
select id,region_id from sqlchallenge1.sales_reps where id in(321510,321990);

-- how many accounts have never ordered poster
select a.id, sum(o.poster_qty)
FROM sqlchallenge1.accounts a left join sqlchallenge1.orders o
on a.id=o.account_id
group by a.id
order by sum(o.poster_qty);

select count(distinct account_id)from sqlchallenge1.orders;

-- what is the most common first name for  primary pocs


select left(primary_poc,(strpos(primary_poc,' '))-1) as first_name,count(*) from sqlchallenge1.accounts
group by first_name
order by count(*) desc;

-- -For the west region which month had the highest percent of poster orders by count during 2015


select extract(month from occurred_at),(sum(poster_qty)/sum(total))*100 as poster_pct from sqlchallenge1.orders
where extract(year from occurred_at)=2015 AND
account_id in(select id as account_id from sqlchallenge1.accounts where sales_rep_id IN
(select id from sqlchallenge1.sales_reps where region_id=4))
group by extract(month from occurred_at)
order by poster_pct desc;

-- starting from the time of their first order which sales rep had reached 100,000 in total sales
-- the fastest in terms of time. list the id's of the sales rep

select subx.target-suby.first as diff, subx.sales_rep_id from
(select sub1.sales_rep_id,min(first) as target from 
(select *, case when sub.cummulative_sales>=100000 then occurred_at end as first from
(select o.total_amt_usd,a.sales_rep_id,o.occurred_at,
sum(o.total_amt_usd)over(partition by a.sales_rep_id order by o.occurred_at) as cummulative_sales,
row_number()over(partition by a.sales_rep_id order by o.occurred_at) as order_count
from sqlchallenge1.orders o join sqlchallenge1.accounts a on o.account_id=a.id)sub)sub1
group by sub1.sales_rep_id)subx
join
(select a1.sales_rep_id,min(o1.occurred_at) as first from sqlchallenge1.accounts a1
join sqlchallenge1.orders o1 on o1.account_id=a1.id
group by a1.sales_rep_id)suby
on subx.sales_rep_id=suby.sales_rep_id
order by diff;
 
 -- for the sales rep with atleast 2 orders what is the name of the sales rep that went the longest between their first 
 -- and second ORDER

select sub1.sales_rep_id,sub1.occurred_at-lag(sub1.occurred_at)over(partition by sub1.sales_rep_id) as difference from
( select * from 
 (select o.id as order_id,o.account_id ,a.sales_rep_id,o.occurred_at,
 rank() over(partition by a.sales_rep_id order by o.occurred_at) as rank_score
 from sqlchallenge1.orders o
 join sqlchallenge1.accounts a on o.account_id=a.id)sub
 where rank_score in(1,2))sub1
 order by difference desc;
 
 select name,id from sqlchallenge1.sales_reps where id=321510;
 
 -- how many sales rep had atleast 9 orders before surpassing 10k cumulative sales

select sub2.sales_rep_id from
(select sub1.sales_rep_id,sub1.target,count(*) as yn from
(select *,case when sub.cummulative_sales>10000 then 'y'  else 'n'end as target
from(
select o.id as order_id,o.total_amt_usd,a.sales_rep_id ,o.occurred_at,
 sum(total_amt_usd) over(partition  by a.sales_rep_id order by o.occurred_at) as cummulative_sales,
 row_number() over(partition  by a.sales_rep_id order by o.occurred_at) as order_count
 from sqlchallenge1.accounts a join sqlchallenge1.orders o
 on o.account_id=a.id) sub
 where order_count in(1,2,3,4,5,6,7,8,9))sub1
 group by sub1.sales_rep_id,sub1.target)sub2
 where yn=9 and sub2.target='n';
 
 -- what 2 calendar day period had largest dollar amount of purchases
 
 select*,sub.total+lag(sub.total,1)over(order by sub.date1) as lag_sum from
 (select 
 sum(total_amt_usd) as total,date(occurred_at)as date1
 from sqlchallenge1.orders 
 group by date1
 order by date1)sub
 order by lag_sum desc;
 
 