Feature: Placing a vehicle in tracking mode

Scenario: Agent places vehicle in tracking mode upon theft report
  Given the agent has received a police report ID from the vehicle owner
  And the vehicle is not already in tracking mode
  When the agent attempts to place the vehicle in tracking mode
  Then the vehicle should be successfully placed in tracking mode
  And the vehicle owner should be locked out of mobile and web applications for vehicle location services
  And the vehicle owner is notified that the vehicle is in stolen vehicle tracking mode





