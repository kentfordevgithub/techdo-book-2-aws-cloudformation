aws cloudformation validate-template --template-body file://./cfn-pipeline.yml

aws cloudformation create-stack --stack-name cloudformation-template --template-body file://./cfn-pipeline.yml --capabilities CAPABILITY_NAMED_IAM

aws cloudformation update-stack --stack-name cloudformation-template --template-body file://./cfn-pipeline.yml --capabilities CAPABILITY_NAMED_IAM
