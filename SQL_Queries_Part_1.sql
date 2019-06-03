USE Spring_2018_Baseball;

--1.	Using the Salaries table, select playerid, yearid and salary. Remember to format the salary using the format command.
select playerID, yearID, format(salary,'C') as Salary from Salaries; 

--2.	Modify the query in #1 so it also shows a monthly salary (salary divided by 12). Rename the derived column Monthly Salary
select playerID, yearID, format(salary,'C') as Salary, format(salary/12,'C') as 'Monthly Salary'  from Salaries;

--3.	Provide a list of the teamids in the Salaries tables listing each team once.
select distinct teamID from Salaries;

--4.	Select the Teamid, PlayerID and Salary from the Salaries table for all players with salaries over $1 million dollars.
select teamID, playerID, format(salary,'C') as Salary from Salaries where salary>1000000;

--5.	Modify the query for #4 to show the same information for players on the New York Yankees. Hint: Use teamid NYA in your where statement
select teamID, playerID,format(salary,'C') as Salary from Salaries where salary>1000000 and teamID = 'NYA';

--6.	Modify the query in #4 to show the players first and last name in addition to the information already shown. You will need to use the Master and Salaries tables with the correct join.
select s.teamID, s.playerID, format(s.salary, 'C') as Salary, m.nameFirst, m.nameLast
from Salaries s, Master m
where s.playerID=m.playerID
and salary>1000000;

--7.	Modify the query for #4 again, but this time show the FranchName from the teamsFranchise table instead of the teamid. For this query, you must use the Master, Salaries, Teams and TeamsFranchises with the appropriate joins
select f.franchName, s.playerID, s.yearID, format(s.salary,'C') as Salary
from Salaries s, Master m, Teams t, TeamsFranchises f
where s.playerID = m.playerID
and s.yearID = t.yearID
and s.teamID = t.teamID
and f.franchID = t.franchID
and s.lgID = t.lgID
and s.salary>1000000;

--8.	Using the MASTER table. List the first, last and given name for all players that use their initials as their first name (Hint: nameFirst contains at least 1 period(.) Also, concatenate the nameGiven, nameFirst and nameLast into a single column called Full Name putting the nameFirst in parenthesis. For example: James (Jim) Markulic
--NOTE: SQL server uses different symbols for concatenation than the one shown in the text
select nameFirst, nameLast, nameGiven, 
nameGiven+' ('+nameFirst+') '+nameLast as FullName
from dbo.Master
where nameFirst like '%.%';

--9.	Modify the query in #8 by adding the Salaries table and only show players who’s name does not contain a period (.) ad who played in 2000 and had a salary between $400,000 and $500,000. The salary in your results must be properly formatted showing dollars and cents. The results must also be sorted by Salary and then Last Name. You must use a BETWEEN clause in you with statement.
select m.nameFirst, m.nameLast, m.nameGiven, m.nameGiven + ' (' + m.nameFirst + ') ' + m.nameLast as FullName, format(salary,'c') as Salary
	from Master m, Salaries s
	where m.nameFirst Not like '%.%' and 
		s.playerID = m.playerID and
		s.salary between 400000 and 500000 and
		s.yearID = 2000 
	order by s.salary, m.nameLast;

--10.	Using the appropriate Set Operator (slide 32) and the MASTER and APPEARANCES tables, list the player, full name (as shown in #8 & 9) and the teamid of players who were in the appearances table for 2000 but not for 2001. HINT: You need to create 2 separate queries (one to select the data for each year, and use the SET Operator to combine the data to get the correct results. You can also refer to the Relational Algebra Chapter for additional information regarding how the set operators work.
select m.playerID as playerID,
m.nameGiven+' ('+m.nameFirst+') '+m.nameLast as 'Full Name', a.teamID
from Master m, Appearances a
where m.playerID = a.playerID 
and a.yearID = 2000
except
select m.playerID as playerID,
m.nameGiven+' ('+m.nameFirst+') '+m.nameLast as FullName, a.teamID
from Master m, Appearances a
where  m.playerID = a.playerID 
and a.yearID = 2001;

--11.	Modify the query in #10 to use the appropriate Set Operator to show players who are in the appearances table for 2000 and 2001
select m.playerID as playerID,
m.nameGiven+' ('+m.nameFirst+') '+m.nameLast as 'Full Name', a.teamID
from Master m, Appearances a
where m.playerID = a.playerID 
and a.yearID = 2000
intersect
select m.playerID as playerID,
m.nameGiven+' ('+m.nameFirst+') '+m.nameLast as FullName, a.teamID
from Master m, Appearances a
where  m.playerID = a.playerID 
and a.yearID = 2001;

--12.	Write one query to calculate the averages salary in the Salaries table using the formula Average Salary = sum(salaries)/count(playerid) and a second query using the average aggregate function. Explain the difference in the results.
select 
format(sum(salary)/count(playerID), 'C') as Average_Divide,
format(avg(salary), 'C') as Aggregrate_Average
from Salaries;
--Explanation: There are many records with salary as NULL, so there is a difference in result.

--13.	Using the Salaries table and the appropriate aggregate function, calculate the average salary by teamid sorted by teamid
select teamID,
format(sum(salary)/count(playerID), 'C') as Average_Salary
from Salaries group by teamID
order by teamID;

--14.	Using the Salaries table and the appropriate aggregate function, calculate the average salary by lgid and teamid sorted by lgid and teamid
select lgID, teamID,
format(sum(salary)/count(playerID), 'C') as Average_Salary
from Salaries 
group by lgID, teamID
order by lgID,teamID;

--15.	Using the Salaries table and the appropriate aggregate function, calculatethe average salary by lgid and teamid sorted by lgid and teamid for 2015
select lgID, teamID,
format(sum(salary)/count(playerID), 'C') as Average_Salary
from Salaries 
where yearID = 2015
group by lgID, teamID
order by lgID,teamID;
