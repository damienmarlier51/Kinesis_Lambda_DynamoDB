# Data ingestion with AWS

## Introduction

Data ingestion module on AWS using Kinesis, Lambda and DynamoDB.

## Get started

### Prerequisites

* Terraform >= 0.11.8
* Python 3.6
* aws-cli

### Deployment

Configure AWS CLI with your AWS profile credentials:

```
aws configure
```

Deploy cloud infrastructure using the makefile:

```
make deploy
```

### Test

You can test the deployed infrastructure by running the example:

```
python testStream.py
```









