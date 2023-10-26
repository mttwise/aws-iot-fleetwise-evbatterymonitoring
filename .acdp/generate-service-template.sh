
rm -rf dist/
mkdir dist
mkdir dist/tmp

cp -r .acdp/proton/v1 dist/tmp

cp -r samples/web/ dist/tmp/v1/instance_infrastructure

tar czf dist/proton-service.tar.gz -C dist/tmp/ ./