CREATE DATABASE Hotel

CREATE TABLE Hotels (
	HotelId int IDENTITY(1,1) PRIMARY KEY,
	Name varchar(100) NOT NULL,
	City varchar(100) NOT NULL,
	Rating int NOT NULL CHECK(Rating BETWEEN 1 AND 5)
)

CREATE TABLE Rooms (
	RoomId int IDENTITY(1,1) PRIMARY KEY,
	Number int NOT NULL,
	HotelId int FOREIGN KEY REFERENCES Hotels(HotelId) NOT NULL,
	Category varchar(50) CHECK(Category IN ('Standard','Studio','Suite','President')) NOT NULL,
	Price int NOT NULL,
	Capacity int NOT NULL,
	Story int NOT NULL
)

CREATE TABLE Visitors (
	VisitorID int IDENTITY(1,1) PRIMARY KEY,
	FirstName varchar(100) NOT NULL,
	LastName varchar(100) NOT NULL,
	Gender int CHECK(Gender IN (0,1,2,9)) NOT NULL, --ISO/IEC 5218
	PIN varchar(11) NOT NULL CHECK(ISNUMERIC(PIN) = 1) UNIQUE
)

CREATE TABLE Staff (
	PersonID int IDENTITY(1,1) PRIMARY KEY,
	FirstName varchar(100) NOT NULL,
	LastName varchar(100) NOT NULL,
	HotelId int FOREIGN KEY REFERENCES Hotels(HotelId),
	Gender int CHECK(Gender IN (0,1,2,9)) NOT NULL,
	Job varchar(30) CHECK(Job IN ('Receptionist','Cleaner', 'Service')),
)

CREATE TABLE Purchases (
	PurchaseId int IDENTITY(1,1) PRIMARY KEY,
	CustomerId int FOREIGN KEY REFERENCES Visitors(VisitorId),
	TransactionDate datetime2 NOT NULL,
	Price int NOT NULL,
	RoomId int FOREIGN KEY REFERENCES Rooms(RoomId),
	Board varchar(10) NOT NULL CHECK(Board IN('None','Half','Full')),
	StartTime datetime NOT NULL,
	EndTime datetime NOT NULL,
	Duration AS DATEDIFF(hh, StartTime, EndTime)
)

CREATE TABLE Visits (
	VisitorId int FOREIGN KEY REFERENCES Visitors(VisitorId),
	PurchaseId int FOREIGN KEY REFERENCES Purchases(PurchaseId),
	CONSTRAINT VisitId PRIMARY KEY(VisitorId, PurchaseId)
)
