-- Drop tables if they already exist
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Employee CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Route CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Itinerary CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE ItineraryDetail CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

-- Create sequences for primary keys
CREATE SEQUENCE seq_employee_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_route_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_itinerary_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_itinerary_detail_id START WITH 1 INCREMENT BY 1 NOCACHE;
/

-- Create Employee table
CREATE TABLE Employee (
  EmployeeID NUMBER PRIMARY KEY,
  EmployeeName VARCHAR2(100) NOT NULL,
  Position VARCHAR2(100) NOT NULL
);
/
-- Create trigger for Employee table
CREATE OR REPLACE TRIGGER trg_employee_id
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
  SELECT seq_employee_id.NEXTVAL INTO :new.EmployeeID FROM dual;
END;
/
-- Create Route table
CREATE TABLE Route (
  RouteID NUMBER PRIMARY KEY,
  RouteName VARCHAR2(100) NOT NULL,
  SourceWarehouseID NUMBER NOT NULL,
  DestinationWarehouseID NUMBER NOT NULL,
  AssignedEmployeeID NUMBER NOT NULL,
  Cost NUMBER(10,2) NOT NULL,
  Time NUMBER(10,2) NOT NULL,
  Distance NUMBER(10,2) NOT NULL
);
/
-- Create trigger for Route table
CREATE OR REPLACE TRIGGER trg_route_id
BEFORE INSERT ON Route
FOR EACH ROW
BEGIN
  SELECT seq_route_id.NEXTVAL INTO :new.RouteID FROM dual;
END;
/
-- Create Itinerary table
CREATE TABLE Itinerary (
  ItineraryID NUMBER PRIMARY KEY,
  OrderID NUMBER NOT NULL,
  CreationDate DATE NOT NULL
);
/
-- Create trigger for Itinerary table
CREATE OR REPLACE TRIGGER trg_itinerary_id
BEFORE INSERT ON Itinerary
FOR EACH ROW
BEGIN
  SELECT seq_itinerary_id.NEXTVAL INTO :new.ItineraryID FROM dual;
END;
/
-- Create ItineraryDetail table
CREATE TABLE ItineraryDetail (
  ItineraryDetailID NUMBER PRIMARY KEY,
  ItineraryID NUMBER NOT NULL,
  RouteID NUMBER NOT NULL,
  StepNumber NUMBER NOT NULL,
  FromWarehouseID NUMBER NOT NULL,
  ToWarehouseID NUMBER NOT NULL,
  DepartureDate DATE NOT NULL,
  ArrivalDate DATE NOT NULL,
  Cost NUMBER(10,2) NOT NULL,
  Distance NUMBER(10,2) NOT NULL,
  Time NUMBER(10,2) NOT NULL,
  FOREIGN KEY (ItineraryID) REFERENCES Itinerary(ItineraryID),
  FOREIGN KEY (RouteID) REFERENCES Route(RouteID)
);
/
-- Create trigger for ItineraryDetail table
CREATE OR REPLACE TRIGGER trg_itinerary_detail_id
BEFORE INSERT ON ItineraryDetail
FOR EACH ROW
BEGIN
  SELECT seq_itinerary_detail_id.NEXTVAL INTO :new.ItineraryDetailID FROM dual;
END;
/
-- Select statements
SELECT * FROM ROUTE;
SELECT * FROM EMPLOYEE;
SELECT * FROM ITINERARY;
SELECT * FROM ITINERARYDETAIL;


COMMIT;
