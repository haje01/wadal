sudo yum -y install git

# for pydata
curl https://bootstrap.pypa.io/get-pip.py | sudo python3.4
sudo /usr/local/bin/pip3 install jupyter
sudo /usr/local/bin/pip3 install numpy
sudo /usr/local/bin/pip3 install matplotlib
sudo /usr/local/bin/pip3 install runipy

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
