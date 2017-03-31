sudo sed -i 's/\("zeppelin.pyspark.python": \)"python"/\1"python3"/' /etc/zeppelin/conf/interpreter.json
sudo chown zeppelin:zeppelin /etc/zeppelin/conf/zeppelin-env.sh
sudo /usr/lib/zeppelin/bin/zeppelin-daemon.sh stop
sudo pkill -f zeppelin
sudo /usr/lib/zeppelin/bin/zeppelin-daemon.sh start
