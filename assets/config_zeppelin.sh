# Default python3
sudo sed -i 's/\("zeppelin.pyspark.python": \)"python"/\1"python3"/' /etc/zeppelin/conf/interpreter.json


# Change Notebook dir 
# sudo su -l hadoop -c "mkdir ~/zworks"
# sudo chown zeppelin:zeppelin /home/hadoop/zworks
# sudo su -l hadoop -c "/usr/local/bin/s3fs $1 /home/hadoop/zworks -o passwd_file=/home/hadoop/.passwd-s3fs"
# sudo sed -i 's;export ZEPPELIN_NOTEBOOK_DIR=/var/lib/zeppelin/notebook;export ZEPPELIN_NOTEBOOK_DIR=/home/hadoop/zworks;' /etc/zeppelin/conf/zeppelin-env.sh

# run S3FS
# sudo cp /home/hadoop/.passwd-s3fs /home/hadoop/.zpasswd-s3fs
# sudo chown zeppelin:zeppelin /home/hadoop/.zpasswd-s3fs
# sudo chsh -s /bin/bash zeppelin
# sudo su -l zeppelin -c "s3fs $1 /home/hadoop/zworks -o passwd_file=/home/hadoop/.zpasswd-s3fs -d -d -f -o f2 -o curldbg -o nonempty" >> /tmp/zs3fs.log 2>&1


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

# sleep 3
# sudo pkill -f zeppelin >> /tmp/pkill_log 2>&1
# touch /tmp/z32

# sudo /usr/lib/zeppelin/bin/zeppelin-daemon.sh start
# touch /tmp/z33
