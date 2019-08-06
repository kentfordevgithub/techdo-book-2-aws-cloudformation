# yaml check

aws cloudformation validate-template --template-body file://./wordpress-multisite.yml


# dev

aws cloudformation create-stack --stack-name wordpress-multisite-dev --template-body file://./wordpress-multisite.yml --parameters ParameterKey=Domain,ParameterValue=dev.ninnino-domain

aws cloudformation update-stack --stack-name wordpress-multisite-dev --template-body file://./wordpress-multisite.yml --parameters ParameterKey=Domain,ParameterValue=dev.ninnino-domain


# prod

aws cloudformation create-stack --stack-name wordpress-multisite-prod --template-body file://./wordpress-multisite.yml --parameters ParameterKey=Domain,ParameterValue=ninnino-domain

aws cloudformation update-stack --stack-name wordpress-multisite-pord --template-body file://./wordpress-multisite.yml --parameters ParameterKey=Domain,ParameterValue=ninnino-domain
