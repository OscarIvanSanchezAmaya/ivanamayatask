from flask import Flask, send_from_directory, logging
import os
#import glob
import socket
import  boto3
import re
from waitress import serve
from paste.translogger import TransLogger
app = Flask(__name__)
#app.logger.setLevel(logging.INFO)
#logging.basicConfig()
#logging.getLogger().setLevel(logging.INFO)
session = boto3.Session()
s3 = session.resource('s3')
typefile = os.environ.get("typefile")
bucket = os.environ.get("bucket")
@app.route("/")
def tos():
    response = s3.list_objects_v2(Bucket='bucket')
    files = sum(re.match(r"*/{typefile}", f['Key']) for f in response['Contents'])
    ip = socket.gethostbyname(socket.gethostname())
    return str("IP:{ip}\nFiles:{files} {typefile}")
    

if __name__ == "__main__":
    serve(TransLogger(app), host="0.0.0.0", port=80)