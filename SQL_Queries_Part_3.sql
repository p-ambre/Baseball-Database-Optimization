use Spring_2018_Baseball;

--1.	Using the Salary table, Write a query that ranks the players by salary (highest to lowest) for the year 2000
select teamID, playerID, format(salary,'C') as Y2K_Salary,
rank() over (order by salary desc) as Salary_Rank
from Salaries
where yearID = 2000;

--2.	Write the same query as #2 but eliminate any gaps in the ranking
select teamID, playerID, format(salary,'C') as Y2K_Salary,
dense_rank() over (order by salary desc) as Salary_Rank
from Salaries
where yearID = 2000;

--3.	Write the same query as #3, but find the ranking within each team
select teamID, playerID, format(salary,'C') as Y2K_Salary,
dense_rank() over (partition by teamID order by salary desc) as Salary_Rank
from Salaries
where yearID = 2000;

--4.	Write the same query as #3, but show the ranking by quartile
select teamID, playerID, format(salary,'C') as Y2K_Salary,
ntile(4) over (order by salary desc) as Salary_Rank
from Salaries
where yearID = 2000;

--5.	Using the Batting table , submit the SQL to find the rank of batting averages in 2011 (using the RANK SQL statement). 
--Batting Averages are calculated using the Batting table. Batting Average should be calculated as (R+H)/AB columns. 
select playerID, teamID, lgID, case When AB > 0 then format((H+R)*1.0/AB,'N3') end as Batting_Avg, 
rank() over (Partition by lgID
order by case When AB > 0 then (H+R)*1.0/AB end desc) as Batting_Rank
from Batting 
where yearID = 2011
order by Batting_Rank;

--6.	Using the Salaries table, write a query that compares the averages salary by team and year with the running average of the
--current year and the next 3 years using the over and partition parameters.
select Sal.teamID, Sal.yearID, format(Sal.AvgSal,'C') as Year_Average,
format(avg(Sal.AvgSal) over (partition by teamID order by yearID 
rows between current row and 3 following),'C') as Moving_Salary
from (select teamID, yearID, avg(salary) as AvgSal 
from Salaries 
group by teamID, yearID) Sal


