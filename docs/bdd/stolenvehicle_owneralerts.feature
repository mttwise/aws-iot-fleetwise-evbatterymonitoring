Feature: Alerting owner when tracking mode is turned off

Scenario: Vehicle tracking mode is turned off
  Given the vehicle is in tracking mode
  When the agent turns off the tracking mode
  Then the vehicle owner should be notified that the vehicle has exited stolen vehicle tracking mode
