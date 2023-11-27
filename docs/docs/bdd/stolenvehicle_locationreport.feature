Feature: Receiving vehicle data in tracking mode

Scenario: Service receives location, speed, and heading at a configurable rate
  Given the vehicle is in tracking mode
  When the service requests location, speed, and heading data
  Then the service should receive this data at the pre-configured rate