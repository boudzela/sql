-- 1 data preporation

-- create database --
create database finance;
-- upload all info -- 
--  nulls and void values --

 -- change the type of date columns --      
select  issue_date, str_to_date(issue_date, '%d-%m-%Y')
from financial_loan; 

update financial_loan
set 
  issue_date =  str_to_date(issue_date, '%d-%m-%Y'),
  last_credit_pull_date = str_to_date(last_credit_pull_date, '%d-%m-%Y'), 
  last_payment_date = str_to_date(last_payment_date, '%d-%m-%Y'),
  next_payment_date = str_to_date(next_payment_date, '%d-%m-%Y'); 
  
alter table financial_loan 
modify  issue_date date,
modify  last_credit_pull_date date, 
modify  last_payment_date date,
modify  next_payment_date date; 

-- null values -- 
select count(*)
from financial_loan
where id is null or  
address_state is null or 
application_type is null or 
emp_length is null or 
emp_title is null or 
grade is null or 
home_ownership is null or  
issue_date is null or 
last_credit_pull_date is null or 
last_payment_date is null or 
loan_status is null or 
next_payment_date  is null or  
member_id is null or 
purpose is null or 
sub_grade is null or 
term is null or 
verification_status is null or  
annual_income is null or 
dti is null or 
installment is null or  
int_rate is null or 
loan_amount is null or 
total_acc is null or 
total_payment is null;  -- no null values --

-- empty values -- 
SELECT COUNT(*)
FROM financial_loan
WHERE id = '' OR  
address_state = '' OR 
application_type = '' OR 
emp_length = '' OR 
emp_title = '' OR 
grade = '' OR 
home_ownership = '' OR  
issue_date = '' OR 
last_credit_pull_date = '' OR 
last_payment_date = '' OR 
loan_status = '' OR 
next_payment_date = '' OR  
member_id = '' OR 
purpose = '' OR 
sub_grade = '' OR 
term = '' OR 
verification_status = '' OR  
annual_income = '' OR 
dti = '' OR 
installment = '' OR  
int_rate = '' OR 
loan_amount = '' OR 
total_acc = '' OR 
total_payment = ''; -- there are 1600 empty values 
-- look into the values:
use finance; 
SELECT *
FROM financial_loan
WHERE id = '' OR  
address_state = '' OR 
application_type = '' OR 
emp_length = '' OR 
emp_title = '' OR 
grade = '' OR 
home_ownership = '' OR  
issue_date = '' OR 
last_credit_pull_date = '' OR 
last_payment_date = '' OR 
loan_status = '' OR 
next_payment_date = '' OR  
member_id = '' OR 
purpose = '' OR 
sub_grade = '' OR 
term = '' OR 
verification_status = '' OR  
annual_income = '' OR 
dti = '' OR 
installment = '' OR  
int_rate = '' OR 
loan_amount = '' OR 
total_acc = '' OR 
total_payment = ''
order by rand(); -- looks like all empty values are in emp_title column, which is ok, let's check it: 

 select count(*) 
 from financial_loan 
 where emp_title = '';  -- 1433 of of 1600 empty values are in this column  

-- let's find the rest 167 empty values 
select * 
from financial_loan 
where id = '' OR  
address_state = '' OR 
application_type = '' OR 
emp_length = '' OR 
grade = '' OR 
home_ownership = '' OR  
issue_date = '' OR 
last_credit_pull_date = '' OR 
last_payment_date = '' OR 
loan_status = '' OR 
next_payment_date = '' OR  
member_id = '' OR 
purpose = '' OR 
sub_grade = '' OR 
term = '' OR 
verification_status = '' OR  
annual_income = '' OR 
dti = '' OR 
installment = '' OR  
int_rate = '' OR 
loan_amount = '' OR 
total_acc = '' OR 
total_payment = ''; -- dti (debt-to-income ratio) column is empty

-- duplicates -- there is the primary key id 
select id
from financial_loan fs
group by id 
having count(id) > 1;  

-- duplicate without id --
select * from 
(
select *, row_number() over (partition by emp_title, issue_date, purpose, term, total_payment order by emp_title, issue_date, purpose, term, total_payment) rn
from financial_loan) sub
where rn > 1;  -- no duplicates 

-- result: dateset of a good quality 

-- 2. Dashboard 1: summary
 
-- total loan applications ofver the cpecified period --
select count(*) 
from financial_loan; -- 38576

-- MTD total number of applications 
select min(issue_date), max(issue_date)
from Financial_loan; -- the cpecified period is  between 2021-01-01 and	2021-12-12

select count(issue_date)
from financial_loan 
where month(issue_date) = 12; -- 4314 applications 

-- MOM total number of applications, number of applications from the beginning of the year, monhtly change, rate of change compared to the previous month  
with CTE as ( 
select month(issue_date) 'month', 
count(id)  total
from financial_loan
group by month(issue_date)
) 
select  month, 
        total, 
        sum(total) over (order by month rows between unbounded preceding and current row) running_total, 
        case 
			when lag(total) over (order by 'month') is null
		    then 'not given'
		    else total - lag(total) over (order by 'month')  end monthly_change,
        case 
			when lag(total) over (order by 'month') is null
		    then 'not given'
		    else round((total - lag(total) over (order by 'month'))/lag(total) over (order by 'month') * 100)  end mom_growth 
from CTE;      
       
 -- let's create a view for our users to follow the changes 
create view mom_applications as 
with CTE as ( 
select month(issue_date) 'month', 
count(id)  total
from financial_loan
group by month(issue_date)
) 
select  month, 
        total, 
        sum(total) over (order by month rows between unbounded preceding and current row) running_total, 
        case 
			when lag(total) over (order by 'month') is null
		    then 'not given'
		    else total - lag(total) over (order by 'month')  end monthly_change,
        case 
			when lag(total) over (order by 'month') is null
		    then 'not given'
		    else round((total - lag(total) over (order by 'month'))/lag(total) over (order by 'month') * 100)  end mom_growth 
from CTE;   
 
 -- Total funded amount (loan_amount)  is calculated the same way 
create view mom_funded_amount as 
with CTE as ( 
select month(issue_date) 'month', 
sum(loan_amount)  total
from financial_loan
group by month(issue_date)
) 
select  month, 
        total, 
        sum(total) over (order by month rows between unbounded preceding and current row) running_total, 
        case 
			when lag(total) over (order by 'month') is null
		    then 'not given'
		    else total - lag(total) over (order by 'month')  end monthly_change,
        case 
			when lag(total) over (order by 'month') is null
		    then 'not given'
		    else round((total - lag(total) over (order by 'month'))/lag(total) over (order by 'month') * 100)  end mom_growth 
from CTE; 


-- total amount returned over the specified period: 

select sum(total_payment) 
from financial_loan;  

-- total payment is a dynamic variable and I disagree with the author in the video
-- that to culculate the amount of total_payment in the previous month we can list filter it by issue_date -- 

-- but we can monitor the amount of money returned to the bank for the loans issued in each month of the year on the date of last operation in tha database --
select month(issue_date) 'month',
       sum(total_payment) 
from financial_loan
group by month(issue_date)
order by month(issue_date);  

 -- create a view to have access to the data 
 create view amount_returned_by_issue_date as
 select month(issue_date) 'month',
       sum(total_payment) 
from financial_loan
group by month(issue_date)
order by month(issue_date);  
 
  
 -- extra ( not included in the problem statement)  
 -- let's look into every month planned installment payments by debtors - 
with recursive CTE_month as (
select 1 nmonth  
union all 
select nmonth + 1 
from CTE_month 
where nmonth < 12) 
select m.nmonth 'month', 
       round(sum(f.installment)) installment_recieved 
from  CTE_month m
left join financial_loan f on month(f.issue_date) <= m.nmonth and month(f.last_payment_date) >= m.nmonth
group by m.nmonth
order by m.nmonth; 

-- I will create a temporary table to store the result of the query and then create a new query wich will calculate running total and monthly rate change and % of change
-- create tempoprary table 
drop temporary table if exists temp_monthly_installment; 
create temporary table temp_monthly_installment as 
	with recursive CTE_month as (
	select 1 nmonth  
	union all 
	select nmonth + 1 
	from CTE_month 
	where nmonth < 12) 
select m.nmonth 'month', 
       round(sum(f.installment)) installment_received 
from  CTE_month m
left join financial_loan f on month(f.issue_date) <= m.nmonth and month(f.last_payment_date) >= m.nmonth
group by m.nmonth
order by m.nmonth; 

-- create query mom, change, mtd 
select  month, 
        installment_received, 
        sum(installment_received) over (order by month rows between unbounded preceding and current row) running_total, 
        case 
			when lag(installment_received) over (order by 'month') is null
		    then 'not given'
		    else installment_received - lag(installment_received) over (order by 'month')  end monthly_change,
        case 
			when lag(installment_received) over (order by 'month') is null
		    then 'not given'
		    else round((installment_received - lag(installment_received) over (order by 'month'))/lag(installment_received) over (order by 'month') * 100)  end mom_growth 
from temp_monthly_installment;

-- unfortunately, temporary table cant be the source of views, to create one, I need t orewrite the queries above: 
-- create a view to monitor installment flow -- 
create view mom_installment as 
WITH RECURSIVE CTE_month AS (
    SELECT 1 AS nmonth
    UNION ALL
    SELECT nmonth + 1
    FROM CTE_month
    WHERE nmonth < 12
)
SELECT
    month,
    installment_received,
    SUM(installment_received) OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
    CASE
        WHEN LAG(installment_received) OVER (ORDER BY month) IS NULL
        THEN 'not given'
        ELSE installment_received - LAG(installment_received) OVER (ORDER BY month)
    END AS monthly_change,
    CASE
        WHEN LAG(installment_received) OVER (ORDER BY month) IS NULL
        THEN 'not given'
        ELSE ROUND((installment_received - LAG(installment_received) OVER (ORDER BY month)) / LAG(installment_received) OVER (ORDER BY month) * 100)
    END AS mom_growth
FROM (
    SELECT
        m.nmonth AS month,
        ROUND(SUM(f.installment)) AS installment_received
    FROM
        CTE_month m
    LEFT JOIN
        financial_loan f
    ON
        MONTH(f.issue_date) <= m.nmonth
        AND MONTH(f.last_payment_date) >= m.nmonth
    GROUP BY
        m.nmonth
) AS subquery
ORDER BY
    month;


-- average intrest rate --
-- averge over the whple period:
select avg(int_rate) 
from financial_loan; 

-- mom amd mtd: 
with CTE_rate as (
select month(issue_date) 'month', 
(avg(int_rate))*100 total
from financial_loan
group by month(issue_date)
) 
select  month, 
        round(total, 2) monthly_rate, 
        round(avg(total) over (order by month rows between unbounded preceding and current row), 2)  running_total, 
        case 
			when lag(total) over (order by 'month') is null
		    then 'not given'
		    else round(total - lag(total) over (order by 'month'), 2)  end monthly_change
from CTE_rate; 

create view mom_intrest_rate as 
with CTE_rate as (
select month(issue_date) 'month', 
(avg(int_rate))*100 total
from financial_loan
group by month(issue_date)
) 
select  month, 
        round(total, 2) monthly_rate, 
        round(avg(total) over (order by month rows between unbounded preceding and current row), 2)  running_total, 
        case 
			when lag(total) over (order by 'month') is null
		    then 'not given'
		    else round(total - lag(total) over (order by 'month'), 2)  end monthly_change
from CTE_rate; 


-- debth-to-income ratio --
-- average dti over the whole period: 
select avg(dti)
from financial_loan;

-- mom and mtd:
with CTE_dti as (
select month(issue_date) 'month', 
(avg(dti))*100 total
from financial_loan
group by month(issue_date)
) 
select  month, 
        round(total, 2) monthly_rate, 
        round(avg(total) over (order by month rows between unbounded preceding and current row), 2)  running_total, 
        case 
			when lag(total) over (order by 'month') is null
		    then 'not given'
		    else round(total - lag(total) over (order by 'month'), 2)  end monthly_change
from CTE_dti; 

create view mom_dti as 
with CTE_dti as (
select month(issue_date) 'month', 
(avg(dti))*100 total
from financial_loan
group by month(issue_date) 
) 
select  month, 
        round(total, 2) monthly_rate, 
        round(avg(total) over (order by month rows between unbounded preceding and current row), 2)  running_total, 
        case 
			when lag(total) over (order by 'month') is null
		    then 'not given'
		    else round(total - lag(total) over (order by 'month'), 2)  end monthly_change
from CTE_dti; 

-- 3. Good loans / bad loads KPI's 

-- good loan application number, good loan application percentage, good loan funded amount, good loan received amount
with CTE_bad as (
select count(id) total 
from financial_loan) 
select count(id) as application_num, 
       count(id) / max(total) * 100  as appllication_cent, 
       sum(loan_amount) as funded_amount, 
       sum(total_payment) as received_amount 
from financial_loan
join CTE_bad 
where loan_status = 'Fully Paid' or loan_status = 'Current'; 

-- bad loan application number, application percentage, funded amount, received amount
with CTE_bad as (
select count(id) total 
from financial_loan) 
select count(id) as application_num, 
       count(id) / max(total) * 100  as appllication_cent, 
       sum(loan_amount) as funded_amount, 
       sum(total_payment) as received_amount 
from financial_loan
join CTE_bad 
where loan_status = 'Charged Off';

-- basic metrics by load status over the whole period 
select 
    case when loan_status ='Fully Paid' then 'Fully Paid Loans'
         when loan_status ='Current'  then 'Currently at work' 
         else 'Charged Off Loans' end loan_status, 
	count(id)  applications, 
    round(count(id) / (select count(id) from financial_loan) *100, 2) application_percent,     
    sum(loan_amount) founded_amount, 
	round(sum(loan_amount) / (select sum(loan_amount) from financial_loan) *100, 2) founded_amount_percent, 
    sum(total_payment) amount_received, 
    round(sum(total_payment) / (select sum(total_payment) from financial_loan) *100, 2) amount_received_percent,
    round(avg(int_rate)*100, 2) intrest_rate, 
    round((avg(dti))*100, 2) dti
from financial_loan 
group by loan_status;     
    
-- 4. dashboard 2 overview: total loan applications, total funded amount, total amount recieved
-- by issue date 
select 
    month(issue_date), 
	count(id)  applications, 
	sum(loan_amount) founded_amount, 
    sum(total_payment) amount_received
from financial_loan 
group by month(issue_date)
order by month(issue_date); 

-- analysis by state 
select 
    address_state, 
	count(id)  applications, 
    sum(loan_amount) founded_amount, 
    sum(total_payment) amount_received 
from financial_loan 
group by address_state
order by applications desc;     

-- loan term analysis 
select 
    term, 
	count(id)  applications, 
    sum(loan_amount) founded_amount, 
    sum(total_payment) amount_received 
from financial_loan 
group by term
order by applications desc;   

-- employee length analysis 
 select 
    emp_length, 
	count(id)  applications, 
    sum(loan_amount) founded_amount, 
    sum(total_payment) amount_received 
from financial_loan 
group by emp_length
order by applications desc;

-- loan purpose analysis 
  select 
    purpose, 
	count(id)  applications, 
    sum(loan_amount) founded_amount, 
    sum(total_payment) amount_received 
from financial_loan 
group by purpose
order by applications desc;

-- home ownership analysis
  select 
    home_ownership, 
	count(id)  applications, 
    sum(loan_amount) founded_amount, 
    sum(total_payment) amount_received 
from financial_loan 
group by home_ownership
order by applications desc;

 