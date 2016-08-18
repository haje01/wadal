sudo yum -y install git

# for R Server
wget https://download2.rstudio.org/rstudio-server-rhel-0.99.903-x86_64.rpm
sudo yum install -y --nogpgcheck rstudio-server-rhel-0.99.903-x86_64.rpm
sudo adduser rstudio
sudo echo 'rstudio ALL = NOPASSWD: ALL' >> /etc/sudoers
echo "rstudio:rstudio" | sudo chpasswd

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
