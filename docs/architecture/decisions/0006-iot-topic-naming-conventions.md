# 6. IoT Topic Naming Conventions

Date: 2023-05-31

## Status

Accepted

Extension - Naming Conventions [3. CMS Naming Conventions](0003-cms-naming-conventions.md)

## Context

Topic naming is complex and requires thought and standards. Most of this decision is a
customized perspective of
[IoT Core's MQTT best practices guide](https://docs.aws.amazon.com/whitepapers/latest/designing-mqtt-topics-aws-iot-core/mqtt-design-best-practices.html).

What is required is a simple way to have modules publish and subscribe
to a topic while enumerating what type of data is being published.

The key enhancement here is the vehicle/simulated trigger and the
data/command trigger. Further enumerated values are likely to occur
on these two sections, while the remaining sections are fairly fixed.


## Decision

Full topic structure:

`/<solution>/<type>/<source>/<device identifier>/<sub device identifier>`

Solution:
- `cms`

Type:
- `data`
- `command`

Source:
- `vehicle`
- `simulated`

Identifiers are both reasonably unique.

Full example topic: `/cms/data/vehicle/unique_id/tcm_id`

Normal example topic: `/cms/data/vehicle/unique_id`

Command example: `/cms/command/vehicle/unique_id`

Simulator example: `/cms/data/simulated/unique_id/`

## Consequences

Code changes required to meet this standard are included along with
this document. Further adherence will be manually enforced.

Customer guidance should be written to both adhere to a similar
standard and to remove the `solution` prefix of this standard.
