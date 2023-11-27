Feature: Sending commands to limit vehicle speed or prevent ignition

Scenario: Agent sends command to limit vehicle speed
  Given the vehicle is in tracking mode
  When the agent sends a command to limit the vehicle's speed
  Then the vehicle should not exceed the specified speed limit

Scenario: Agent sends command to prevent vehicle ignition
  Given the vehicle is in tracking mode
  And the vehicle is currently not ignited
  When the agent sends a command to prevent ignition
  Then the vehicle should not start until the command is revoked