# Default python3
sudo sed -i 's/\("zeppelin.pyspark.python": \)"python"/\1"python3"/' /etc/zeppelin/conf/interpreter.json

# Store notebook in S3
cat << EOF > /tmp/zcfg_tmp

export ZEPPELIN_NOTEBOOK_STORAGE=org.apache.zeppelin.notebook.repo.S3NotebookRepo
export ZEPPELIN_NOTEBOOK_S3_BUCKET=$1
export ZEPPELIN_NOTEBOOK_S3_USER=$2
EOF

echo "if len(\"$3\") > 0: print(\"\n\".join([\"export {}\".format(it) for it in \"$3\".split(\";\")]))" > /tmp/zcfg_cmd.py
/usr/bin/python /tmp/zcfg_cmd.py >> /tmp/zcfg_tmp
sudo bash -c "cat /tmp/zcfg_tmp >> /etc/zeppelin/conf/zeppelin-env.sh"
sudo chown zeppelin:zeppelin /etc/zeppelin/conf/zeppelin-env.sh
rm /tmp/zcfg_cmd.py
rm /tmp/zcfg_tmp

# Restart zeppelin
sudo /usr/lib/zeppelin/bin/zeppelin-daemon.sh stop
sudo pkill -f zeppelin
sudo /usr/lib/zeppelin/bin/zeppelin-daemon.sh start
