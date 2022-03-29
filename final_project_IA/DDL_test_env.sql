# DDL for test environment for project:

CREATE DATABASE `IA_Final_Project_NY_Transportation_Test` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

-- creating 1st table for data source #1:
use IA_Final_Project_NY_Transportation_Test;
DROP TABLE IF EXISTS `traffic_tickets_source1`;
CREATE TABLE `traffic_tickets_source1` (
  `Violation Charged Code` varchar(100),
  `Violation Description` varchar(500),
  `Violation Year` int,
  `Violation Month` int,
  `Violation Day of Week` varchar(100),
  `Age at Violation` float,
  `Gender` varchar(100),
  `State of License` varchar(100),
  `Police Agency` varchar(100),
  `Court` varchar(100),
  `Source` varchar(100)
  );
  -- testing 1st data source:
  select * from `traffic_tickets_source1`;
 
 
 -- creating 2nd table for data source #2:

DROP TABLE IF EXISTS `vehicle_crashes_source2`;
CREATE TABLE `vehicle_crashes_source2`(
  `Year` int,
  `Violation Description` varchar(500),
  `Violation Code` varchar(100),
  `Case Individual ID` int
  );
  
-- testing 2nd data source:
  select * from `vehicle_crashes_source2`;