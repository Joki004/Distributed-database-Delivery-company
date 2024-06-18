CREATE OR REPLACE PACKAGE BODY ITINERARY_PACKAGE AS
  PROCEDURE INSERT_ITINERARY(
    p_package_details_id IN NUMBER,
    p_route_id IN NUMBER,
    p_step_number IN NUMBER,
    p_departure_date IN DATE,
    p_arrival_date IN DATE
  ) AS
  BEGIN
    INSERT INTO ITINERARY (
      itinerary_id,
      package_details_id,
      route_id,
      step_number,
      departure_date,
      arrival_date
    ) VALUES (
      seq_itinerary_id.NEXTVAL,
      p_package_details_id,
      p_route_id,
      p_step_number,
      p_departure_date,
      p_arrival_date
    );
  END INSERT_ITINERARY;
END ITINERARY_PACKAGE;
/