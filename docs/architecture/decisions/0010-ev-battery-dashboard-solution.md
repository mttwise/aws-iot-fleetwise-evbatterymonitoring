# 10. EV Battery Dashboard Solution

Date: 2023-07-06

## Status

Accepted

## Context

The EV Battery Health module ingests telemetric battery data, and must display and interact with that data
using a prebuilt dashboard solution.

The dashboard should have the ability to display a single data attribute (e.g. the current value of a battery's
remaining lifespan) for a single vehicle at both a time instance and range - meaning it should be capable of displaying
past trends as well as future forecasts for the given attribute.

Future requirements could include support for comparison of a single data type from multiple vehicles in a single
time-series visualization, which is supported by both solutions considered.

Another key component of the dashboard is that it allows configuring alerts based on anomalies in historical,
recent, and forecasted data. More specifically, the dashboard should enable alert configuration based on: (1) past data
(e.g. the average value of attribute X over the last Y days has fallen below Z); (2) current data (e.g. an incoming
value of attribute X is below Z); and (3) forecast data (e.g. the incoming data changes the forecasted value of
attribute X at time T to be below Z). As a result, it is important that our chosen dashboard solution allows users to set
alerts with customized configurations. Alert configurations should support a variety of options such as thresholds,
severity, evaluation frequency, and alert delivery method. Additionally, depending on the required latency of alerts,
a short poll time (i.e. the time between dashboard data queries) is necessary. In the
context of our module, we have deemed a shorter poll time, in the span of seconds to minutes, as necessary to deliver
the best user experience.

Finally, the end-user should have the ability to dynamically configure the dashboard, including all
visualizations and alerts, without needing to redeploy the module. Although we are providing a default dashboard, our
choice of dashboard solution should offer a straightforward way for users to modify elements of the dashboard through a
UI, so that users can choose to display certain data and create alerts to cater to their use case.

We considered two AWS Managed Services for implementing a dashboard with these requirements.

### Option 1: AWS-Managed Grafana

Pros

Alerts are well-supported in AWS-managed Grafana, supporting configuration with a
myriad of supported alert notifiers
(<https://docs.aws.amazon.com/grafana/latest/userguide/old-alert-notifications.html>)
and data sources (<https://docs.aws.amazon.com/grafana/latest/userguide/alerts-overview.html>),
including SNS (our preferred notifier) and Athena (our preferred data source).

Also, with a minimum refresh time of 5 seconds, Grafana is able to update
more frequently than Quicksight and is better-suited for "real-time" data-monitoring, in terms of both alerts and
dashboard updates.

Grafana is also slightly cheaper than Quicksight in the early stages of production, costing $9 for each writer/month
and $5 for each active reader/month on the standard plan (writers are users with dashboard editing privileges, while
readers are provided view-only privileges). However, there is little available information regarding how
this pricing scales as the number of readers increases, compared to Quicksight's capacity-based plans, which offer
significant discounts for upfront commitments to more readers (see section on Option 2).

Cons:

While Grafana is more developer friendly than Quicksight (see Quicksight cons for details), more work is required
to setup visualizations, due to Grafana requiring SQL syntax for querying data. At the same time, Grafana does not have
any built-in machine learning capabilities that could help with understanding metrics data easily. It is a great tool
for creating charts, but leaves much of the burden on the developer and end-user to make sense of that output.

### Option 2: AWS Quicksight

Pros:

Quicksight's main selling point over Grafana are its business analytics capabilities: the ability to receive generated
insights on data could make it significantly easier for the end-user to understand their data. This also lessens the
burden on the writer to provide means of analyzing data (e.g vehicle A's battery is deteriorating more
quickly than vehicle B's, due to X factor).

To enhance this data analysis process further, Quicksight offers Q, a language model that allows readers to directly
ask the model questions and receive insights from simple language queries. In addition to Q, Quicksight also applies
machine learning on top of data to produce forecasts.

Sharing dashboards with non-technical teams is also easier. In Grafana, every dashboard reader must be verified as a
registered, paying reader. However, Quicksight doesn't require the shared reader to be a paying reader, as long as the writer
turns on session capacity pricing mode, which will charge for the amount of time the shared reader spent viewing the
dashboard.

Cons:

In contrast to Grafana's 5 second minimum refresh time, Quicksight's minimum refresh time is an hour, making real-time
data monitoring and early-alerting impossible through Quicksight.

Alerts in Quicksight are also less configurable than those in Grafana. Quicksight only natively supports email alerts,
and alert configuration is also limited to threshold alerts, with parameters like notification frequency limited to
high-level options like "as frequently as possible", "daily", and "weekly".

Another area of concern for Quicksight is its lack of support for geospatial charts in non-US regions. While initial
specifications for the EV Battery module do not include visualizations on location data, this may be something we
are interested in exploring in the future, especially considering that geolocation is part of our data model.

Finally, given our need for configurable alerts, Quicksight's premium plan is the only viable pricing plan
for our use case. The premium plan is $18 per month per writer with annual subscription.
Readers are priced $0.30 per session with a cap of $5 per month (and consequent unlimited use). Writers in Quicksight
are $9 more per month than writers in Grafana; however, potential savings could come in the form of a large number
of readers who do not use enough sessions to reach the full $5 per-month fee that Grafana charges. It is also worth
mentioning that due to its capacity pricing plan, QS may be cheaper as the number of readers increases: at the most
extreme level, 1.6 million sessions is $258,000, which is $0.16/session. However, tacking on Quicksight Q is an additional
$250 / month for each user (reader or writer) on top of the additional cost of premium, making it very costly and
unlikely for our default offering to be built with Q enabled.

## Decision

Selected Option 1 : AWS-managed Grafana.

Ultimately, given the lower upfront cost of Grafana, as well as the increased flexibility it offers developers,
we've chosen to use Grafana as our primary dashboard solution.

Committing to Grafana keeps the door open on several requirements, including the possibility of low-latency
alerts and data refreshes, as well as compatability with notifiers like SNS.
Given Quicksight's massive, hour-long latency and lack of support for
alert notifiers, these requirements would be impossible to fulfill.

## Consequences

Committing to Grafana could be more expensive than Quicksight in the middle-long term, simply due to a lack of
scalable pricing plans.

Grafana is also quite limited in its ability to provide data insights and analysis. Committing to Grafana means
that we take on more of the burden to provide interpretable visualizations and insights for the end user.
