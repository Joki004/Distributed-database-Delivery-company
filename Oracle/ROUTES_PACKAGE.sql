CREATE OR REPLACE PACKAGE ROUTES_PACKAGE AS 
  PROCEDURE INSERT_ROUTE (
    RouteName VARCHAR2,
    SourceWarehouseID NUMBER,
    DestinationWarehouseID NUMBER,
    AssignedEmployeeID NUMBER,
    VehicleID NUMBER,
    Cost NUMBER,
    Time NUMBER,
    Distance NUMBER
    
  );
  
    PROCEDURE INSERT_ROUTE_SCHEDULE (
    RouteID NUMBER,
    DepartureTime VARCHAR2,
    ArrivalTime VARCHAR2
  );
END ROUTES_PACKAGE;
/
