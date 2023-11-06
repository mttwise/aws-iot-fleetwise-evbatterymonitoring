# 7. CDK Parameterization Pattern

Date: 2023-06-07

## Status

Approved

## Context

Following the content of the [AWS CDK Best Practices Guide](https://docs.aws.amazon.com/cdk/v2/guide/best-practices.html),
it is considered an anti-pattern to use environment variables in any form within CDK scripts.

Currently, environment variables are used to feed values to various modules as parameters within the CDK scripts.

This ADR addresses the following issues:

1. CDK Environment variables are only resolved at `cdk synth` time, and therefore create a dependency on the settings
   on the system that builds the cdk code. Effectively any environment variables become hardcoded values in
   the transpiled CFN scripts.
2. The way the parameters are passed down to nested and module stacks requires they be passed into the 'default' property.
   This prevents any changes/upgrades after the initial deployment.

There are 2 options for replacing the environment variables, but each option will change the support and behavior for
deployments going forward significantly.

### Option 1: Use CDK Context to pass in values at runtime

This is the preferred mechanism for "cdk first" deployments as it allows developers to keep state in git for their deployments.
It is recommended by the best practices to check in cdk.context.json files to keep in sync with a deployment,
but we should not be checking in this file as we are publishing a solution and not the users of said solution.
Instead, there will be a Makefile that devs can run to generate cdk.context.json.

However, this effectively locks out the ability to deploy with native Cloudformation.  Users wishing to deploy CMS will
not be able to utilize a one-click approach.
They will instead have to fork the git repo, create a tailored context file and then deploy. This adds a slight barrier
for entry for non-developers being able to deploy and test CMS.

Pros:

* Can continue to fully utilize CDK specific functionalities (e.g. cdk bootstrap provided CFN custom resources) such as
  ACM Certificate generation.
* Can use generator script to aggregate properties and create cdk.context.json compared to having to build out env vars
  to pass to CFN CLI or manually enter in AWS Console.

Cons:

* Deployers are locked to CDK.  They must install cdk-bootstrap on their account before deployment will work.
* We are locking ourselves into CDK baked in functionality that does not exist in native cloudformation. We would have
  to redo the parameter model and duplicate CDK functionality to support moving to a native CloudFormation deployment.
* In the future, if we move to a different deployment model such as Terraform, or have to deploy to an account where
  the CDK bootstrap is not deployed, some of the custom resources the CDK provides will not exist and will have to
  be re-written from scratch.

### Option 2: Use CFN Parameters to pass in values at runtime

This is the preferred method for the Solutions Org as it allows deployers of a solution the ability to eventually use a
one-click deploy button from the solution's website.
So far; to my knowledge, all solutions published by the Solutions org have used CFN Parameters as their top level
parameter model.

This approach requires redoing the current deployment model entirely by replacing CDK context with a sample in the
readme with a `CFN/cdk deploy` command that is populated by devs and used to pass required parameter args to to the deployment.

Pros:

* Puts CMS in-line with other solutions
* Allows end-users to deploy with CloudFormation or CDK and maintains the same CMS experience.
* Support for NightsWatch without changing their code.

Cons:

* If we continue using bootstrapped custom resources, the end-user must run cdk-bootstrap on their account regardless of
  if they plan to deploy with CDK or CFN.
* CFN parameters are harder to pass around since there is no "global and local context" that can be used anywhere within
  CDK constructs.

## Decision

Selected Option 2.

Implement CFN Parameters as the only mechanism to deliver configuration properties.

This is done for 2 main reasons.

   1. We need to maintain compatibility w/ NightsWatch which only supports deploying CFN native scripts via taskcat.
   2. Leaves us with more future flexibility to support customers deploying either with CFN deploy or CDK deploy CLI commands.

Some additional info:

I spoke with another solution builder that provides their customers a mechanism for deploying both w/ CFN and CDK deploy.
They said they ran into the same wall with our pipeline and NightsWatch when trying to use CDK context and ended up
providing CFN Parameters.  We should take their lessons learned when making this decision to prevent running into the
same issues and having to revert from Option 1 to Option 2 after hitting the same wall.

The following will be implemented:

1. Expose CFN Parameters with all required settable properties at the top level CDK scripts.
2. Replace all instances of context values being set as defaults for module CDK stacks with proper CFN parameter inputs
   so that changes made after initial deployment will be applied successfully.
3. Convert all `os.environ` calls used by CDK scripts to parameter value reads.
4. Required CFN parameters are verified to exist (or have defaults) and follow some allowable structure
   (e.g. email address is valid email address) and errors are thrown when any fails verification.
   This error should prevent deployment from starting.
5. Remove the checked in cdk.context.json and instead create a sample CDK/CFN deploy w/ parameters command and a
   Makefile deploy command which is populated by deployers specifically for their environment

## Consequences

**BREAKING CHANGE**

* Breaks all deployment backwards compatibility with inputs passed on previously deployed CMS stacks.
  * All existing deployments of CMS will be broken in the sense that there will be no upgrade path for them.
   Everyone will have to completely tear down and re-deploy their environments
