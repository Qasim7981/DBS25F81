DROP DATABASE IF EXISTS TourAndTravelDB;
CREATE DATABASE TourAndTravelDB;
USE TourAndTravelDB;


CREATE TABLE Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Username VARCHAR(50) UNIQUE NOT NULL,
    Password VARCHAR(100) NOT NULL,
    Role ENUM('Admin','Staff') NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Users (FullName, Username, Password, Role) VALUES
('Admin User','admin','admin123','Admin'),
('Staff User','staff','staff123','Staff');

CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Phone VARCHAR(15),
    Email VARCHAR(100) UNIQUE,
    CNIC VARCHAR(15) UNIQUE,
    Address VARCHAR(255),
    Gender ENUM('Male','Female'),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Customers (FullName, Phone, Email, CNIC, Address, Gender) VALUES
('Ali Khan','03001234567','ali@gmail.com','35201-1111111-1','Lahore','Male'),
('Sara Ahmed','03007654321','sara@gmail.com','35201-2222222-2','Karachi','Female'),
('Usman Malik','03003334455','usman@gmail.com','35201-3333333-3','Islamabad','Male'),
('Ayesha Khan','03004445566','ayesha@gmail.com','35201-4444444-4','Lahore','Female');

CREATE TABLE Hotels (
    HotelID INT AUTO_INCREMENT PRIMARY KEY,
    HotelName VARCHAR(100),
    Location VARCHAR(100),
    StarRating INT CHECK (StarRating BETWEEN 1 AND 5),
    ContactNumber VARCHAR(20),
    CostPerNight DECIMAL(10,2)
);

INSERT INTO Hotels VALUES
(1,'Hunza Serena','Hunza',5,'0581-111111',15000),
(2,'Skardu Resort','Skardu',4,'0582-222222',12000),
(3,'Murree Hills','Murree',3,'0583-333333',8000);

CREATE TABLE Facilities (
    FacilityID INT AUTO_INCREMENT PRIMARY KEY,
    FacilityName VARCHAR(50)
);

INSERT INTO Facilities (FacilityName) VALUES
('Breakfast'),('Lunch'),('Dinner'),('Transport'),('Tour Guide');


CREATE TABLE Transport (
    TransportID INT AUTO_INCREMENT PRIMARY KEY,
    TransportType VARCHAR(50),
    Provider VARCHAR(100),
    Cost DECIMAL(10,2)
);

INSERT INTO Transport VALUES
(1,'Bus','Pak Travels',5000),
(2,'Flight','Air Pak',25000),
(3,'Jeep','Mountain Tours',12000);


CREATE TABLE TourGuides (
    GuideID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100),
    Phone VARCHAR(15),
    Language VARCHAR(50)
);
INSERT INTO TourGuides VALUES
(1,'Ali Raza','03001112233','Urdu'),
(2,'John Smith','03002223344','English');

CREATE TABLE TourPackages (
    PackageID INT AUTO_INCREMENT PRIMARY KEY,
    PackageName VARCHAR(100),
    Destination VARCHAR(100),
    DurationDays INT CHECK (DurationDays > 0),
    Price DECIMAL(10,2),
    AvailableSeats INT,
    Description TEXT
);
INSERT INTO TourPackages VALUES
(1,'Northern Tour','Hunza & Skardu',7,85000,30,'Complete northern areas tour'),
(2,'Murree Weekend','Murree',3,30000,40,'Weekend getaway');

CREATE TABLE PackageFacilities (
    PackageID INT,
    FacilityID INT,
    PRIMARY KEY (PackageID, FacilityID),
    FOREIGN KEY (PackageID) REFERENCES TourPackages(PackageID),
    FOREIGN KEY (FacilityID) REFERENCES Facilities(FacilityID)
);
INSERT INTO PackageFacilities VALUES
(1,1),(1,2),(1,3),(1,4),(1,5),
(2,1),(2,4);
CREATE TABLE PackageHotels (
    PackageHotelID INT AUTO_INCREMENT PRIMARY KEY,
    PackageID INT,
    HotelID INT,
    Nights INT,
    FOREIGN KEY (PackageID) REFERENCES TourPackages(PackageID),
    FOREIGN KEY (HotelID) REFERENCES Hotels(HotelID)
);
INSERT INTO PackageHotels VALUES
(1,1,1,3),
(2,1,2,3),
(3,2,3,2);

CREATE TABLE Bookings (
    BookingID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    PackageID INT,
    UserID INT,
    BookingDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    TravelDate DATE,
    SeatsBooked INT,
    TotalPrice DECIMAL(10,2),
    Status ENUM('Confirmed','Cancelled','Pending'),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (PackageID) REFERENCES TourPackages(PackageID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
INSERT INTO Bookings VALUES
(1,1,1,1,NOW(),'2026-01-05',2,170000,'Confirmed'),
(2,2,2,2,NOW(),'2026-02-10',3,90000,'Pending');

CREATE TABLE Payments (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    BookingID INT UNIQUE,
    AmountPaid DECIMAL(10,2),
    PaymentMethod ENUM('Cash','Card','Online'),
    PaymentStatus ENUM('Paid','Unpaid'),
    PaymentDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);
INSERT INTO Payments VALUES
(1,1,170000,'Card','Paid',NOW());

CREATE VIEW vw_PendingBookings AS
SELECT * FROM Bookings WHERE Status='Pending';
CREATE VIEW vw_TotalPayments AS
SELECT SUM(AmountPaid) AS TotalCollection FROM Payments;

DELIMITER $$
CREATE PROCEDURE GetAllCustomers()
BEGIN
    SELECT * FROM Customers;
END$$
CREATE PROCEDURE ConfirmBooking(IN bid INT)
BEGIN
    UPDATE Bookings SET Status='Confirmed' WHERE BookingID=bid;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_reduce_seats
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN
    UPDATE TourPackages
    SET AvailableSeats = AvailableSeats - NEW.SeatsBooked
    WHERE PackageID = NEW.PackageID;
END$$
DELIMITER ;
SELECT * FROM Customers;
SELECT * FROM TourPackages;
SELECT * FROM Bookings;
SELECT * FROM Payments;