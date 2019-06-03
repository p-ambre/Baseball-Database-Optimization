--adding primary Key to master table
alter table dbo.Master
alter column playerID varchar(255) NOT NULL;
go

alter table dbo.Master
add constraint master_tb primary key (playerID); 
go

--adding primary key to teams table
alter table dbo.Teams
alter column teamID varchar (255) not null;
go

alter table dbo.Teams
alter column yearID int not null;
go

alter table dbo.Teams
alter column lgID varchar (255) not null;
go

alter table dbo.Teams
add constraint teams_pk primary key (yearID,lgID,teamID);
go

--adding foreign key in managers with reference to master table
alter table dbo.Managers
add constraint managers_fk_ref_master foreign key (playerID) references dbo.Master(playerID);
go

--adding foreign key in AllstarFull with reference to Teams Table
alter table dbo.AllstarFull
add constraint allstarfull_fk_ref_teams foreign key (yearID, lgID, teamID) references dbo.Teams(yearID, lgID, teamID);
go

--adding foreign key in AllstarFull with reference to Master Table 
alter table dbo.AllstarFull
add constraint allstarfull_fk_ref_master foreign key (playerID) references dbo.Master(playerID);
go

--adding foreign key in Managers with reference to teams table
alter table dbo.Managers
add constraint managers_fk_ref_teams foreign key (yearID, lgID, teamID) references dbo.Teams(yearID, lgID, teamID);
go

--adding foreign key in Pitching with reference to master table
alter table dbo.Pitching
add constraint picth_fk_ref_playerid_master foreign key (playerID) references dbo.Master(playerID);
go

--adding foreign key in pitching with reference to teams table
alter table dbo.Pitching
add constraint pitch_fk_ref_composite_teams foreign key (yearID, lgID, teamID) references dbo.Teams(yearID, lgID, teamID);
go

--adding primary key in Schools table
alter table dbo.Schools
alter column schoolID varchar(255) NOT NULL;
go

alter table dbo.Schools
add constraint schools_pk primary key (schoolID);
go

--Absence of few records in the master table and presence of those absent records in the salaries table, lead to conflict while adding foreign keys in salaries.
--finding missing records 
select distinct playerID from dbo.Salaries
where playerID not in
(select playerID from dbo.Master);

--inserting missing records
insert into  dbo.Master(PlayerID)
select distinct playerID from dbo.Salaries
where playerID not in
(select playerID from dbo.Master);

--adding foreign key in Salaries with reference to Master table
alter table dbo.Salaries
add constraint salaries_fk_ref_master foreign key (playerID) references dbo.Master(playerID);
go

--adding foreign key to Salaries with references to Teams table
alter table dbo.Salaries
add constraint salaries_fk_ref_composite_teams foreign key (yearID, lgID, teamID) references dbo.Teams(yearID, lgID, teamID);
go

--Creating Leagues Table
create table dbo.Leagues 
(
    lgID varchar(255) NOT NULL,
    leagueName varchar(255) NULL,
	constraint leagues_pk primary key (lgID)
);
go

--Inserting Data Into Leagues Table
insert into Leagues values('UA','Union Association');
go
insert into Leagues values('AL','American League');
go
insert into Leagues values('NA','National Association');
go
insert into Leagues values('NL','National League');
go
insert into Leagues values('AA','American Association');
go
insert into Leagues values('FL','Federal League');
go
insert into Leagues values('PL','Players League');
go

--adding foreign key in AwardsShareManagers with reference to Leagues table
alter table dbo.AwardsShareManagers
add constraint awardssharemanagers_fk_refpk_leagues foreign key (lgID) references dbo.Leagues(lgID);
go

--adding primary key to Parks
alter table dbo.Parks
alter column park_key varchar(255) NOT NULL;
go

alter table dbo.Parks
add constraint parkkey_pk primary key (park_key);
go

--adding foreign key in HomeGames with reference to Parks table
alter table dbo.HomeGames
add constraint homegames_fk_ref_parks foreign key (parkID) references dbo.Parks(park_key);
go

--adding foreign key in HomeGames with reference to teams table
alter table dbo.HomeGames
add constraint homegames_fk_ref_composite_teams foreign key (yearID, lgID, teamID) references dbo.Teams(yearID, lgID, teamID);
go

--adding foreign key in Appearances with reference to teams table
alter table dbo.Appearances
add constraint appearances_fk_ref_composite_teams foreign key (yearID, lgID, teamID) references dbo.Teams(yearID, lgID, teamID);
go

--adding foreign key in Appearances with reference to Master table
alter table dbo.Appearances
add constraint appearances_fk_ref_master foreign key (playerID) references dbo.Master(playerID);
go

--adding foreign key in Fielding with reference to Master table
alter table dbo.Fielding
add constraint fielding_fk_ref_master foreign key (playerID) references dbo.Master(playerID);
go

--adding foreign key in Fielding with references to teams table
alter table dbo.Fielding
add constraint fielding_fk_ref_composite_teams foreign key (yearID, lgID, teamID) references dbo.Teams(yearID, lgID, teamID);
go

--adding foreign key in AwardsPlayers with reference to Master
alter table dbo.AwardsPlayers
add constraint awardsplayer_fk_ref_master foreign key (playerID) references dbo.Master(playerID);
go

--adding foreign key in AwardsManager with reference to Master
alter table dbo.AwardsManagers
add constraint awardsmanager_fk_ref_master foreign key (playerID) references dbo.Master(playerID);
go

--adding primary key to TeamsFranchises
alter table dbo.TeamsFranchises
alter column franchID varchar(255) NOT NULL;
go

alter table dbo.TeamsFranchises
add constraint teamfranchises_pk primary key (franchID);
go

--adding foreign key in CollegePlaying with reference to Master
alter table dbo.CollegePlaying
add constraint collegeplaying_fk_ref_master foreign key (playerID) references dbo.Master(playerID);
go

--adding foreign key in FieldingOF with reference to Master
alter table dbo.FieldingOF
add constraint fieldingof_fk_ref_master foreign key (playerID) references dbo.Master(playerID);
go

--adding foreign key in Batting with reference to Master
alter table dbo.Batting
add constraint batting_fk_ref_master foreign key (playerID) references dbo.Master(playerID);
go

--adding foreign key in Batting with references to teams table
alter table dbo.Batting
add constraint batting_fk_ref_composite_teams foreign key (yearID, lgID, teamID) references dbo.Teams(yearID, lgID, teamID);
go

--adding foreign key in AwardsShareManagers with reference to Master
alter table dbo.AwardsShareManagers
add constraint awardssharemanagers_fk_ref_master foreign key (playerID) references dbo.Master(playerID);
go

--adding foreign key in AwardsSharePlayers with reference to Master
alter table dbo.AwardsSharePlayers
add constraint awardsshareplayers_fk_ref_master foreign key (playerID) references dbo.Master(playerID);
go

--adding foreign key in Teams with reference to TeamsFranchises
alter table dbo.Teams
add constraint teams_fk_ref_teamsfranchises foreign key (franchID) references dbo.TeamsFranchises(franchID);
go

--Absence of few records in the schools table and presence of those absent records in the collegePlaying table, lead to conflict while adding foreign keys in collegePlays.
--missing records
select distinct schoolID from dbo.CollegePlaying
where schoolID not in
(select schoolID from dbo.Schools)

--inserting missing records
insert into  dbo.Schools(schoolID)
select distinct schoolID from dbo.CollegePlaying
where schoolID not in
(select schoolID from dbo.Schools);

--adding foreign key in CollegePlaying with reference to Schools
alter table dbo.CollegePlaying
add constraint collegeplaying_fk_ref_schools foreign key (schoolID) references dbo.Schools(schoolID);
go

--adding foreign key in Managers with reference to Leagues
alter table dbo.Managers
add constraint managers_fk_ref_leagues foreign key (lgID) references dbo.Leagues(lgID);
go

--adding foreign key in Teams with reference to Leagues
alter table dbo.Teams
add constraint teams_fk_ref_leagues foreign key (lgID) references dbo.Leagues(lgID);
go

--adding foreign key in AllstarFull with reference to Leagues
alter table dbo.AllstarFull
add constraint allstarfull_fk_ref_leagues foreign key (lgID) references dbo.Leagues(lgID);
go

--adding foreign key in Fielding with reference to Leagues
alter table dbo.Fielding
add constraint fielding_fk_ref_leagues foreign key (lgID) references dbo.Leagues(lgID);
go

--adding foreign key in Appearances with reference to Leagues
alter table dbo.Appearances
add constraint appaerances_fk_refer_leagues foreign key (lgID) references dbo.Leagues(lgID);
go

--adding foreign key in Salaries with reference to Leagues
alter table dbo.Salaries
add constraint salaries_fk_ref_leagues foreign key (lgID) references dbo.Leagues(lgID);
go

--adding foreign key in Batting with reference to Leagues
alter table dbo.Batting
add constraint batting_fk_ref_leagues foreign key (lgID) references dbo.Leagues(lgID);
go

--adding foreign key in HomeGames with reference to Leagues
alter table dbo.HomeGames
add constraint homegames_fk_ref_leagues foreign key (lgID) references dbo.Leagues(lgID);
go


