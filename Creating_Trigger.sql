use Spring_2018_Baseball;

--creating and populating the total salary column with the sum of all salaries for each player

if col_length('Master','PRA22_Total_Salary') is null
begin
	alter Table Master add PRA22_Total_Salary money
end;

update Master
	set PRA22_Total_Salary = (select case when sum(salary) is not null then sum(salary)
											else 0 end
						  from Salaries s
							  where s.playerID = Master.playerID);

if object_id ('PRA22-Salary_MOD','TR') is not null
begin
   drop trigger PRA22_Salary_MOD
end

create trigger PRA22_Salary_MOD on Salaries 
after insert, update
as
begin 

--updating the total salary column in master table for all player records inserted or updated in the salaries table.
	update Master set PRA22_Total_Salary = (select sum(x.salary)
												from (select * from Salaries sal
														where sal.playerID in (select playerID
																				from inserted)) x
												group by x.playerID)
	where Master.playerID in (select playerID from inserted);

--updating the average salary column in master table for all player records inserted or updated in the salaries table.
	update Master set PRA22_Avg_Salary = (select avg(x.salary)
												from (select * from Salaries sal
														where sal.playerID in (select playerID
																				from inserted)) x
												group by x.playerID)
	where Master.playerID in (select playerID from inserted);

--updating the PRA22_401K column in salaries table for all player records inserted or updated in the salaries table.
	update Salaries set PRA22_401K = (select case when salary < 2000000 then salary * 0.10
												  when salary >= 2000000 then salary * 0.05 
											 end)
	where convert(varchar,Salaries.yearID) + Salaries.teamID + Salaries.lgID + Salaries.playerID 
		in (select convert(varchar,yearID) + teamID + lgID + playerID from inserted);
end;

select playerID, PRA22_Avg_Salary, PRA22_Total_Salary from Master where playerID = 'abercda01';
select * from Salaries where playerID = 'abercda01';

insert into Salaries(yearID, teamID, lgID, playerID, salary) values(2007, 'CIN', 'NL', 'abercda01', 323000);
insert into Salaries(yearID, teamID, lgID, playerID, salary) values(2008, 'CIN', 'NL', 'abercda01', 50000);
insert into Salaries(yearID, teamID, lgID, playerID, salary) values(2009, 'CIN', 'NL', 'abercda01', 200000);
insert into Salaries(yearID, teamID, lgID, playerID, salary) values(2010, 'CIN', 'NL', 'abercda01', 250000);
insert into Salaries(yearID, teamID, lgID, playerID, salary) values(2011, 'CIN', 'NL', 'abercda01', 350000);

select playerID, PRA22_Avg_Salary, PRA22_Total_Salary from Master where playerID = 'abercda01';
select * from Salaries where playerID = 'abercda01';

update Salaries set salary = salary * 1.10 
				where yearID <> 2006 and playerID = 'abercda01';

select playerID, PRA22_Avg_Salary, PRA22_Total_Salary from Master where playerID = 'abercda01';
select * from Salaries where playerID = 'abercda01';