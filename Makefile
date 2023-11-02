CMS_SOLUTION_VERSION ?= v1.0.0


# Call export after all variables are set.
# This allows Make variables to be used and environment variables in sub-shells created by Make target commands
export


build:
	.acdp/scripts/generate-service-template.sh

clean:
	rm -rf dist/

deploy:
	echo ${CMS_SOLUTION_VERSION}
	.acdp/scripts/copy-backstage-template-to-s3.sh