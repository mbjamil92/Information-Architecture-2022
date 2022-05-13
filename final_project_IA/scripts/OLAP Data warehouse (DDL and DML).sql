CREATE DATABASE  IF NOT EXISTS `dmv_dw` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `dmv_dw`;
-- MySQL dump 10.13  Distrib 8.0.17, for Win64 (x86_64)
--
-- Host: localhost    Database: dav6100_db
-- ------------------------------------------------------
-- Server version	8.0.17

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

use dmv_dw;

-- For our warehouse we would be using the data for year 2018 and would be limiting data to 100K records
-- dim table#1 for Ticket violation:
DROP TABLE IF EXISTS `dim_ticket_violation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dim_ticket_violation` (
  `ticket_key` int NOT NULL AUTO_INCREMENT,
  `Violation Charged Code` varchar(100),
  `Violation Description` varchar(500),
  `Violation Day of Week` varchar(100),
  `Violation Month` int(11),
  `Age at Violation` float,
  `Gender` varchar(100),
  `State of License` varchar(100),
  `Police Agency` varchar(100),
  `Court` varchar(100),
  PRIMARY KEY( `ticket_key`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=default;
/*!40101 SET character_set_client = @saved_cs_client */;


-- ETL for table#1:
/*!40000 ALTER TABLE `dim_ticket_violation` DISABLE KEYS */;
insert into dmv_dw.dim_ticket_violation(`Violation Charged Code`,`Violation Description`,`Violation Day of Week`,
`Violation Month`,`Age at Violation`,`Gender`,`State of License`,`Police Agency`,`Court`)
(SELECT DISTINCT `Violation Charged Code`,`Violation Description`,`Violation Day of Week`,
`Violation Month`,`Age at Violation`,`Gender`,`State of License`,`Police Agency`,`Court` FROM final_project_db.traffic_tickets_source1
where `Violation Year` = '2018'
LIMIT 100000);
/*!40000 ALTER TABLE `dim_ticket_violation` ENABLE KEYS */;


-- checking the query for table#1:
select * from dmv_dw.dim_ticket_violation;

####################################################
-- dim table#2 for Motor Vehicle Crash violation information:
DROP TABLE IF EXISTS `dim_mtr_crash_violation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dim_mtr_crash_violation` (
  `violation_key` int NOT NULL AUTO_INCREMENT,
  `Case Individual ID` int(11),
  `Crash Violation Description` varchar(500),
  `Violation Code` varchar(100),
  PRIMARY KEY(`violation_key`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=default;
/*!40101 SET character_set_client = @saved_cs_client */;


-- ETL for table#2:
/*!40000 ALTER TABLE `dim_mtr_crash_violation` DISABLE KEYS */;
insert into dmv_dw.dim_mtr_crash_violation(`Case Individual ID`,`Crash Violation Description`,`Violation Code`)
(SELECT DISTINCT `Case Individual ID`,`Violation Description`,`Violation Code` FROM final_project_db.violation_info_source2
where `Year` = '2018'
LIMIT 100000);
/*!40000 ALTER TABLE `dim_mtr_crash_violation` ENABLE KEYS */;

-- checking the query for table#2:
select * from dim_mtr_crash_violation

####################################################
-- dim table#3 for Motor Vehicle Crash individual information:
DROP TABLE IF EXISTS `dim_mtr_crash_individual`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dim_mtr_crash_individual` (
  `individual_key` int NOT NULL AUTO_INCREMENT,
  `case individual id` int(11),
  `case vehicle id` int(11),
  `victim status` varchar(200),
  `role type` varchar(200),
  `seating position` varchar(200),
  `ejection` varchar(200),
  `sex` varchar(200),
  `transported by` varchar(200),
  `safety equipment` varchar(200),
  `injury descriptor` varchar(200),
  `injury location` varchar(200),
  `injury severity` varchar(200),
  PRIMARY KEY(`individual_key`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=default;
/*!40101 SET character_set_client = @saved_cs_client */;

-- ETL for table#3:
/*!40000 ALTER TABLE `dim_mtr_crash_individual` DISABLE KEYS */;
insert into dmv_dw.dim_mtr_crash_individual(`case individual id`,`case vehicle id`,`victim status`,`role type`,`seating position`,
`ejection`,`sex`,`transported by`,`safety equipment`,`injury descriptor`,`injury location`,
`injury severity`)
(SELECT DISTINCT `case individual id`,`case vehicle id`,`victim status`,`role type`,`seating position`,
`ejection`,`sex`,`transported by`,`safety equipment`,`injury descriptor`,`injury location`,
`injury severity` FROM final_project_db.individual_info_source4
where `year` = '2018'
LIMIT 100000);
/*!40000 ALTER TABLE `dim_mtr_crash_violation` ENABLE KEYS */;

-- checking the query for table#3:
select * from dmv_dw.dim_mtr_crash_individual;


####################################################
-- dim table#4 for Motor Vehicle Crash vehicle information:
DROP TABLE IF EXISTS `dim_mtr_crash_vehicle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dim_mtr_crash_vehicle` (
  `vehicle_key` int NOT NULL AUTO_INCREMENT,
  `case vehicle id` int(11),
  `vehicle body type` varchar(200),
  `registration class` varchar(200),
  `action prior to accident` varchar(200),
  `type / axles of truck or bus` varchar(200),
  `direction of travel` varchar(200),
  `fuel type` varchar(200),
  `vehicle year` varchar(200),
  `number of occupants` varchar(200),
  `engine cylinders` varchar(200),
  `vehicle make` varchar(200),
  `contributing factor 1` varchar(200),
  `contributing factor 1 description` varchar(200),
  `contributing factor 2` varchar(200),
  `contributing factor 2 description` varchar(200),
  `event type` varchar(200),
  PRIMARY KEY(`vehicle_key`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=default;
/*!40101 SET character_set_client = @saved_cs_client */;

-- ETL for table#4:
/*!40000 ALTER TABLE `dim_mtr_crash_individual` DISABLE KEYS */;
insert into dmv_dw.dim_mtr_crash_vehicle(`case vehicle id`,`vehicle body type`,`registration class`,`action prior to accident`,
`type / axles of truck or bus`,`direction of travel`,`fuel type`,`vehicle year`,`number of occupants`,
`engine cylinders`,`vehicle make`,`contributing factor 1`,`contributing factor 1 description`,
`contributing factor 2`,`contributing factor 2 description`,`event type`)
(SELECT DISTINCT `case vehicle id`,`vehicle body type`,`registration class`,`action prior to accident`,
`type / axles of truck or bus`,`direction of travel`,`fuel type`,`vehicle year`,`number of occupants`,
`engine cylinders`,`vehicle make`,`contributing factor 1`,`contributing factor 1 description`,
`contributing factor 2`,`contributing factor 2 description`,`event type`
FROM final_project_db.vehicle_info_source3
where `year` = '2018'
LIMIT 100000);
/*!40000 ALTER TABLE `dim_mtr_crash_individual` ENABLE KEYS */;

-- checking the query for table#4:
select * from dmv_dw.dim_mtr_crash_vehicle;

####################################################
-- creating 5th (fact table):
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS `fact_dmv`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fact_dmv`(
`ticket_key` int,
`violation_key` int, 
`individual_key` int,
`vehicle_key` int,
`count_ticket_violations` int,
`count_motor_violations` int,
FOREIGN KEY (`ticket_key`) REFERENCES `dim_ticket_violation`(`ticket_key`),
FOREIGN KEY (`violation_key`) REFERENCES `dim_mtr_crash_violation`(`violation_key`),
FOREIGN KEY (`individual_key`) REFERENCES `dim_mtr_crash_individual`(`individual_key`),
FOREIGN KEY (`vehicle_key`) REFERENCES `dim_mtr_crash_vehicle`(`vehicle_key`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=default;
/*!40101 SET character_set_client = @saved_cs_client */;
SET FOREIGN_KEY_CHECKS=1;

-- ETL now:

SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;
insert into dmv_dw.fact_dmv(ticket_key,violation_key,individual_key,vehicle_key,count_ticket_violations,count_motor_violations)
(select 
distinct d1.ticket_key, 
d2.violation_key, 
d3.individual_key, 
d4.vehicle_key,
count(d1.`Violation Charged Code`) as count_ticket_violations,
count(d2.`Violation Code`) as count_motor_violations
from dmv_dw.dim_ticket_violation as d1,
dmv_dw.dim_mtr_crash_violation as d2,
dmv_dw.dim_mtr_crash_individual as d3,
dmv_dw.dim_mtr_crash_vehicle as d4
where d1.`Violation Charged Code`= d2.`Violation Code`
and d2.`Case Individual ID` = d3.`case individual id`
and d3.`case vehicle id` = d4.`case vehicle id`
group by d1.ticket_key, 
d2.violation_key, 
d3.individual_key, 
d4.vehicle_key);
SET SQL_SAFE_UPDATES = 1;
SET FOREIGN_KEY_CHECKS = 1;

-- checking fact table:
select * from fact_dmv

