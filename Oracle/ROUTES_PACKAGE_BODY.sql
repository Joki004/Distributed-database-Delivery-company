CREATE OR REPLACE
PACKAGE BODY ROUTES_PACKAGE AS

  PROCEDURE INSERT_ROUTE (
    RouteName VARCHAR2,
    SourceWarehouseID NUMBER,
    DestinationWarehouseID NUMBER,
    AssignedEmployeeID NUMBER,
    Cost NUMBER,
    Time NUMBER,
    Distance NUMBER
  ) AS
  BEGIN
    BEGIN
    INSERT INTO Route (
      RouteID,
      RouteName,
      SourceWarehouseID,
      DestinationWarehouseID,
      AssignedEmployeeID,
      Cost,
      Time,
      Distance
    ) VALUES (
      seq_route_id.NEXTVAL,
      RouteName,
      SourceWarehouseID,
      DestinationWarehouseID,
      AssignedEmployeeID,
      Cost,
      Time,
      Distance
    );
    END;
  END INSERT_ROUTE;

END ROUTES_PACKAGE;
