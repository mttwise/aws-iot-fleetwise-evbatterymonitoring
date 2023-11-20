# 11. SSM Parameter naming convention for inter-module dependencies

Date: 2023-07-11

## Status

Accepted

Extends [3. CMS Naming Conventions](0003-cms-naming-conventions.md)

## Context

One of the core tenets of CMS is that each module is independent and functional on
its own. When multiple modules are deployed, the dependencies between them are
configured via SSM Parameters. The SSM parameters act as inputs that configure a
given module. Lets say that module A deploys a resource A_R1 and module B depends on
the resource A_R1 for its deployment. To comply with the tenet of modularity,
module B should not be dependent on module A being deployed, rather it depends on the
resource A_R1. The source of the resource A_R1 can be module A or any other source that
the customer has previously defined.

Earlier, the SSM parameter naming convention was defined as /`stage-name`/`stack-name`/`parameter-name`.
This naming convention does not work for SSM Parameters that define inter-module resource dependencies
because it contains the `stack-name` which implies that the source of the resource is `stack-name`.
Therefore, a new naming convention is required for this use case.

## Decision

SSM Parameters that define inter-module dependencies should follow the naming convention given below:

/`stage-name`/cms/`resource-prefix`/`resource-name`-`resource-attribute`

Here, `stage-name` stands for whether the module is being deployed in `dev` or `prod` stages.
`resource-prefix` is used to specify additional context to the resource (e.g the S3 bucket storing
the VSS telemetry data can have a `resource-prefix` named `telemetry`). `resource-name` should specify
what type of a resource it is and what service it belongs to (e.g specify whether it is a S3 bucket,
DynamoDB table). `resource-attribute` should specify which attribute of the resource is being stored
as an SSM parameter (e.g name, arn, url, policy name).

For example, the SSM parameter for the ARN of the S3 bucket storing the VSS telemtry data in a dev
environment should be named: `/dev/cms/telemetry/vss-data-storage-bucket-arn`.

## Consequences

Change the SSM parameter names that define inter-module resource dependencies in all CMS modules.
