import json
import boto3
from ProcessTradeEvents import parse_and_format_record
import time 

def test_stream():

	#Load example data
	data_file = "../example/1504524001_1504824001"
	json_data=open(data_file).read()
	data = json.loads(json_data)

	#Create client for stream
	my_stream_name = 'datapipeline-kinesis-lambda-dynamodb-myKinesis'
	kinesis_client = boto3.client('kinesis', region_name='ap-southeast-1')

	#Get shard
	streamDescriptionResponse = kinesis_client.describe_stream(StreamName=my_stream_name)
	shard_id = streamDescriptionResponse["StreamDescription"]["Shards"][0]["ShardId"]

	#Send record every 1 second
	for datum in data:
		time.sleep(1)
		put_response = kinesis_client.put_record(StreamName=my_stream_name,Data=json.dumps(datum),PartitionKey=shard_id)

if __name__ == "__main__":

	test_stream()