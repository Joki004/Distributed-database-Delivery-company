-- Drop tables if they already exist
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Employee CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Route CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Itinerary CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE RouteSchedule CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

DROP SEQUENCE seq_employee_id;
DROP SEQUENCE seq_route_id;
DROP SEQUENCE seq_itinerary_id;
DROP SEQUENCE seq_route_schedule_id;
-- Create sequences for primary keys
CREATE SEQUENCE seq_employee_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_route_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_itinerary_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_route_schedule_id START WITH 1 INCREMENT BY 1 NOCACHE;
/

-- Create Employee table
CREATE TABLE Employee (
  employee_id NUMBER PRIMARY KEY,
  employee_name VARCHAR2(100) NOT NULL,
  position VARCHAR2(100) NOT NULL
);
/
-- Create trigger for Employee table
CREATE OR REPLACE TRIGGER trg_employee_id
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
  SELECT seq_employee_id.NEXTVAL INTO :new.employee_id FROM dual;
END;
/
-- Create Route table
CREATE TABLE Route (
  route_id NUMBER PRIMARY KEY,
  route_name VARCHAR2(100) NOT NULL,
  from_warehouse_id NUMBER NOT NULL,
  to_warehouse_id NUMBER NOT NULL,
  assigned_employee_id NUMBER NOT NULL,
  vehicle_id NUMBER,
  cost NUMBER(10,2) NOT NULL,
  time NUMBER(10,2) NOT NULL,
  distance NUMBER(10,2) NOT NULL
);
/
-- Create trigger for Route table
CREATE OR REPLACE TRIGGER trg_route_id
BEFORE INSERT ON Route
FOR EACH ROW
BEGIN
  SELECT seq_route_id.NEXTVAL INTO :new.route_id FROM dual;
END;
/
CREATE TABLE RouteSchedule (
  route_schedule_id NUMBER PRIMARY KEY,
  route_id NUMBER NOT NULL,
 departure_time VARCHAR2(5) NOT NULL,
  arrival_time VARCHAR2(5) NOT NULL,   
  CONSTRAINT fk_route FOREIGN KEY (route_id) REFERENCES Route(route_id)
);
-- Create trigger for Route table
CREATE OR REPLACE TRIGGER trg_route_schedule_id
BEFORE INSERT ON RouteSchedule
FOR EACH ROW
BEGIN
  SELECT seq_route_schedule_id.NEXTVAL INTO :new.route_schedule_id FROM dual;
END;
/
-- Create Itinerary table
CREATE TABLE Itinerary (
  itinerary_id NUMBER PRIMARY KEY,
  package_details_id NUMBER NOT NULL,
  route_id NUMBER NOT NULL,
  step_number NUMBER NOT NULL,
  departure_Date DATE NOT NULL,
  arrival_date DATE NOT NULL,
  FOREIGN KEY (route_id) REFERENCES Route(route_id)
);
/
-- Create trigger for Itinerary table
CREATE OR REPLACE TRIGGER trg_itinerary_id
BEFORE INSERT ON Itinerary
FOR EACH ROW
BEGIN
  SELECT seq_itinerary_id.NEXTVAL INTO :new.itinerary_id FROM dual;
END;
/

-- Select statements
SELECT * FROM ROUTE;
SELECT * FROM EMPLOYEE;
SELECT * FROM ITINERARY;
SELECT * FROM ROUTESCHEDULE;

DELETE FROM ITINERARY;


COMMIT;
