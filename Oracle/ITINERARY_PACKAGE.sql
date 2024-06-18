CREATE OR REPLACE PACKAGE ITINERARY_PACKAGE AS
  PROCEDURE INSERT_ITINERARY(
    p_package_details_id IN NUMBER,
    p_route_id IN NUMBER,
    p_step_number IN NUMBER,
    p_departure_date IN DATE,
    p_arrival_date IN DATE
  );
END ITINERARY_PACKAGE;
/
