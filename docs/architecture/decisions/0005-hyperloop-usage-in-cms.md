# 5. Hyperloop Usage in CMS

Date: 2023-05-22

## Status

Accepted

## Context

AWS HyperLoop is a managed service to ingest and transform automotive data, which is proposed to be included as a part of the Connected Mobility Solution. Currently Hyperloop is only available in the eu-central-1 region.

The service consists of three major components:

 * Data Connector
   - The only data Connector implemented thus far is for Amazon Managed Streaming for Kafka.
 * Data Transformer
   - The data transformer can only be implemented using a custom Lambda.
 * Subscriptions
   - Subscriptions information could be sent either to AWS AppSync or Amazon Kinesis.

Our evaluation of the Milestone 5 beta release of Hyperloop revealed the following:

 * Adding Amazon Managed Streaming for Kafka into our design will generate an additional cost comparing to streaming data directly into the Kinesis Firehose Data stream, which is currently implemented in the CMS Connect and Store module.
 * Using Kafka as a middleman for data transformation has no added benefits for the current CMS design.
 * Streaming IoT core collected data directly into Kinesis Stream will not generate a cost when idle, which is in alignment with the solution tenets.
 * The most noticeable benefit of using AWS Hyperloop is generating AWS Appsync schemas for the transformed data; a later release of CMS will or may rely on well defined schemas.

## Decision

Hyperloop will not be used in 2023 releases of CMS.

In the upcoming 2023 release cycle, CMS will be leveraging its existing data ingestion path, where IoT Core is sending VSS data as JSON blobs into the Kinesis Firehose Data Stream for conversion into Apache Parquet format. Converted data is stored in S3 bucket. Data transformation is done inside the Firehose Data Stream with assistance of an AWS Glue table defining incoming data format.

## Consequences

No significant consequences of this decision.
