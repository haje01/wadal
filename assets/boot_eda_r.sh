sudo yum -y install git

# for R Server
wget https://download2.rstudio.org/rstudio-server-rhel-0.99.903-x86_64.rpm
sudo yum install -y --nogpgcheck rstudio-server-rhel-0.99.903-x86_64.rpm
sudo adduser rstudio
sudo usermod -aG hadoop rstudio
sudo echo 'rstudio ALL = NOPASSWD: ALL' >> /etc/sudoers
echo "rstudio:rstudio" | sudo chpasswd
sudo su -l rstudio -c "cat << EOF >> /home/rstudio/.bashrc
export AWS_DEFAULT_REGION=$(curl --retry 5 --silent --connect-timeout 2 http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
export JAVA_HOME=/etc/alternatives/jre
EOF
"

# install additional packages
sudo Rscript -e 'update.packages(checkBuilt = TRUE, ask = FALSE, repos="http://cran.rstudio.com/")'
sudo Rscript -e 'install.packages("tidyverse", repos = "http://cran.us.r-project.org")'

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

# rar
wget http://www.rarlab.com/rar/rarlinux-x64-5.4.0.tar.gz
tar xzvf rarlinux-x64-5.4.0.tar.gz
cd rar
sudo cp rar unrar /usr/bin
cd ..
rm -fr rar
rm rarlinux-x64-5.4.0.tar.gz 
