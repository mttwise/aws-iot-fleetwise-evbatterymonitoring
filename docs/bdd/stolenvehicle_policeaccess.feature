
Feature: Police API consumption for vehicle tracking

Scenario: Police consume API for vehicle location and speed
  Given the vehicle is in tracking mode
  And the police have access to the vehicle tracking API
  When the police request the vehicle's location and speed
  Then the API should provide the current location and speed of the vehicle