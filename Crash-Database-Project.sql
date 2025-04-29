CREATE SCHEMA Crash_data;
USE Crash_data;


CREATE TABLE crash(
	collision_id int unsigned,
    crash_time varchar(50),
    crash_date varchar(50),
    primary key(collision_id));



CREATE TABLE people(collision_id int unsigned primary key,
    people_injured smallint unsigned,
    people_killed smallint unsigned);
    

CREATE TABLE pedestrians(collision_id int unsigned primary key,
    ped_injured smallint unsigned,
    ped_killed smallint unsigned);


CREATE TABLE cyclists(collision_id int unsigned primary key,
    cyc_injured smallint unsigned,
    cyc_killed smallint unsigned);


CREATE TABLE motorists(collision_id int unsigned primary key,
	mot_injured smallint unsigned,
    mot_killed smallint unsigned);


CREATE TABLE location(collision_id int unsigned primary key,
    borough varchar(50),
    zip_code varchar(50));

    
SET SQL_MODE = ANSI_QUOTES; #allow quotes in argument
INSERT INTO crash(collision_id, crash_time, crash_date)
SELECT COLLISION_ID, "CRASH TIME", "CRASH DATE"
FROM "motor_vehicle_collisions_-_crashes";

Insert into cyclists(collision_id, cyc_injured, cyc_killed)
Select COLLISION_ID, "NUMBER OF CYCLIST INJURED", "NUMBER OF CYCLIST KILLED"
FROM "motor_vehicle_collisions_-_crashes";

insert into people(collision_id, people_injured, people_killed)
select COLLISION_ID, "NUMBER OF PERSONS INJURED", "NUMBER OF PERSONS KILLED"
FROM "motor_vehicle_collisions_-_crashes";

insert into pedestrians(collision_id, ped_injured, ped_killed)
select COLLISION_ID, "NUMBER OF PEDESTRIANS INJURED", "NUMBER OF PEDESTRIANS KILLED"
FROM "motor_vehicle_collisions_-_crashes";

insert into motorists(collision_id, mot_injured, mot_killed)
select COLLISION_ID, "NUMBER OF MOTORIST INJURED", "NUMBER OF MOTORIST KILLED"
FROM "motor_vehicle_collisions_-_crashes";

insert into location(collision_id, borough, zip_code)
select COLLISION_ID, BOROUGH, "ZIP CODE"
FROM "motor_vehicle_collisions_-_crashes";

# 1 find the zip code and time of the crash that had the most overall injuries.

WITH 
cte1 as(SELECT zip_code, collision_id FROM location),
cte2 as(SELECT crash_time, collision_id FROM crash),
cte3 as(SELECT people_injured, collision_id FROM people)
SELECT zip_code, crash_time, MAX(people_injured)
FROM cte1, cte2, cte3
WHERE cte1.collision_id=cte2.collision_id AND cte2.collision_id=cte3.collision_id;




# 2 find the date of the crash where there were pedestrians injured.

WITH 
cte1 as(SELECT crash_date, collision_id FROM crash),
cte2 as(SELECT ped_injured, collision_id FROM pedestrians)
SELECT crash_date, ped_injured
FROM cte1, cte2
WHERE cte1.collision_id=cte2.collision_id 
and ped_injured <>0
GROUP BY crash_date;



# 3 Find the borough that, on average has higher pedestrian injuries than the average number of pedestrian injuries in Brooklyn

SELECT borough, ped_injured
FROM pedestrians, location
WHERE pedestrians.collision_id=location.collision_id
GROUP BY borough
HAVING MAX(ped_injured)>ALL(SELECT MAX(ped_injured)
FROM pedestrians
WHERE borough='Brooklyn'
GROUP BY borough);

# 4 find the maximum number of motorist deaths for each borough

SELECT borough, max(mot_killed)
FROM location, motorists
WHERE location.collision_id=motorists.collision_id
GROUP BY borough;

# 5 Find the least amount of cyclists injured for each borough, in the year 2022

SELECT cyc_injured, borough, crash_date
FROM cyclists, location, crash
WHERE crash.collision_id=cyclists.collision_id and 
cyclists.collision_id=location.collision_id
and RIGHT(crash_date, 4)='2022';


# 6 for each zip code, find the number of motorists injured. Order by motorists injured in descending order

SELECT zip_code, count(mot_injured) as mot_injured
FROM location, motorists
WHERE location.collision_id=motorists.collision_id
GROUP BY zip_code
ORDER BY mot_injured DESC;

# 7 Find the date of all crashes occuring in 2021 where the total number of injured is larger than at least one crash in 2022.

SELECT crash_date, people_injured
FROM crash, people
WHERE crash.collision_id=people.collision_id
and (RIGHT(crash_date,4)='2021')> SOME(SELECT (RIGHT(crash_date,4)='2022') FROM crash)
ORDER BY people_injured DESC;


# 8 list the times of collisions that had cyclist injuries and no motorist injuries


SELECT crash_time, cyc_injured, mot_injured
FROM crash, cyclists, motorists
WHERE crash.collision_id=cyclists.collision_id and cyclists.collision_id=motorists.collision_id
and cyc_injured >=1 and mot_injured=0;

# 9 create a view for pedestrians and locations

 
 CREATE VIEW pedestrianlocation AS
 SELECT collision_id, ped_injured, ped_killed, zip_code, borough
 FROM pedestrians NATURAL JOIN location NATURAL JOIN crash;
 
 # 10 list the number of crashes per borough

SELECT borough, COUNT(distinct collision_id) as num_of_crashes
FROM location RIGHT JOIN crash using(collision_id)
GROUP BY borough;









    

