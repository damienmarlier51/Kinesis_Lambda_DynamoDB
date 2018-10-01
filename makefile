FUNCTION = ProcessTradeEvents
DYNAMODB = myDynamoDB
KINESIS = myKinesis

.PHONY: clean build deploy

#Package Lambda function
build_zip:

	#Create a virtual environment where to install python libraries needed by lambda
	virtualenv $(FUNCTION)-dev

	#Activate environment
	. $(FUNCTION)-dev/bin/activate

	#Install the libraries described in the requirements file
	pip install -r requirements.txt
	
	#Copy python environment libraries into site-packages
	mkdir -p site-packages
	cd site-packages; cp -r ../$(FUNCTION)-dev/lib/python3.6/site-packages/ ./

	#Add the libraries to the zip files
	cd site-packages; zip -g -r ../$(FUNCTION)-dev.zip .
	zip -g $(FUNCTION)-dev.zip $(FUNCTION).py

clean_env: build_zip

	rm -r site-packages
	rm -r $(FUNCTION)-dev

init:
	terraform init

plan: init build_zip clean_env
	terraform plan \
		-var 'function_name=$(FUNCTION)' \
  		-var 'dynamodb_name=$(DYNAMODB)' \
  		-var 'kinesis_name=$(KINESIS)'

#Deploy configuration.tf on the cloud
deploy: init build_zip clean_env
	terraform apply \
		-var 'function_name=$(FUNCTION)' \
  		-var 'dynamodb_name=$(DYNAMODB)' \
  		-var 'kinesis_name=$(KINESIS)'

#Destroy stack described configuration.tf
destroy:
	terraform destroy