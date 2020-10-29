from flask import Flask, jsonify
import boto3
import os
import json

s3_bucket_name = os.environ.get('S3_BUCKET_NAME')
s3_object_key = os.environ.get('S3_OBJECT_KEY')

if not (s3_bucket_name and s3_object_key):
    raise ValueError("S3_BUCKET_NAME and S3_OBJECT_KEY not configured.")

app = Flask(__name__)

def get_data_from_s3():
    """
    Gets vulnerability data from S3 bucket.
    TODO: Configure bucket and key from environment variables.
    """

    s3 = boto3.resource('s3')
    vulnerabilities = s3.Object(s3_bucket_name, s3_object_key).get()['Body'].read().decode('utf-8')
    return json.loads(vulnerabilities)

@app.route('/')
def get_data():
    """
    Returns vulnerability data gathered from S3 bucket.
    """
    return get_data_from_s3()

@app.route('/stats')
def get_count():
    """
    Calculates number of LOW, MEDIUM, or HIGH vulnerabilities per vendor_id and returns the counts.
    """
    vulnerabilities = get_data_from_s3()
    
    response = {}

    for vuln in vulnerabilities['vulnerabilities']:
        vendor_id = vuln['vendor_id']
        severity = vuln['severity']
        
        # Initialize default counts if vendor_id hasn't been seen.
        if not response.get(vendor_id):
            response[vendor_id] = {
                    'LOW': 0,
                    'MEDIUM': 0,
                    'HIGH': 0,
                    }

        response[vendor_id][severity] =+ 1 

    return response

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)
