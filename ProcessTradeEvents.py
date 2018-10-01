from __future__ import print_function
import boto3
from decimal import Decimal
import base64
import json

'''
Example of kinesis streamed wrapped data
{'Records': [{'kinesis': {'kinesisSchemaVersion': '1.0', 'partitionKey': 'shardId-000000000000', 'sequenceNumber': '49588763521539636171473035759529458585192324752482500610', 'data': 'eyJkYXRlIjogMTUwNDIyODgwMCwgImhpZ2giOiAzOTIuOTk5OTk5OTksICJsb3ciOiAzOTIuMDc0MDEsICJvcGVuIjogMzkyLjc3Nzc3NzcsICJjbG9zZSI6IDM5Mi45NjA2OTk5OCwgInZvbHVtZSI6IDY4MDY3Ljk1MDEzMTQ0LCAicXVvdGVWb2x1bWUiOiAxNzMuMjM3NDM1NjgsICJ3ZWlnaHRlZEF2ZXJhZ2UiOiAzOTIuOTE3MDk1OTF9', 'approximateArrivalTimestamp': 1538362955.278}, 'eventSource': 'aws:kinesis', 'eventVersion': '1.0', 'eventID': 'shardId-000000000000:49588763521539636171473035759529458585192324752482500610', 'eventName': 'aws:kinesis:record', 'invokeIdentityArn': 'arn:aws:iam::477894402526:role/datapipeline-kinesis-lambda-dynamodb-ProcessTradeEvents-iam-role', 'awsRegion': 'ap-southeast-1', 'eventSourceARN': 'arn:aws:kinesis:ap-southeast-1:477894402526:stream/datapipeline-kinesis-lambda-dynamodb-myKinesis'}]}
'''

def parse_and_format_record(record):

	#Decode payload
	encoded_data = record["kinesis"]["data"]
	decoded_data = base64.b64decode(encoded_data)
	data = json.loads(decoded_data)

	#Rewrite data dictionnary for DynamoDB input format 
	for k, v in data.items():
		data[k] = {"N": str(v)}

	return data

def lambda_handler(event, context):

	#Add each record into Database
	client = boto3.client('dynamodb')
	table = 'datapipeline-kinesis-lambda-dynamodb-myDynamoDB'
	for record in event['Records']:
		data = parse_and_format_record(record)
		client.put_item(TableName=table, Item=data)