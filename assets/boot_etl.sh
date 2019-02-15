sudo yum -y install git

sudo yum -y install python36 python36-pip python36-devel
sudo pip-3.6 install jupyter
sudo pip-3.6 install numpy
sudo pip-3.6 install matplotlib
sudo pip-3.6 install cython
sudo pip-3.6 install pandas
sudo pip-3.6 install runipy
sudo pip-3.6 install boto3
sudo pip-3.6 install pycrypto
sudo pip-3.6 install s3fs
sudo pip-3.6 install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master
sudo su -l hadoop -c "/usr/local/bin/jupyter contrib nbextension install --user"
sudo su -l hadoop -c "/usr/local/bin/jupyter nbextension enable toc2/main"

# for s3fs
sudo yum install -y gcc libstdc++-devel gcc-c++ fuse fuse-devel curl-devel libxml2-devel mailcap automake openssl-devel 
sudo wget ftp://mirror.switch.ch/pool/4/mirror/epel/6/x86_64/Packages/j/jsoncpp-devel-0.10.5-2.el6.x86_64.rpm
wget ftp://mirror.switch.ch/pool/4/mirror/epel/6/x86_64/Packages/j/jsoncpp-0.10.5-2.el6.x86_64.rpm
sudo rpm -ivh *.rpm
git clone https://github.com/s3fs-fuse/s3fs-fuse
cd s3fs-fuse/
./autogen.sh
./configure --prefix=/usr --with-openssl
make
sudo make install
cd

# rsub
cd
sudo wget -O /usr/local/bin/rsub \https://raw.github.com/aurora/rmate/master/rmate
sudo chmod a+x /usr/local/bin/rsub

cat << EOF > /home/hadoop/.vimrc
syntax on
set ic
set tabstop=4
set shiftwidth=4
set autoindent
set hlsearch
set smartindent
set backspace=2
set expandtab
set laststatus=2   " Always show the statusline
set encoding=utf-8 " Necessary to show Unicode glyphs
set t_Co=256 " Explicitly tell Vim that the terminal supports 256 colors

au BufRead,BufNewFile *.html set textwidth=200
au BufRead,BufNewFile *.md set filetype=markdown
au BufRead,BufNewFile *.py set textwidth=79
au BufRead,BufNewFile *.py set makeprg=pylint\ --reports=n\ --output-format=parseable\ %:p
au BufRead,BufNewFile *.py set errorformat=%f:%l:\ %m
au BufRead,BufNewFile *.sh set tabstop=2
au BufRead,BufNewFile *.sh set shiftwidth=2
au BufRead,BufNewFile *.js set tabstop=2
au BufRead,BufNewFile *.js set shiftwidth=2
au BufRead,BufNewFile *.html set tabstop=2
au BufRead,BufNewFile *.html set shiftwidth=2
au BufRead,BufNewFile *.css set tabstop=2
au BufRead,BufNewFile *.css set shiftwidth=2
au BufRead,BufNewFile *.py set tabstop=4
EOF


cat << EOF > tmpenv

export SPARK_HOME=/usr/lib/spark/
export PYSPARK_PYTHON=/usr/bin/python36
export PYSPARK_DRIVER_PYTHON=/usr/local/bin/jupyter
export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib
alias python=python36
alias pip=pip-3.6
EOF

cat tmpenv >> /home/hadoop/.bash_profile
sudo cat tmpenv >> /root/.bash_profile
rm tmpenv
