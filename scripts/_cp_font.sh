sudo mkdir -p /usr/share/fonts/truetype/nanum
sudo aws s3 cp {INIT_SCRIPT_DIR_S3}/NanumGothic.ttf /usr/share/fonts/truetype/nanum --region={AWS_REGION}
