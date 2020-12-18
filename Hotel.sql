CREATE DATABASE Hotel
--
USE Hotel

CREATE TABLE Hotels (
	HotelId int IDENTITY(1,1) PRIMARY KEY,
	Name varchar(100) NOT NULL,
	City varchar(100) NOT NULL UNIQUE(Name, City),
	Rating int NOT NULL CHECK(Rating BETWEEN 1 AND 5)
);

CREATE TABLE Rooms (
	RoomId int IDENTITY(1,1) PRIMARY KEY,
	HotelId int FOREIGN KEY REFERENCES Hotels(HotelId) NOT NULL,
	Number int NOT NULL UNIQUE(HotelId, Number),
	Category varchar(50) CHECK(Category IN ('Standard','Studio','Suite','President')) NOT NULL,
	Price int NOT NULL CHECK(Price>0),
	Capacity int NOT NULL CHECK(Capacity>0),
	Story int NOT NULL CHECK(Story>=0)
);

CREATE TABLE Employees (
	EmployeeID int IDENTITY(1,1) PRIMARY KEY,
	FirstName varchar(100) NOT NULL,
	LastName varchar(100) NOT NULL,
	HotelId int FOREIGN KEY REFERENCES Hotels(HotelId) UNIQUE(FirstName, LastName, HotelId),
	Gender int CHECK(Gender IN (0,1,2,9)) NOT NULL,  --ISO/IEC 5218
	Job varchar(30) CHECK(Job IN ('Receptionist','Cleaner', 'Service')),
);

CREATE TABLE Visitors (
	VisitorID int IDENTITY(1,1) PRIMARY KEY,
	FirstName varchar(100) NOT NULL,
	LastName varchar(100) NOT NULL,
	Gender int CHECK(Gender IN (0,1,2,9)) NOT NULL,
	PIN varchar(11) NOT NULL CHECK(ISNUMERIC(PIN) = 1) UNIQUE
);

CREATE TABLE Purchases (
	PurchaseId int IDENTITY(1,1) PRIMARY KEY,
	CustomerId int FOREIGN KEY REFERENCES Visitors(VisitorId),
	TransactionDate datetime2 NOT NULL,
	Price int NOT NULL CHECK(Price>=0),
	RoomId int FOREIGN KEY REFERENCES Rooms(RoomId),
	Board varchar(10) NOT NULL CHECK(Board IN('None','Half','Full')),
	StartTime datetime NOT NULL, --u slucaju da se trazilo vrijeme boravka za svaku osobu a ne rezervaciju,
	EndTime datetime NOT NULL, --ovo bih samo prebacio u visits
	Duration AS DATEDIFF(hh, StartTime, EndTime),
);

ALTER TABLE Purchases
ADD CONSTRAINT TimeOrderCheck CHECK(EndTime>StartTime);

CREATE TABLE Visits (
	VisitorId int FOREIGN KEY REFERENCES Visitors(VisitorId),
	PurchaseId int FOREIGN KEY REFERENCES Purchases(PurchaseId),
	CONSTRAINT VisitId PRIMARY KEY(VisitorId, PurchaseId)
);

GO
CREATE TRIGGER DeleteVisits
ON Purchases
INSTEAD OF DELETE
AS 
BEGIN
DELETE FROM Visits
WHERE PurchaseId IN (SELECT deleted.PurchaseId FROM deleted)
DELETE FROM Purchases
WHERE PurchaseId IN (SELECT deleted.PurchaseId FROM deleted)
END

--

INSERT INTO Hotels(Name, City, Rating) VALUES
('Elara', 'Las Vegas', 5),
('French Quarter', 'Charleston', 2),
('Lancaster', 'Houston', 1),
('Trump', 'Las Vegas', 4),
('Emma', 'San Antonio', 3),
('Clermont', 'Atlanta', 5),
('Langham', 'Chicago', 5);

INSERT INTO Rooms(HotelId, Number, Category, Price, Capacity, Story) VALUES
(1, 100, 'Standard', 330, 3, 1),
(1, 102, 'Suite', 857, 5, 1),
(1, 170, 'President', 1033, 2, 1),
(1, 201, 'Studio', 170, 1, 2),
(1, 209, 'Standard', 419, 2, 2),
(1, 311, 'President', 1099, 2, 3),
(1, 425, 'Suite', 1500, 4, 4),
(2, 201, 'Studio', 111, 1, 3),
(2, 101, 'Standard', 604, 6, 2),
(2, 351, 'Standard', 384, 3, 4),
(2, 307, 'Standard', 454, 2, 4),
(2, 308, 'Standard', 454, 3, 4),
(3, 802, 'Suite', 2000, 3, 6),
(4, 502, 'Suite', 4050, 7, 5),
(4, 488, 'Suite', 444, 3, 4),
(5, 112, 'Suite', 3555, 6, 1),
(5, 131, 'Suite', 2094, 5, 1),
(6, 155, 'Suite', 1555, 4, 1),
(4, 142, 'President', 2000, 3, 1),
(7, 355, 'President', 1000, 3, 3),
(7, 111, 'President', 4400, 5, 1),
(3, 202, 'Studio', 602, 1, 2),
(3, 404, 'Studio', 702, 1, 4);

INSERT INTO Employees(FirstName, LastName, HotelId, Gender, Job) VALUES
('Tom', 'Hanks', 1, 1, 'Cleaner'),
('Taylor', 'Swift', 2, 2, 'Cleaner'),
('Brad', 'Pitt', 2, 1, 'Receptionist'),
('Julia', 'Roberts', 2, 2, 'Service'),
('Dwayne', 'Johnson', 3, 1, 'Receptionist'),
('Madonna', 'Ciccone', 3, 2, 'Receptionist'),
('Will', 'Smith', 4, 1, 'Service'),
('Jennifer', 'Lopez', 4, 2, 'Cleaner'),
('Marques', 'Brownlee', 4, 1, 'Receptionist'),
('Stefani', 'Germanotta', 4, 2, 'Cleaner'),
('Hank', 'Green', 5, 1, 'Receptionist'),
('Alec', 'Watson', 4, 1, 'Cleaner');

INSERT INTO Visitors(FirstName,LastName, Gender, PIN) VALUES
('Walter', 'Lewin', 1, '0031239654'),
('Tom', 'Scott', 1, '18205481298'),
('Joel', 'Yliluoma', 1, '75191870904'),
('Carrie', 'Philbin', 2, '05910068039'),
('Arun', 'Maini', 1, '87625413257'),
('Steve', 'Mould', 1, '34758078503'),
('Toby', 'Hendy', 2, '95051986319'),
('Brady', 'Haran', 1, '75654809447'),
('Matt', 'Parker', 1, '05827577155'),
('Mike', 'Pound', 1, '01375456321'),
('Simone', 'Giertz', 2, '88542273698'),
('Yan', 'Chernikov', 1, '77644593751'),
('Sabine', 'Hossenfelder', 2, '58736207043'),
('James', 'Grimes', 1, '49764313880');

INSERT INTO Purchases(CustomerId, TransactionDate, Price, RoomId, Board, StartTime, EndTime) VALUES
(1, '2019-04-11', 5001, 2, 'Half', '2019-05-12','2019-05-14'),
(3, '2019-05-07', 3091, 4, 'Full', '2019-05-12','2019-05-17'),
(7, '2019-08-03', 4392, 17, 'None', '2019-08-07','2019-08-10'),
(4, '2020-02-23', 6044, 13, 'None', '2020-02-24','2020-02-26'),
(10, '2020-05-17', 4442, 10, 'None', '2020-05-22','2020-05-24'),
(12, '2020-06-29', 1999, 7, 'Half', '2020-06-30','2020-07-02'),
(9, '2020-07-15', 2011, 11, 'Full', '2020-07-17','2020-07-22'),
(14, '2020-10-01', 3020, 5, 'Half', '2020-10-18','2020-10-22'),
(13, '2020-12-15', 2011, 11, 'Full', '2020-12-15','2021-01-12'),
(13, '2020-12-03', 955, 12, 'None', '2020-12-16','2021-01-02'),
(2, '2020-12-01', 3020, 5, 'Half', '2020-12-04','2020-12-30'),
(5, '2021-12-15', 2041, 8, 'Full', '2021-12-15','2022-01-12'),
(6, '2021-12-03', 935, 9, 'None', '2021-12-16','2022-01-02'),
(7, '2022-12-01', 2020, 10, 'Half', '2022-12-04','2023-12-30');


INSERT INTO Visits(VisitorId, PurchaseId) VALUES
(1,1),
(4,1),
(12,1),
(11,1),
(3,2),
(7,3),
(4,4),
(5,4),
(10,5),
(12,6),
(2,6),
(3,6),
(9,7),
(14,8),
(11,8),
(13,9),
(2,10),
(5,10),
(14,11),
(11,12),
(13,12),
(2,13),
(5,13);



SELECT * FROM Rooms WHERE HotelId = (SELECT HotelId FROM Hotels WHERE Name = 'Elara') ORDER BY Number ASC;

SELECT * FROM Rooms WHERE Number LIKE '1%';

SELECT FirstName, LastName FROM Employees WHERE HotelId = 4 AND JOB = 'Cleaner' AND Gender=2;

SELECT * FROM Purchases WHERE TransactionDate >= '2020-12-01' AND Price>1000;

SELECT Visitors.VisitorId, Visitors.FirstName, Visitors.LastName, Visitors.Gender, Visitors.PIN,
Purchases.RoomId, Purchases.Board, Purchases.StartTime, Purchases.EndTime, Purchases.Duration AS DurationInHours
FROM Visits
INNER JOIN Visitors ON Visitors.VisitorID = Visits.VisitorId
INNER JOIN Purchases ON Purchases.PurchaseId = Visits.PurchaseId
WHERE (GETDATE() BETWEEN StartTime AND EndTime);

DELETE FROM Purchases
WHERE StartTime < '2020-12-1'; --DELETES MOST VISITS 

UPDATE Rooms
SET Capacity = 4
WHERE HotelId = 2 AND Capacity = 3;

SELECT Visitors.VisitorId, Visitors.FirstName, Visitors.LastName, Visitors.Gender, Visitors.PIN,
Purchases.RoomId, Purchases.Board, Purchases.StartTime, Purchases.EndTime, Purchases.Duration AS DurationInHours
FROM Visits
INNER JOIN Visitors ON Visitors.VisitorID = Visits.VisitorId
INNER JOIN Purchases ON Purchases.PurchaseId = Visits.PurchaseId
WHERE RoomId = 5
ORDER BY Duration ASC;

SELECT Visitors.VisitorId, Visitors.FirstName, Visitors.LastName, Visitors.Gender, Visitors.PIN,
Purchases.RoomId, Purchases.Board, Purchases.StartTime, Purchases.EndTime, Purchases.Duration AS DurationInHours
FROM Visits
INNER JOIN Visitors ON Visitors.VisitorID = Visits.VisitorId
INNER JOIN Purchases ON Purchases.PurchaseId = Visits.PurchaseId
WHERE (RoomId IN (SELECT RoomId FROM Rooms WHERE HotelId=2)) AND (Board = 'Half' OR Board = 'Full');

UPDATE TOP(2) Employees
SET Job = 'Receptionist'
WHERE Job = 'Service';