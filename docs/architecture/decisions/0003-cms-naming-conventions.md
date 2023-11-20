# 3. CMS Naming Conventions

Date: 2023-03-22

## Status

Accepted

Extension - IoT Topic Names [6. IoT Topic Naming Conventions](0006-iot-topic-naming-conventions.md)

Extension - Inter-module SSM parameters [11. SSM Parameter naming convention for inter-module dependencies](0011-ssm-parameter-naming-convention-for-inter-module-dependencies.md)

## Context

As of this proposal, we have 3 established modules and 1 new module,
while establishing the boiler plate of our new modules it was discovered
that we have inconsistency in naming AWS infrastructure resources
throughout our other modules. We have used PascalCase, snake_case, kebab-case,
and lowercase for different resources even within the same module.
There are also, Construct Id's, and Tags named in such fashion.

## Decision

Information below is accurate as of aws-cdk version 2.

The change that we are implementing from now onwards is as follows:

1. Module names (repository name): module names should use kebab-case name's, gitfarm enforces
   the first letter of the repo to be uppercase so that must also be followed
   in this case. All modules should follow this template
   `Cms-<module-descriptor>-on-aws`.
2. Stack name: stack name should also use kebab-case, we will not have any
   uppercase letters in here. This name is what will show up in Cloudformation
   console when we deploy the stack. It should follow this format
   `<module-name>-stack-<stage-name>`
3. File Names (non-python): File names: files should follow generally known
   standards when one exists; python_file.py, README.md, Pipfile, LICENSE,
   etc. If no such standard exists for a given file type, we will default
   back to kebab-case.
4. Construct Id's: Use kebab-case.
5. Resource tags: All modules should have 2 tags added in `app.py`, module tag
   with value `<module-name>` and solution tag with value
   `connected-mobility-solution-on-aws`. This would apply tags to every resource
   under the construct scope.
   [CDK Tagging](https://docs.aws.amazon.com/cdk/api/v1/python/aws_cdk.core/Tags.html#aws_cdk.core.Tags).
   If you need to add additional tags please follow this format `<stack-name>-<tag-name>`.
6. Actual name of deployed resource: It is not recommended to name the actual
   resource directly through cdk as many resources would require the name to
   be unique across the entire region. e.g. S3, dynamodb. So do not explicitly
   name anything until and unless required. If it is required then use
   kebab-case, and prefix it with stack name if possible, otherwise use your
   best judgement and discuss if necessary.
7. AWS SSM Parameter names: parameter names should use the naming convention
   as per these guidelines
   [Creating SSM Parameters](https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-su-create.html).
   To summarize the article, we will use this format /`stage-name`/`stack-name`/`parameter-name`.
   The article also uses aws-region in this name but we will avoid it as there is 1011 character
   limit on parameter name and it includes the entire ARN so the region is already there.
   Name should not start with /aws, aws, /ssm, ssm. If you want to make it more descriptive,
   then you can extend the name and use / as
   a seperator but use it after the stack-name.
8. AWS Secretsmanager secret names: secrets manager enforces a 512 unicode
   character limit on secret name, so we will try to keep it simple just like
   we did for SSM Parameter name. We will use this format
   `/<stage>/<stack-name>/<secret-name>` and you can add more description if
   you want after stack-name, use / as a seperator.

Note that, these changes would not apply to any frontend changes including config files.
CamelCase is the standard there, and frontend files and code should follow their standards.

## Consequences

As a consequence of this decision, we will have to revisit all of our existing modules and make it adhere to this standard.
