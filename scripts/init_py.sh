sudo yum -y install git

# for pydata
curl https://bootstrap.pypa.io/get-pip.py | sudo python3.4
sudo /usr/local/bin/pip3 install jupyter
sudo /usr/local/bin/pip3 install numpy
sudo /usr/local/bin/pip3 install matplotlib
# sudo /usr/local/bin/pip3 install pandas
sudo /usr/local/bin/pip3 install runipy
sudo /usr/local/bin/pip3 install plotly
sudo /usr/local/bin/pip3 install cufflinks
sudo /usr/local/bin/pip3 install click

# for s3fs
sudo yum install -y gcc gcc-c++
sudo yum install -y automake
sudo yum install -y fuse-devel curl-devel libxml2-devel openssl-devel
wget https://github.com/s3fs-fuse/s3fs-fuse/archive/master.zip
unzip master.zip
cd s3fs-fuse-master
./autogen.sh
./configure
make
sudo make install

SPARK_PACKAGES=com.databricks:spark-csv_2.11:1.4.0
cat << EOF > tmpenv

export SPARK_HOME=/usr/lib/spark/
export PYSPARK_PYTHON=/usr/bin/python3
export PYSPARK_DRIVER_PYTHON=/usr/local/bin/ipython3
export SPARK_PACKAGES=$SPARK_PACKAGES
alias python=python3
EOF

cat tmpenv >> /home/hadoop/.bash_profile
sudo cat tmpenv >> /root/.bash_profile
rm tmpenv
