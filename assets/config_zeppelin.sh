# Default python3
sudo sed -i 's/\("zeppelin.pyspark.python": \)"python"/\1"python3"/' /etc/zeppelin/conf/interpreter.json

# Store notebook in S3
sudo bash -c "cat << EOF >> /etc/zeppelin/conf/zeppelin-env.sh
export ZEPPELIN_NOTEBOOK_STORAGE=org.apache.zeppelin.notebook.repo.S3NotebookRepo
export ZEPPELIN_NOTEBOOK_S3_BUCKET=$1
export ZEPPELIN_NOTEBOOK_S3_USER=$2
EOF"
sudo chown zeppelin:zeppelin /etc/zeppelin/conf/zeppelin-env.sh

# Restart zeppelin
sudo /usr/lib/zeppelin/bin/zeppelin-daemon.sh stop
sudo pkill -f zeppelin
sudo /usr/lib/zeppelin/bin/zeppelin-daemon.sh start
