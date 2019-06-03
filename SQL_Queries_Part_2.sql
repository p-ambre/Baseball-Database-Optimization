USE Spring_2018_Baseball;

--1. Using the Salaries table and the appropriate aggregate functions, calculate the average salary by lgid, teamid and team name sorted by lgid and teamid for 2015
select t.lgID, t.teamID, t.name, format(avg(s.salary),'C') as Average_Salary
from Salaries s, Teams t
where s.lgID = t.lgID and
	  s.teamID = t.teamID and
	  s.yearID = t.yearID and 
	  s.yearID = 2015
group by t.lgID, t.teamID, t.name
order by t.lgID, t.teamID;

--2.Using the Master and Salaries tables along with the appropriate aggregate functions list the playerid, 
--names (in nameGiven (nameFirst) nameLast format) and average salary for all players who had a salary greater than $400,000.
--You must use a HAVING clause to handle the salary condition and your answer must be sorted by playerid.
select  s.playerID, m.nameGiven + ' (' + m.nameFirst + ') ' + m.nameLast as Name, 
		format(avg(s.salary),'C') as Average_Salary
from Salaries s, Master m 
where s.playerID = m.playerID and
	  s.playerID IN (select playerID
					from Salaries
					group by playerID
					having sum(salary) > 400000)
group by s.playerID, m.nameGiven + ' (' + m.nameFirst + ') ' + m.nameLast
order by s.playerID;

--3. Use a nested subquery and an IN statement in the WHERE Clause to find all players who played in 2010 and 2015. 
--Your results should show the playerid, full name, teamid and team name. HINT: The subquery should use the Appearances table to
--find out who played in any given year. Use that query with an IN clause in the WHERE clause for your query. 
--The main query will use the Master, Appearances and Teams tables.
select distinct m.playerID, m.nameGiven + ' (' + m.nameFirst + ') ' + m.nameLast as Player_Name, t.teamID, t.name
from Master m, Teams t, Appearances a
where t.teamID = a.teamID and
	  t.yearID = a.yearID and
	  t.lgID = a.lgID and
	  a.yearID IN (2010,2015) and
	  m.playerID = a.playerID and
	  m.playerID IN ((select playerID from Appearances where yearID=2010) intersect 
					(select playerID from Appearances where yearID=2015))

--4. Using the Salaries table, a nested subquery similar to that in #3 and a SOME clause to find the list of players 
--on the NY Yankees and their salary that have a salary higher than at least one other player on the team in 2014
select playerID, teamID, yearID, format(salary,'C') as Salary
from Salaries
where teamID = 'NYA' and
	yearID = 2014 and
	salary > SOME (select salary 
					from Salaries 
					where yearID = 2014 and 
						teamID = 'NYA')

--5. Using the Salaries table, select the team name, minimum, average and maximum salary for all teams in the AL league in 2015
select t.lgID, t.name, format(min(s.salary),'C') as MIN_Salary, format(avg(s.salary),'C') as AVG_Salary,
						format(max(s.salary),'C') as MAX_Salary
from Teams t, Salaries s
where s.teamID = t.teamID and
      s.yearID = t.yearID and 
	  s.lgID = t.lgID and
	  s.lgID = 'AL' and
	  s.yearID = 2015
group by t.lgID, t.name

--6.Using the Salaries table, a HAVING clause, and a subquery similar to that used in the question #4, find the teamids and average
--salary of the teams with and average salary greater than the average salary of the NY Mets in 2010 HINT: Use teamid = NYN to find
--the Mets information.
select t.teamID, format(avg(s.salary),'C') as Average_Salary
from Teams t, Salaries s
where t.yearID = s.yearID and
	  s.yearID = 2010 and
	  t.lgID = s.lgID and
	  t.teamID = s.teamID
group by t.teamID
having avg(s.salary) > (select avg(Salary)
						from Salaries 
						where teamID = 'NYN' and 
							yearID = 2010);

--7.Using the Master, Teams and Appearances tables, list the play name and team name of all players playing on the same team in 2010
--and 2015. You must use a nested query in your answer. HINT: Use a subquery using the Appearances table as part of your from statement
--along with the appropriate comparisons in the WHERE statement to identify the teams and playerids in the 2010 to 2015 timeframe. 
select m.nameLast + ', ' + m.nameFirst as Player_Name, t.name as Team_Name 
from Master m, Teams t, ((select playerID, teamID from Appearances where yearID=2010) intersect 
						(select playerID, teamID from Appearances where yearID=2015)) a
where m.playerID = a.playerID and
	t.teamID = a.teamID

--8.Using an All clause and a subquery using the Salaries table, find the names of all players who played in 2016 and had a salary 
--higher than all the players who played in 2013. You will need to use the Master, Teams and Salaries tables in the main query to 
--get the required information
select m.nameLast + ', ' + m.nameFirst as Player_Name, t.name as Team_Name
from Salaries s, Master m, Teams t
where t.teamID = s.teamID and
    t.lgID = s.lgID and
    t.yearID = s.yearID and 
	s.playerID = m.playerID and
	s.yearID = 2016 and
	s.salary > ALL (select distinct salary 
					from Salaries 
					where yearID = 2013)

--9.Using a WITH clause to calculate the average salary by team for 2012, find the names of all the player, their salaries and the
--difference between their salary and the average salary of their team who played in 2012. Use the subquery created by the WITH clause
--along with the Master, Salaries and Teams tables in the FROM clause of the main query.

with Avg_Sal as (select s.teamID, t.name, avg(salary) as SalAvg
					from Salaries s, Teams t
					where s.teamID = t.teamID and 
					      s.lgID = t.lgID and
					      s.yearID = t.yearID and 
 						  s.yearID = 2012
					group by s.teamID, t.name)
select a.name as Team_Name, m.nameLast + ', ' + m.nameFirst as Player_Name, 
	format(salary,'C') as Salary, format((salary - SalAvg),'C') as difference
from Salaries s, Master m, Avg_Sal a
where a.teamID = s.teamID and
	s.playerID = m.playerID and
	s.yearID = 2012;


--10.Using WITH statements to create 3 subqueries (one each for the Manager Win %, Team Win % and Team Names, find the managers who’s
--win percent (total of W/total of G) for all the years they managed is greater that the win percentage of all the years for that team.
--You will need to use the Managers table along with the 3 temporary tables created using the WITH clause in the main query. Only show
--managers who’s win percent is higher than the team’s and sort your answer by the team name.
with Manager_details 
	as
(select m1.teamID, t.name as Team_Name, m1.playerID, mm.nameLast + ', ' + mm.nameFirst as Manager,
		(select sum(W*1.0)/sum(G)
		from Managers m
		where m1.playerID = m.playerID) as Win_Percent ,
		(select sum(W*1.0)/sum(G)
		from Teams t1
		where t1.teamID = t.teamID) as Team_Win_Percent
from Managers m1, Master mm, Teams t
where	m1.playerID = mm.playerID and
		m1.lgID = t.lgID and
		m1.yearID = t.yearID and
		m1.teamID = t.teamID and
		m1.plyrMgr = 'Y')

select distinct Team_Name, Manager, format(Win_Percent,'P') as Manager_Percent, 
		format(Team_Win_Percent,'P') as Team_Percent, 
		format(Win_Percent - Team_Win_Percent,'P') as Per_Difference
from Manager_details
where Win_Percent > Team_Win_Percent
order by Team_Name

--11.Using a scalar query using the Appearances table and the Master table, find the number of teams each player played for. 
select m.nameLast + ', ' + m.nameFirst as Player_Name, (select COUNT(*) 
														from (select playerID, teamID 
																from Appearances a
																group by playerID, teamID) aa
														where m.playerID = aa.playerID) as '# of Teams' 
														from Master m;

--12.Add a column to the MASTER table named NJITID_Avg_Salary (NJITID is your NJIT ID such as JM234_Avg_Salary) and write a 
--query that will calculate the player’s average salary and update the new column with that information. Your SQL should use 
--an IF and GO statements to check and see if the new column exists before adding it. After updating the information in the new column, 
--write a query that shows the player name and the value in the new column you created. Exclude the players where the salary information is null. 
--You will need to use the Master and Salaries tables for this problem.
if col_length('Master','PRA22_Avg_Salary') is NULL
begin
	alter table Master add PRA22_Avg_Salary money;
end;
update Master 
	set PRA22_Avg_Salary = (select 
								case when avg(salary) is NOT NULL then avg(salary) 
										else 0
								end
							from Salaries s
							where Master.playerID = s.playerID);
select m.nameLast + ', ' + m.nameFirst as Player_Name, format(PRA22_Avg_Salary,'C') as Average_Salary
from Master m;

--13.	The player’s new contract says that each team must contribute to a player’s 401K retirement account. The contract says 10% of the salary must 
--be put in the 401K for players making under $2 million dollars and 5% for players making $2 million and above.  Create a column (with the 
--appropriate IF and GO statement) in the Salaries table named NJITID_401K (NJITID is your NJIT ID such as JM234_401K) and write a query to populate 
--the data from all past years. Use a CASE clause to update the column using the correct percentage. Also write a query to show the playerid, 
--salary and 401K amount for each year. You will need to use only the Salaries table for this problem.
if col_length('Salaries','PRA22_401K') is NULL
begin
	alter table Salaries add PRA22_401K money
end;
update Salaries
	set PRA22_401K = (select case when salary < 2000000 then (salary * 10 / 100)
								when salary >= 2000000 then (salary * 5 / 100)
								end);
select playerID, yearID, format(salary,'C') as Salary, format(PRA22_401K,'C') as Amount_401K
from Salaries s;


--14.Using the Master and Salaries tables, show the playerID, full names as formatted below and birthdates (properly formatted) and salary  for 
--any Yankee(NYA) playing in 1990 whose salary is greater than the salary of any Boston Red Sox (BOS) using the salaries and mater tables sort 
--highest to lowest salary
select s.playerID, m.nameGiven + ' (' + m.nameFirst + ') ' + m.nameLast as 'Full Name', 
		convert(varchar(10),(convert(char(02),m.birthMonth) + '/' + convert(char(02),m.birthDay) + '/' + 
		convert(char(04),m.birthYear)),101) as 'Birth Day', format(salary,'C') as 'NYA Salary'
from Master m, Salaries s
where m.playerID = s.playerID and
	s.yearID = 1990 and
	s.salary > ANY (select distinct salary 
					from Salaries 
					where teamID = 'BOS' and 
					yearID = 1990)
order by 'NYA Salary' Desc;

--15.	Using only the Master table for this problem. Players are inducted into the Hall of Fame on July 7th each year. Calculate the exact age 
--(using days, months and years) of the players when they were inducted into the Hall of Fame. You will need to use a CONVERT function to properly 
--combine the 3 date columns to get a derived column you can use in the required calculation. To get the exact age, you will need to use a DATEDIFF 
--function using the month and then convert the months to years to get the exact age. Your results should have the playerID, Full Name, Birth Year, 
--Inducted Year, Full Birth Date (in the proper format), Full Induction Date (in the proper format) and the age in years. Note: subtracting the 2 years 
--will give an incorrect answer.
select m.playerID, m.nameFirst + ' ' + m.nameLast as 'Player Name', m.birthYear, h.yearID, h.category,
		d.calcdate, d.inductdate, datediff(month,d.calcdate,d.inductdate)/12 as Age
from Master m, HallOfFame h, 
			(select m.playerID, convert(char(10),(convert(char(02),birthMonth) + '-' + 
												convert(char(02),birthDay) + '-' + 
												convert(char(04),birthYear)),110) as calcdate,
				  convert(char(10),('07-07-' + convert(char(04),yearID)),110) as inductdate
			 from Master m, HallOfFame h 
			 where m.playerID = h.playerID and h.inducted = 'Y') as d
where d.playerID = h.playerID and
      m.playerID = h.playerID and	
	  h.inducted = 'Y' 
