cd /usr/lib/spark/lib

sudo aws s3 cp $INIT_SCRIPT_S3_URL/commons-csv-1.1.jar . --region=$AWS_REGION

sudo aws s3 cp $INIT_SCRIPT_S3_URL/spark-csv_2.11-1.4.0.jar . --region=$AWS_REGION

