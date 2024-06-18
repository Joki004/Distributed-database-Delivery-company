CREATE OR REPLACE
PACKAGE BODY ROUTES_PACKAGE AS

  PROCEDURE INSERT_ROUTE (
    RouteName VARCHAR2,
    SourceWarehouseID NUMBER,
    DestinationWarehouseID NUMBER,
    AssignedEmployeeID NUMBER,
    VehicleID NUMBER,
    Cost NUMBER,
    Time NUMBER,
    Distance NUMBER
  ) AS
  BEGIN
    BEGIN
    INSERT INTO Route (
      route_id,
      route_name,
      from_warehouse_id,
      to_warehouse_id ,
      assigned_employee_id,
      vehicle_id,
      cost,
      time,
      distance
    ) VALUES (
      seq_route_id.NEXTVAL,
      RouteName,
      SourceWarehouseID,
      DestinationWarehouseID,
      AssignedEmployeeID,
      VehicleID,
      Cost,
      Time,
      Distance
    );
    END;
  END INSERT_ROUTE;


    PROCEDURE INSERT_ROUTE_SCHEDULE (
        RouteID NUMBER,
        DepartureTime VARCHAR2,
        ArrivalTime VARCHAR2
      ) AS
      BEGIN
        INSERT INTO ROUTESCHEDULE (
          route_schedule_id,
          route_id,
          departure_time,
          arrival_time
        ) VALUES (
          seq_route_schedule_id.NEXTVAL,
          RouteID,
          DepartureTime,
          ArrivalTime
        );
      END INSERT_ROUTE_SCHEDULE;
END ROUTES_PACKAGE;
/