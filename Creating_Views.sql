use Spring_2018_Baseball;

create view pra22_Player_History
			(playerID, Player_Name, #_of_Teams_played_for, #_of_Years_played, Total_Salary, Average_Salary, Name_of_last_college_attended, Year_Last_played_in_College, 
			 #_of_Years_attended_college, #_of_different_colleges_played_for, Year_last_played, Name_of_last_Team_played_for, Last_Year_played_in_AllStars,
			 ID_of_Last_team_played_in_AllStars, Name_of_Last_Team_played_in_AllStars, Last_league_in_AllStars, Last_Position_played_in_AllStars, 
			 Year_of_highest_Batting_Average, Highest_Batting_Average,Name_of_the_Team_of_Highest_batting_Average, Total_num_of_Home_runs,
			 #_of_Years_as_Manager, #_of_distinct_Teams_Managed,Average_percent_wins_as_manager, Year_of_highest_percent_wins, Team_of_highest_percent_wins) 
as

with Player_Data as
(select mt.playerID, (mt.nameFirst + ' ( ' + mt.nameGiven + ' ) '+ mt.nameLast) as PlayerName,
	(select count(*) from (select playerID, teamid from Appearances group by playerID,teamID) a 
		where mt.playerID = a.playerID) as #_of_teams_played, 
	(select max(yearID) - min(yearID) + 1 from Appearances a	
			where mt.playerID = a.playerID) as #_of_Yrs_played from Master mt),

Salary_Data as
(select distinct sl.playerID, format(sum(sl.salary),'C') as Total_Salary, 
	format(avg(sl.salary),'C') as Avg_Salary from Salaries sl group by playerID),

College_Data as
  (select distinct c.playerID, s.name_full as Last_College, cc.year_last_played,cc.#_of_years, 
	(select count(*) from (select playerID, schoolID from CollegePlaying group by playerID, schoolID) sc
		where cc.playerID = sc.playerID) as #_of_Colleges_played from CollegePlaying c, 
	(select c.playerID, max(c.yearID) as year_last_played,
		(max(c.yearID) - min(c.yearID) + 1) as #_of_years from CollegePlaying c
		group by playerID) cc, Schools s
	where c.playerID = cc.playerID and
	s.schoolID = c.schoolID and	c.yearID = cc.year_last_played),

Career_Data as
  (select a.playerID, y.year_last_played, tm.name as last_team_played_for from Appearances a,
	(select a.playerID, max(a.yearID) as year_last_played from Appearances a group by a.playerID) y, Teams tm where
	a.playerID = y.playerID 
	and a.teamID = tm.teamID 
	and a.yearID = tm.yearID 
	and a.lgID = tm.lgID 
	and a.yearID = y.year_last_played),

Allstar_Data as
(select distinct a.playerID, a.yearID as last_yr_played_AllStars, a.teamID as last_AllStars_TeamID, 
tm.name as last_AllStars_Team_name, a.lgID as last_AllStars_lgID, a.startingPos as last_AllStars_Pos
from AllstarFull a, 
	(select a.playerID, max(a.yearID) as Last_Yr_played_in_AllStars from AllstarFull a
		group by playerID) aa, Teams tm
	where a.playerID = aa.playerID and
	tm.teamID = a.teamID and
	tm.yearID = a.yearID and
	tm.lgID = a.lgID and
	a.yearID = aa.Last_Yr_played_in_AllStars),



Batting_Data as
(select b.playerID, b.yearID as Highest_Bat_Avg_Yr, b.Bat_Avg as Highest_Bat_Avg, 
b.teamID as Highest_Bat_Avg_Team,bb.Total_Home_Run from 
	(select *, H*1.0/AB as Bat_Avg from Batting where AB > 0) b, 
		(select bx.playerID, max(bx.Bat_Avg) as Highest_bat_Avg,sum(bx.HR) as Total_Home_Run
			from (select *, H*1.0/AB as Bat_Avg from Batting where AB > 0) bx
			group by bx.playerID) bb, Teams tm
where b.playerID = bb.playerID and
	b.Bat_Avg = bb.Highest_bat_Avg and
	b.teamID = tm.teamID and
	b.yearID = tm.yearID and
	b.lgID = tm.lgID),



Manager_Data as
(select m1.playerID, mx.#_of_Years_as_Mgr,
(select count(*) from (select playerID, teamID from Managers
					   where plyrMgr = 'Y' group by playerID, teamID) m2
	where m1.playerID = m2.playerID) as #_of_teams_managed,
format(mx.Avg_WR,'P') as Average_Win_Percent,m1.yearID as Max_Mgr_win_percent_year,
tm.name as Max_Mgr_win_percent_team from Teams tm, 
	(select *,(W*1.0/G) as Win_ratio from Managers where plyrMgr = 'Y') m1,
	(select playerID, max(yearID) - min(yearID) + 1 as #_of_Years_as_Mgr,
		avg(Win_ratio) as Avg_WR, max(Win_ratio) as Max_WR 
		from (select *,(W*1.0/G) as Win_ratio from Managers where plyrMgr = 'Y') mm
		group by playerID) mx
where m1.playerID = mx.playerID and
m1.yearID = tm.yearID and
m1.teamID = tm.teamID and
m1.lgID = tm.lgID and 
m1.Win_ratio = mx.Max_WR)
	
	(select pd.playerID, pd.playerName, pd.#_of_teams_played, pd.#_of_Yrs_played, 
						sd.Total_salary, sd.Avg_salary, cd.Last_College, cd.year_last_played, 
						cd.#_of_years, cd.#_of_Colleges_played, cad.year_last_played, 
						cad.last_team_played_for, ad.last_yr_played_AllStars, ad.Last_AllStars_lgID, ad.Last_AllStars_TeamID,
						ad.Last_AllStars_Team_name,	ad.Last_AllStars_Pos, bd.Highest_Bat_Avg_Yr,
						bd.Highest_Bat_Avg, bd.Highest_Bat_Avg_Team, bd.Total_Home_Run,
						md.#_of_teams_managed, md.#_of_Years_as_Mgr, md.Average_Win_Percent,
						md.Max_Mgr_win_percent_team, md.Max_Mgr_win_percent_year
				from player_data pd left outer join salary_data sd on pd.playerID = sd.playerID 
									left outer join college_data cd on pd.playerID = cd.playerID
									left outer join career_data cad on pd.playerID = cad.playerID
									left outer join allstar_data ad on pd.playerID = ad.playerID
									left outer join batting_data bd on pd.playerID = bd.playerID
									left outer join manager_data md on pd.playerID = md.playerID
				);

go
select * from pra22_Player_History;






