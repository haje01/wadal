sudo mkdir -p /usr/share/fonts/truetype/nanum
sudo aws s3 cp {INIT_ASSET_DIR_S3}/NanumGothic.ttf /usr/share/fonts/truetype/nanum --region={AWS_REGION}

# cd /usr/lib/spark/external/lib
# sudo wget http://dl.bintray.com/spark-packages/maven/graphframes/graphframes/0.2.0-spark2.0-s_2.11/graphframes-0.2.0-spark2.0-s_2.11.jar
