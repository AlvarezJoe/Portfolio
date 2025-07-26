DROP DATABASE IF EXISTS movie_theater_chain;
GO
CREATE DATABASE movie_theater_chain;
GO
USE movie_theater_chain;
GO

DROP TABLE IF EXISTS position;
CREATE TABLE position (
  position_id int NOT NULL,
  title varchar(25) NOT NULL,
  rate decimal(5,2) NOT NULL,
  PRIMARY KEY (position_id)
);
GO

DROP TABLE IF EXISTS location;
CREATE TABLE location (
  location_id int NOT NULL,
  address varchar(255) NOT NULL,
  city varchar(25) NOT NULL,
  state varchar(2) NOT NULL,
  zip varchar(25) NOT NULL,
  PRIMARY KEY (location_id)
);
GO

DROP TABLE IF EXISTS employee;
GO
CREATE TABLE employee (
  employee_id int NOT NULL,
  location_id int NOT NULL,
  position_id int NOT NULL,
  first_name varchar(25) NOT NULL,
  last_name varchar(25) NOT NULL,
  phone varchar(25) NOT NULL,
  email varchar(80) NOT NULL,
  PRIMARY KEY (employee_id),
  CONSTRAINT fk_employee_location FOREIGN KEY (location_id) REFERENCES location (location_id) ON UPDATE CASCADE,
  CONSTRAINT fk_employee_position1 FOREIGN KEY (position_id) REFERENCES position (position_id) ON UPDATE CASCADE
);
GO

DROP TABLE IF EXISTS item;
CREATE TABLE item (
  item_id int NOT NULL,
  name varchar(60) NOT NULL,
  price decimal(5,2) NOT NULL,
  discounted_price decimal(5,2) DEFAULT NULL,
  cost_per_unit decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (item_id)
);
GO

DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
  sale_id int NOT NULL,
  location_id int NOT NULL,
  employee_id int NOT NULL,
  sale_date date NOT NULL,
  PRIMARY KEY (sale_id),
  CONSTRAINT fk_sales_employee1 FOREIGN KEY (employee_id) REFERENCES employee (employee_id) ON UPDATE CASCADE,
  CONSTRAINT fk_sales_location1 FOREIGN KEY (location_id) REFERENCES location (location_id) ON UPDATE NO ACTION
);
GO

DROP TABLE IF EXISTS theater;
CREATE TABLE theater (
  theater_id int NOT NULL,
  location_id int NOT NULL,
  theater_number VARCHAR(5) NOT NULL,
  type varchar(25) NOT NULL,
  seats smallint NOT NULL,
  PRIMARY KEY (theater_id),
  CONSTRAINT fk_theater_location1 FOREIGN KEY (location_id) REFERENCES location (location_id) ON UPDATE CASCADE
);
GO

DROP TABLE IF EXISTS sale_details;
CREATE TABLE sale_details (
  sale_details_id int NOT NULL,
  sale_id int NOT NULL,
  item_id int NOT NULL,
  theater_id int NULL,
  quantity smallint NOT NULL,
  notes varchar(255) DEFAULT NULL,
  PRIMARY KEY (sale_details_id),
  CONSTRAINT fk_sale_details_item1 FOREIGN KEY (item_id) REFERENCES item (item_id) ON UPDATE CASCADE,
  CONSTRAINT fk_sale_details_sales1 FOREIGN KEY (sale_id) REFERENCES sales (sale_id) ON UPDATE CASCADE,
  CONSTRAINT fk_sale_details_theater1 FOREIGN KEY (theater_id) REFERENCES theater (theater_id) ON UPDATE NO ACTION
);
GO

INSERT INTO location VALUES (1000,'2965 Agriculture Lane','Miami','FL','33145'),(1001,'909 2nd St','Miami','FL','33139'),(1002,'2510 NE 182nd Ter','North Miami Beach','FL','33160'),(1003,'7363 NW 173rd Dr #102','Hialeah','FL','33015'),(1004,'8366 W 14th Ave','Hialeah','FL','33014');
GO

INSERT INTO position VALUES (2000,'part-time',13.45),(2001,'full-time',15.19),(2002,'team-lead',17.22),(2003,'manager',25.89);
GO

INSERT INTO employee VALUES (1,1000,2003,'Jack','Williams','3055673451','jackwilliams@example.com'),(2,1000,2002,'Vanessa','Perez','7869996365','VPerez2@miamitheaters.com'),(3,1000,2002,'Bryan','Garcia','9548693214','BGarcia3@miamitheaters.com'),(4,1000,2002,'Todd','Gomez','3057893256','toddgomez@example.com'),(5,1000,2001,'Maria','Fernandez','9548976321','mariafernandez@example.com'),(6,1000,2001,'Jake','Hernandez','7863621478','JHernandez6@miamitheaters.com'),(7,1000,2001,'Andrew','Clark','9547818569','andrewclark@exmaple.com'),(8,1000,2001,'Lia','Perez','5158674156','liaperez@example.com'),(9,1000,2000,'Hillary','Myers','7867847788','HMyers9@miamitheaters.com'),(10,1000,2000,'Katherine','Gray','9546325634','KGray10@miamitheaters.com'),(11,1000,2000,'Allyson','Brewer','7865234621','ABrewer11@miamitheaters.com'),(12,1000,2000,'Michael','Arrellano','3052146389','michaelarrellano@example.com'),(13,1001,2003,'James','Harris','3052364852','JHarris13@miamitheaters.com'),(14,1001,2002,'Stacy','Sellers','4152364569','stacysellers@example.com'),(15,1001,2002,'Katherine','Barajas','3052147896','katherinebarajas@example.com'),(16,1001,2002,'Beverly','Mclaughlin','9548741235','beverlymclaughlin@example.com'),(17,1001,2002,'Savannah','Hayes','9548715556','SHayes17@miamitheaters.com'),(18,1001,2001,'Melissa','Holmes','3052221587','melissaholmes@example.com'),(19,1001,2001,'Christopher','Allen','6165223699','christopherallen@example.com'),(20,1001,2001,'Daniel','Butler','2125633354','danielbutler@example.com'),(21,1001,2001,'James','Jones','3052524567','JJones21@miamitheaters.com'),(22,1001,2001,'Crystal','Adams','7865478988','CAdams22@miamitheaters.com'),(23,1001,2000,'Sarah','Young','9541112533','sarahyoung@example.com'),(24,1001,2000,'Emily','Jackson','3057441144','emilyjackson@example.com'),(25,1001,2000,'Robert','Wade','7865549988','RWade25@miamitheaters.com'),(26,1001,2000,'Taylor','Ochoa','3054142237','taylorochoa@example.com'),(27,1002,2003,'Sergio','Fuller','9547788941','SFuller27@miamitheaters.com'),(28,1002,2002,'Joel','Morgan','3052654495','joelmorgan@example.com'),(29,1002,2002,'Heather','Martin','5859668732','heathermartin@example.com'),(30,1002,2001,'Olivia','White','3053257456','OWhite30@miamitheaters.com'),(31,1002,2001,'Gregory','Johnson','3614569552','gregoryjohnson@example.com'),(32,1002,2001,'Laura','Nelson','7869653364','lauranelson@example.com'),(33,1002,2000,'Jesse','Ramirez','3054218966','JRamirez33@miamitheaters.com'),(34,1002,2000,'Steven','Smith','3054189988','stevensmith@example.com'),(35,1002,2000,'Cesar','Foster','3054178992','cesarfoster@example.com'),(36,1002,2000,'Shawn','Adkins','3054777922','SAdkins36@miamitheaters.com'),(37,1003,2003,'Theresa','Brady','3055489688','theresabrady@example.com'),(38,1003,2002,'Matthew','Lee','3052369955','MLee38@miamitheaters.com'),(39,1003,2002,'Peter','Sanchez','7865522336','petersanchez@example.com'),(40,1003,2002,'Ernesto','Herrera','7869955447','EHerrera40@miamitheaters.com'),(41,1003,2002,'Andrea','Morrison','9547732156','andreamorrison@example.com'),(42,1003,2001,'Eduardo','Tapia','3051148857','eduardotapia@example.com'),(43,1003,2001,'Jessica','Stanley','3054236658','JStanley43@miamitheaters.com'),(44,1003,2001,'Timothy','Chang','9541658365','timothychang@example.com'),(45,1003,2001,'Alejandro','Miller','3056647823','alejandromiller@example.com'),(46,1003,2001,'Kayla','Jackson','9546561254','kaylajackson@example.com'),(47,1003,2001,'Cindy','Garcia','3054711211','CGarcia47@miamitheaters.com'),(48,1003,2001,'Erika','Martinez','7865213345','EMartinez48@miamitheaters.com'),(49,1003,2001,'Matthias','Long','9548872211','matthewlong@example.com'),(50,1003,2001,'Neil','Walsh','3054269665','NWalsh50@miamitheaters.com'),(51,1003,2000,'Krista','Webb','3059988663','kristawebb@example.com'),(52,1003,2000,'Kathleen','Ortiz','3055566378','kathleenortiz@example.com'),(53,1003,2000,'Melissa','Leon','3056458557','MLeon53@miamitheaters.com'),(54,1003,2000,'Patrick','Charles','3052423211','patrickcharles@example.com'),(55,1003,2000,'James','Evans','7865596688','jamesevans@example.com'),(56,1003,2000,'David','Smith','3054178441','DSmith56@miamitheaters.com'),(57,1004,2003,'Alisha','Hansen','9548786556','AHansen57@miamitheaters.com'),(58,1004,2002,'Thomas','Brown','3054243699','TBrown58@miamitheaters.com'),(59,1004,2002,'Tyler','Owens','3053316339','TOwens59@miamitheaters.com'),(60,1004,2002,'Shelby','Taylor','3054657899','STaylor60@miamitheaters.com'),(61,1004,2001,'Erin','Brown','9541236259','erinbrown@example.com'),(62,1004,2001,'Michael','Johnson','3052326399','michaeljohnson@example.com'),(63,1004,2001,'Kendra','Wilson','9542012300','KWilson63@miamitheaters.com'),(64,1004,2001,'Jennifer','Kirby','3056230015','jenniferkirby@example.com'),(65,1004,2001,'Melanie','Davis','7865040561','melaniedavis@example.com'),(66,1004,2000,'Erika','Richardson','3056201204','ERichardson66@miamitheaters.com'),(67,1004,2000,'Daniel','Morrow','3059603368','danielmorrow@example.com'),(68,1004,2000,'Allison','Bishop','7863226002','ABishop68@miamitheaters.com'),(69,1004,2000,'Joshua','Perez','3055426588','joshuaperez@example.com'),(70,1004,2000,'Jennifer','Serrano','7869520145','JSerrano70@miamitheaters.com');
GO

INSERT INTO item VALUES (3000,'Adult ticket',15.00,NULL,NULL),(3001,'Senior ticket',12.00,NULL,NULL),(3002,'Child ticket',8.00,NULL,NULL),(3003,'IMAX upgrade',6.00,NULL,NULL),(3004,'3D upgrade',3.00,NULL,NULL),(4000,'Small drink (32oz)',4.99,NULL,30.94),(4001,'Medium drink (44oz)',5.50,NULL,34.00),(4002,'Large drink (51oz)',6.50,NULL,40.00),(4003,'Small ICEE (32oz)',5.50,NULL,34.00),(4004,'Medium ICEE (44oz)',6.50,NULL,40.00),(4005,'Large ICEE (51oz)',7.50,NULL,46.00),(4006,'Bottled Water',5.00,NULL,31.00),(4007,'Coffee',3.00,NULL,19.00),(5000,'Small popcorn',6.00,NULL,61.00),(5001,'Medium popcorn',7.00,NULL,71.00),(5002,'Large popcorn',8.25,NULL,83.50),(6000,'Ice Cream',4.79,NULL,5.79),(6001,'Pizza',7.00,NULL,8.00),(6002,'Cheeseburger',7.50,NULL,8.50),(6003,'Chicken sandwhich',7.50,NULL,8.50),(6004,'Chicken tenders',7.00,NULL,8.00),(6005,'Hot dod',5.00,NULL,6.00),(6006,'Nachos',4.00,NULL,5.00),(6007,'Gourmet pretzel',4.00,NULL,5.00),(6008,'Cheese sticks',8.00,NULL,9.00),(6009,'Fries',3.00,NULL,4.00);
GO

INSERT INTO theater VALUES (1,1000,'N1','regular',250),(2,1000,'N2','regular',250),(3,1000,'N3','regular',225),(4,1000,'N4','regular',225),(5,1000,'N5','regular',225),(6,1000,'N6','regular',225),(7,1000,'N7','regular',175),(8,1000,'N8','regular',175),(9,1000,'N9','regular',175),(10,1000,'N10','regular',175),(11,1000,'N11','IMAX',155),(12,1000,'N12','IMAX',155),(13,1000,'N13','regular',120),(14,1000,'N14','regular',120),(15,1001,'N1','regular',250),(16,1001,'N2','regular',250),(17,1001,'N3','regular',250),(18,1001,'N4','regular',250),(19,1001,'N5','regular',225),(20,1001,'N6','regular',225),(21,1001,'N7','regular',225),(22,1001,'N8','regular',175),(23,1001,'N9','regular',175),(24,1001,'N10','regular',155),(25,1001,'N11','IMAX',155),(26,1001,'N12','IMAX',155),(27,1001,'N13','IMAX',120),(28,1001,'N14','IMAX',120),(29,1001,'N15','regular',120),(30,1001,'N16','regular',85),(31,1002,'N1','regular',320),(32,1002,'N2','regular',320),(33,1002,'N3','regular',225),(34,1002,'N4','regular',225),(35,1002,'N5','regular',225),(36,1002,'N6','regular',225),(37,1003,'N1','regular',250),(38,1003,'N2','regular',250),(39,1003,'N3','regular',250),(40,1003,'N4','regular',250),(41,1003,'N5','regular',225),(42,1003,'N6','regular',225),(43,1003,'N7','regular',225),(44,1003,'N8','regular',175),(45,1003,'N9','IMAX',225),(46,1003,'N10','IMAX',225),(47,1003,'N11','IMAX',175),(48,1003,'N12','IMAX',155),(49,1003,'N13','IMAX',155),(50,1003,'N14','IMAX',150),(51,1003,'N15','regular',225),(52,1003,'N16','regular',150),(53,1003,'N17','regular',150),(54,1003,'N18','regular',150),(55,1004,'N1','regular',250),(56,1004,'N2','regular',250),(57,1004,'N3','IMAX',225),(58,1004,'N4','IMAX',225),(59,1004,'N5','IMAX',225),(60,1004,'N6','regular',225),(61,1004,'N7','regular',175),(62,1004,'N8','regular',175),(63,1004,'N9','regular',175),(64,1004,'N10','regular',175),(65,1004,'N11','regular',155),(66,1004,'N12','regular',155),(67,1004,'N13','regular',120),(68,1004,'N14','regular',120);
GO

INSERT INTO sales VALUES (1,1000,2,'2022-01-02'),(2,1000,11,'2022-01-03'),(3,1000,5,'2022-01-03'),(4,1000,7,'2022-01-04'),(5,1000,9,'2022-01-04'),(6,1000,4,'2022-01-04'),(7,1000,12,'2022-01-05'),(8,1000,8,'2022-01-05'),(9,1000,3,'2022-01-05'),(10,1000,6,'2022-01-05'),(11,1000,9,'2022-01-06'),(12,1000,10,'2022-01-06'),(13,1000,2,'2022-01-06'),(14,1000,4,'2022-01-07'),(15,1000,3,'2022-01-07'),(16,1000,10,'2022-01-08'),(17,1000,6,'2022-01-08'),(18,1000,11,'2022-01-09'),(19,1000,5,'2022-01-09'),(20,1000,7,'2022-01-10'),(21,1000,1,'2022-01-10'),(22,1000,12,'2022-01-10'),(23,1000,8,'2022-01-11'),(24,1000,9,'2022-01-11'),(25,1000,3,'2022-01-12'),(26,1000,5,'2022-01-13'),(27,1000,10,'2022-01-13'),(28,1000,2,'2022-01-14'),(29,1000,4,'2022-01-15'),(30,1000,12,'2022-01-15'),(31,1001,14,'2022-01-02'),(32,1001,18,'2022-01-02'),(33,1001,26,'2022-01-03'),(34,1001,15,'2022-01-05'),(35,1001,20,'2022-01-05'),(36,1001,22,'2022-01-06'),(37,1001,17,'2022-01-06'),(38,1001,13,'2022-01-06'),(39,1001,21,'2022-01-07'),(40,1001,16,'2022-01-08'),(41,1001,19,'2022-01-08'),(42,1001,24,'2022-01-09'),(43,1001,25,'2022-01-09'),(44,1001,13,'2022-01-10'),(45,1001,15,'2022-01-10'),(46,1001,18,'2022-01-11'),(47,1001,19,'2022-01-11'),(48,1001,26,'2022-01-12'),(49,1001,21,'2022-01-12'),(50,1001,14,'2022-01-13'),(51,1001,20,'2022-01-13'),(52,1001,17,'2022-01-14'),(53,1001,16,'2022-01-15'),(54,1001,15,'2022-01-15'),(55,1001,24,'2022-01-16'),(56,1001,26,'2022-01-16'),(57,1001,14,'2022-01-17'),(58,1001,22,'2022-01-17'),(59,1001,23,'2022-01-19'),(60,1001,19,'2022-01-19'),(61,1002,28,'2022-01-02'),(62,1002,31,'2022-01-02'),(63,1002,35,'2022-01-02'),(64,1002,29,'2022-01-03'),(65,1002,36,'2022-01-04'),(66,1002,29,'2022-01-05'),(67,1002,33,'2022-01-05'),(68,1002,28,'2022-01-09'),(69,1002,31,'2022-01-09'),(70,1002,33,'2022-01-09'),(71,1003,46,'2022-01-02'),(72,1003,42,'2022-01-02'),(73,1003,41,'2022-01-03'),(74,1003,53,'2022-01-04'),(75,1003,47,'2022-01-04'),(76,1003,51,'2022-01-04'),(77,1003,40,'2022-01-06'),(78,1003,43,'2022-01-06'),(79,1003,42,'2022-01-07'),(80,1003,47,'2022-01-07'),(81,1003,55,'2022-01-07'),(82,1003,50,'2022-01-08'),(83,1003,42,'2022-01-09'),(84,1003,53,'2022-01-10'),(85,1003,47,'2022-01-10'),(86,1004,51,'2022-01-02'),(87,1004,52,'2022-01-02'),(88,1004,47,'2022-01-02'),(89,1004,49,'2022-01-02'),(90,1004,41,'2022-01-02'),(91,1004,42,'2022-01-02'),(92,1004,66,'2022-01-03'),(93,1004,42,'2022-01-03'),(94,1004,61,'2022-01-04'),(95,1004,70,'2022-01-04'),(96,1004,59,'2022-01-06'),(97,1004,68,'2022-01-07'),(98,1004,65,'2022-01-07'),(99,1004,64,'2022-01-08'),(100,1004,59,'2022-01-08'),(101,1004,60,'2022-01-10'),(102,1004,58,'2022-01-11'),(103,1004,59,'2022-01-12'),(104,1004,63,'2022-01-13'),(105,1004,70,'2022-01-14'),(106,1004,69,'2022-01-15');
GO

INSERT INTO sale_details VALUES (1,1,3000,7,2,NULL),(2,1,3002,7,2,NULL),(3,1,5000,NULL,2,NULL),(4,2,3000,11,1,NULL),(5,2,3003,NULL,1,NULL),(6,3,3000,2,3,NULL),(7,3,4000,NULL,3,NULL),(8,3,6001,NULL,1,NULL),(9,3,6006,NULL,1,NULL),(10,4,3001,4,2,'descriptive audio'),(11,4,5001,NULL,1,NULL),(12,5,3000,6,2,NULL),(13,5,6006,NULL,1,NULL),(14,6,3000,7,5,'assistive listening'),(15,6,5002,NULL,1,NULL),(16,6,6000,NULL,1,NULL),(17,6,6009,NULL,1,NULL),(18,7,3000,8,2,'handicap'),(19,7,5000,NULL,1,NULL),(20,8,3000,1,1,NULL),(21,8,4004,NULL,1,NULL),(22,9,3000,12,2,NULL),(23,9,3003,NULL,2,NULL),(24,9,5002,NULL,1,NULL),(25,10,3000,1,2,'descriptive audio'),(26,10,3002,1,1,NULL),(27,10,4003,NULL,1,NULL),(28,10,6001,NULL,1,NULL),(29,11,3000,2,2,NULL),(30,11,5000,NULL,1,NULL),(31,12,3001,3,2,'assistive listening'),(32,12,4006,NULL,2,NULL),(33,13,3000,9,6,NULL),(34,13,6001,NULL,1,NULL),(35,13,6005,NULL,1,NULL),(36,13,6009,NULL,1,NULL),(37,14,3000,14,3,NULL),(38,14,4004,NULL,2,NULL),(39,14,5002,NULL,1,NULL),(40,15,3000,13,2,'descriptive audio'),(41,15,3002,13,1,NULL),(42,15,6004,NULL,1,NULL),(43,15,6005,NULL,1,NULL),(44,16,3000,4,1,NULL),(45,16,5002,NULL,1,NULL),(46,17,3000,11,2,NULL),(47,17,3003,NULL,2,NULL),(48,18,3000,1,3,'descriptive audio'),(49,18,3002,1,2,NULL),(50,19,3000,9,4,NULL),(51,19,4000,NULL,1,NULL),(52,19,4003,NULL,1,NULL),(53,19,6000,NULL,1,NULL),(54,19,6007,NULL,1,NULL),(55,20,3001,3,2,'handicap'),(56,20,3002,3,1,NULL),(57,20,5000,NULL,1,NULL),(58,21,3000,7,2,NULL),(59,21,4002,NULL,2,NULL),(60,21,6002,NULL,1,NULL),(61,21,6005,NULL,1,NULL),(62,22,3000,2,3,NULL),(63,22,3001,2,2,NULL),(64,22,3002,2,2,NULL),(65,22,4006,NULL,2,NULL),(66,22,5002,NULL,2,NULL),(67,23,3000,11,4,NULL),(68,23,3003,NULL,4,NULL),(69,24,3000,12,2,NULL),(70,24,3003,NULL,2,NULL),(71,24,4005,NULL,1,NULL),(72,24,6007,NULL,2,NULL),(73,25,3000,8,1,NULL),(74,25,5000,NULL,1,NULL),(75,26,3000,4,2,NULL),(76,26,4006,NULL,2,NULL),(77,26,6001,NULL,1,NULL),(78,27,3000,1,3,NULL),(79,27,3004,NULL,3,NULL),(80,28,3000,6,1,NULL),(81,28,3002,6,2,NULL),(82,28,3004,NULL,3,NULL),(83,28,4005,NULL,1,NULL),(84,28,5002,NULL,1,NULL),(85,29,3000,11,2,'assistive listening'),(86,29,3003,NULL,2,NULL),(87,29,4007,NULL,1,NULL),(88,30,3000,1,2,NULL),(89,30,3002,1,3,NULL),(90,30,4006,NULL,2,NULL),(91,30,5002,NULL,1,NULL),(92,31,3000,17,3,NULL),(93,31,3002,17,1,NULL),(94,31,3004,NULL,4,NULL),(95,32,3000,21,5,'descriptive audio'),(96,32,6000,NULL,1,NULL),(97,32,6001,NULL,1,NULL),(98,32,6008,NULL,2,NULL),(99,33,3000,28,2,'handicap'),(100,33,3003,NULL,2,NULL),(101,33,5000,NULL,1,NULL),(102,34,3000,23,4,NULL),(103,34,4005,NULL,2,NULL),(104,35,3000,15,1,NULL),(105,35,3004,NULL,1,NULL),(106,36,3000,22,2,NULL),(107,36,3002,22,2,NULL),(108,36,4007,NULL,3,NULL),(109,36,5002,NULL,1,NULL),(110,37,3001,15,3,NULL),(111,37,3004,NULL,3,NULL),(112,37,4006,NULL,3,NULL),(113,37,5001,NULL,1,NULL),(114,38,3000,16,5,NULL),(115,38,3004,NULL,5,NULL),(116,39,3000,19,2,'handicap'),(117,39,3002,19,2,'handicap'),(118,40,3000,20,1,NULL),(119,40,4006,NULL,1,NULL),(120,40,5000,NULL,1,NULL),(121,41,3000,18,5,NULL),(122,41,3004,NULL,5,NULL),(123,41,4005,NULL,2,NULL),(124,41,6001,NULL,1,NULL),(125,41,6002,NULL,1,NULL),(126,41,6004,NULL,2,NULL),(127,42,3000,26,3,NULL),(128,42,3003,NULL,3,NULL),(129,43,3000,25,1,NULL),(130,43,3003,NULL,1,NULL),(131,43,4006,NULL,1,NULL),(132,43,5001,NULL,1,NULL),(133,44,3000,15,2,NULL),(134,44,3004,NULL,2,NULL),(135,45,3000,19,3,NULL),(136,45,5002,NULL,1,NULL),(137,46,3000,16,2,'descriptive audio'),(138,46,3002,16,2,NULL),(139,47,3000,23,3,NULL),(140,47,4005,NULL,1,NULL),(141,47,5002,NULL,1,NULL),(142,47,6001,NULL,1,NULL),(143,48,3000,27,1,NULL),(144,48,3003,NULL,1,NULL),(145,48,4005,NULL,1,NULL),(146,49,3001,16,2,NULL),(147,49,3002,16,3,'handicap'),(148,49,5002,NULL,2,NULL),(149,50,3000,25,4,NULL),(150,50,3003,NULL,4,NULL),(151,50,4006,NULL,4,NULL),(152,50,5002,NULL,2,NULL),(153,51,3000,22,1,NULL),(154,51,4000,NULL,1,NULL),(155,51,5000,NULL,1,NULL),(156,52,3000,18,3,NULL),(157,52,3004,NULL,3,NULL),(158,52,4004,NULL,3,NULL),(159,52,5000,NULL,3,NULL),(160,53,3000,20,2,'descriptive audio'),(161,54,3000,23,2,NULL),(162,54,3004,NULL,2,NULL),(163,54,4005,NULL,1,NULL),(164,55,3000,26,4,NULL),(165,55,3003,NULL,4,NULL),(166,55,4006,NULL,4,NULL),(167,55,5000,NULL,3,NULL),(168,55,6004,NULL,1,NULL),(169,56,3000,15,3,NULL),(170,56,3004,NULL,3,NULL),(171,56,5002,NULL,2,NULL),(172,57,3000,17,1,NULL),(173,57,4000,NULL,1,NULL),(174,57,6006,NULL,1,NULL),(175,58,3000,28,2,NULL),(176,58,3002,28,2,'handicap'),(177,58,3003,NULL,4,NULL),(178,58,4006,NULL,4,NULL),(179,58,5000,NULL,2,NULL),(180,59,3000,19,2,NULL),(181,59,4002,NULL,1,NULL),(182,59,6002,NULL,1,NULL),(183,60,3000,16,4,NULL),(184,60,3002,16,2,NULL),(185,60,4005,NULL,2,NULL),(186,60,6001,NULL,1,NULL),(187,60,6004,NULL,1,NULL),(188,61,3000,33,2,'assistive listening'),(189,61,6000,NULL,1,NULL),(190,62,3000,35,1,NULL),(191,63,3000,32,4,NULL),(192,63,5002,NULL,1,NULL),(193,63,6003,NULL,2,NULL),(194,64,3000,32,3,NULL),(195,65,3000,32,2,NULL),(196,66,3000,34,2,NULL),(197,67,3000,36,1,NULL),(198,67,4004,NULL,1,NULL),(199,68,3001,31,2,'handicap'),(200,69,3000,32,3,NULL),(201,69,3001,31,2,NULL),(202,69,3002,36,5,NULL),(203,70,3000,33,1,NULL),(204,71,3000,43,2,NULL),(205,71,4005,NULL,1,NULL),(206,73,3001,44,1,NULL),(207,74,3001,42,1,NULL),(208,75,3000,53,3,NULL),(209,75,3002,53,2,NULL),(210,75,6000,NULL,2,NULL),(211,76,3000,37,2,NULL),(212,77,3000,39,1,NULL),(213,78,3001,39,1,NULL),(214,79,3000,45,2,NULL),(215,79,3003,NULL,2,NULL),(216,79,6009,NULL,1,NULL),(217,80,3000,42,3,'assistive listening'),(218,81,3000,42,1,NULL),(219,82,3001,44,2,'handicap'),(220,82,4002,NULL,2,NULL),(221,83,3000,53,1,NULL),(222,84,3000,54,2,NULL),(223,85,3000,47,3,NULL),(224,85,3003,NULL,3,NULL),(225,85,4005,NULL,1,NULL),(226,86,3000,56,1,NULL),(227,87,3000,62,2,NULL),(228,87,6000,NULL,1,NULL),(229,87,6001,NULL,1,NULL),(230,87,6008,NULL,1,NULL),(231,88,3000,57,2,NULL),(232,88,3003,NULL,2,NULL),(233,88,5000,NULL,1,NULL),(234,89,3000,61,3,'descriptive audio'),(235,89,4005,NULL,3,NULL),(236,90,3000,68,2,NULL),(237,90,3004,NULL,2,NULL),(238,91,3000,65,2,NULL),(239,92,3002,67,1,NULL),(240,92,4007,NULL,1,NULL),(241,92,5002,NULL,2,NULL),(242,93,3001,56,2,NULL),(243,93,3004,NULL,2,NULL),(244,93,4006,NULL,2,NULL),(245,93,5001,NULL,1,NULL),(246,94,3000,60,3,NULL),(247,94,5002,NULL,1,NULL),(248,95,3000,56,3,'handicap'),(249,95,3003,NULL,3,NULL),(250,95,4007,NULL,1,NULL),(251,96,3000,66,4,NULL),(252,97,3002,55,1,NULL),(253,97,4006,NULL,1,NULL),(254,97,5002,NULL,1,NULL),(255,98,3000,60,7,NULL),(256,99,3002,62,1,NULL),(257,99,3004,NULL,1,NULL),(258,100,3000,65,2,NULL),(259,101,6000,NULL,1,NULL),(260,102,6001,NULL,1,NULL),(261,102,6008,NULL,1,NULL),(262,103,3000,58,4,'assistive listening'),(263,103,3003,NULL,4,NULL),(264,104,3001,67,3,NULL),(265,105,3000,67,4,NULL),(266,106,3000,61,2,NULL);
GO