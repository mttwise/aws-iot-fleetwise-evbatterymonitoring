# 4. Usage of Smart Battery Manager for CMS

Date: 2023-04-11

## Status

Accepted

## Context

One of the core capabilities of Connected Mobility Solutions (CMS) is
EV Battery Health Prediction. The prototyping team has developed a
serverless and event-driven solution named
[Smart Battery Manager (SBM)](https://demo-factory.corp.amazon.com/app/browse/smart-battery-manager/)
using:

- AWS AppSync - Serverless GraphQL API
- AWS Forecast - Create time series dataset, train forecasting models,
  generate forecasts based on trained model
- AWS Lambda - Serverless compute to service APIs
- AWS Glue - Run ETL functions on training and test datasets
- AWS EventBridge - Event-driven execution of lambda functions
- AWS S3 - Read and write dataset, deploy UI assets
- AWS DynamoDB - Store state of different pipeline stages
- AWS Cognito - Access management

SBM embodies much of the technical tenets that CMS is built on:
serverless compute, independently deployable and usable module, low cost
at rest, and highly scalable. The architecture of SBM conforms with the
goals of CMS, and this would not change if it were refactored with these
tenets in mind.

SBM uses TypeScript and AngularJS whereas CMS uses Python and React.
While not required to be aligned, effort should be taken to convert
SBM to match CMS technologies.

If CMS were a library, then the tech stack used by the multiple different
modules within CMS would be of little significance. However, CMS is an
application template for developers from OEMs and customers to build upon.
It is imperative to maintain consistency across the different CMS modules
for our team and customers to be able to build upon them and iterate changes
with minimal friction. The SBM codebase is of a manageable size in its
current form and it can be rewritten to conform with the tech stack of CMS.

## Decision

1. Create a new CMS module: `Cms-ev-battery-health-on-aws`.
2. Rewrite the infrastructure CDK code in Python3. Broadly follow the
   SBM architecture with minor changes required to conform with other
   CMS modules.
3. Rewrite the UI in React and make it part of the
   `Cms-portal-on-aws` repository.
4. Create a data adapter for VSS data stored in S3 in json and Parquet formats
   to convert it to a csv which is the preferred format for AWS Forecast
5. Implement additional event based rules to populate dashboard items such as
   state of charge, charging duration, current, voltage and temperature of the
   battery. Establish the required cadence at which this information needs to be
   updated on the dashboard. Dashboard items which require historical data
   such as time since last charged to populate should be handled in addition to
   static data that can be obtained from VSS.
6. AWS Forecast is an AutoML framework which decides the appropriate algorithm to
   use based on the dataset. This should be implemented first and in the future,
   based on customer needs, provide functionality for customers to import their
   own models to use for forecasting.

## Consequences

- Rewriting SBM as a CMS module leads to taking full ownership of
  the solution. This implies that the onus is upon the CMS team
  to ensure that the solution conforms with the tenets of CMS and
  AWS Publishing standards.
- Using the bulk of Smart Battery Manager's architecture with data
  ingestion capabilities from CMS connect and store module should
  save us time on design phase.
- Implementing additional functionality to populate the dashboard
  with real data from VSS in place of mock data used by SBM requires
  additional development effort.
- SBM does not have unit test coverage at all. Utilizing SBM, we can
  use the existing CDK infrastructure to avoid starting from scratch,
  however, converting the code from Typescript to Python will take
  considerable development effort.
- Implementing the battery health dashboard UI components showcasing
  various battery parameters is a low effort task. However,
  implementing UI for the ML Operations stack consisting of dataset
  management, retraining forecasting model and managing user profiles
  (developer, fleet operator) would require considerable development effort.
