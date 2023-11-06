# 2. Backstage as the deployment platform

Date: 2023-03-21

## Status

Accepted

## Context

The Connected Mobility Solution on AWS requires a user friendly,
configurable, and extensible platform to deploy various modules
with interdependencies. These modules also are developed in a way
that they can be independently and solely deployed in a
separate method (cdk deploy, cloudformation template import, etc).

We have a strategic mission in the automotive space to help our
customers accelerate their ability to develop, deploy and evolve
their connected vehicle platforms and microservices to increase
their value. This in large part means bringing focus to the
experience of the developer and operators of the connected vehicle
platforms.

A great deal of research and focus in the wider marketplace has
demonstrated that proper organization and the adoption of
[Platform Engineering](https://www.puppet.com/resources/state-of-platform-engineering)
approaches are central to achieving the kind of high performanace
our customers are looking to achieve. Our own experience with
customers like Stellantis and
[Toyota](https://backstage.spotify.com/blog/adopter-spotlight-toyota/)
demonstrate the effectiveness of this approach in both embedded
and traditional software spaces. It is not the purpose of this
document to explain Platform Engineering and so we encourage
anyone not understanding it to start with the linked Puppet
report for further understanding.

As such, we are looking to deliver a solution for CMS that provides
the most foundational components in production ready state and gives
strong reference content for additional elements, while taking a
platform engineering approach that reduces friction for development,
testing, deployment and continuous improvement of the value generating
services as well as the processes around their delivery.

## Options Considered

- Backstage
- AC/DC
- Engineeing Workbench
- Shared Services Catalog
- Proton
- Build from Scratch

## Decision

Use [Backstage](https://backstage.io/docs/overview/what-is-backstage)
as the central deployment mechanism for the CMS modules.

The other offerings expect too much complexity and effort from developers,
and would require extensive training to enable customer to deploy
this solution. Each module utilizes CDK, but there isn't a CDK
feature to pull in disparate modules from a central location.
In addition, many other offerings lack the combination of features
and maturity that Backstage currently offers.

Engineering Workbench is much more applicable to embedded development,
and is well integrated with the tool chains and workflows that are common
in that space. We recognise a fair amount of overlap between the two,
especially commonality of purpose. That said, attempts to constrain
all software domains to the same tools often fail. Engineering
Workbench is also much lighter on features around documentation,
monitoring and the ability to bring in open source repositories,
proprietary and other types of code bases or project configurations.

Backstage offers a straightforward and strong path forward. It is
configurable, extensible, utilizes a plugin design, and reads a yaml
file from a remote respository to launch it. Since Backstage
is open source, we can also write the plugins in such
a way to handle the interdependency problems.

As for user friendly, most options fall short the most on this
constraint. Backstage, however, is already adopted in many
environments that CMS would be launched in.

We feel that upon the completion of AC/DC this decision may be
revisited and we are open to collaboration with the Industry Products
team working on this product.

Build from scratch in this instance, with so many available
options, does not make sense. The threshold of adoption and success
of a custom platform engineering solution are high enough to outright
prohibit this path.

## Consequences

Additional development is required to write the plugins and
reconfigure the modules to follow Backstage's format.

Customers will be directed to adopt Backstage. Documentation will
cover deploying the solution via CDK or Cloudformation templates
for the cases where Backstage cannot be used. The Solution Landing
page will not directly deploy the solution, but rather Backstage
with further steps to deploy the modules for this solution.

We will have to design and execute for customers that are already
using Backstage.

Integrating and leveraging Backstage does not provide any benefit
if we decide on a different path in the future. It is prescriptive and
non-transferable development efforts. This situation could change
if a new offering comes out that follows Backstage's plugin and
configuration standards.
