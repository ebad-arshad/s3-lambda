import boto3
import urllib.parse

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    # Get the bucket name and object key from the event
    # [0] refers to the first file in the event (usually there is only one)
    bucket = event['Records'][0]['s3']['bucket']['name']
    
    # We use unquote_plus because S3 replaces spaces with '+' in the event key
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])
    
    print(f"File uploaded: {key} in bucket: {bucket}")
    try:
        # Fetch the object from S3
        response = s3_client.get_object(Bucket=bucket, Key=key)
        
        # 'Body' is a streaming object. .read() converts it into raw bytes.
        image_data = response['Body'].read()
        
        print(f"Successfully read {len(image_data)} bytes.")
        
        s3_client.put_object(
        Bucket='ebad-arshad-processed-assets-dev',
        Key=key,
        Body=image_data,
        ContentType='image/png' # Important so the browser renders it correctly
    )
        
        # --- YOUR PROCESSING LOGIC GOES HERE ---
        # e.g., using a library like Pillow or sharp to resize
        
    except Exception as e:
        print(f"Error getting object {key} from bucket {bucket}: {e}")
        raise e
    
    return {"status": "success"}