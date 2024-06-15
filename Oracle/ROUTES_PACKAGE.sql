CREATE OR REPLACE PACKAGE ROUTES_PACKAGE AS 
  PROCEDURE INSERT_ROUTE (
    RouteName VARCHAR2,
    SourceWarehouseID NUMBER,
    DestinationWarehouseID NUMBER,
    AssignedEmployeeID NUMBER,
    Cost NUMBER,
    Time NUMBER,
    Distance NUMBER
  );
END ROUTES_PACKAGE;

