sudo yum -y install git
# install node
sudo yum install -y curl-devel
sudo su -l hadoop -c "curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash"
sudo su -l hadoop -c ". ~/.nvm/nvm.sh"
sudo su -l hadoop -c "nvm install 9.0"

sudo yum -y install python36 python36-pip python36-devel
sudo pip-3.6 install tornado==5.1.1  # 6.0.0 has Jupyter kernel connection problem
sudo pip-3.6 install jupyter
sudo pip-3.6 install jupyterlab
sudo pip-3.6 install boto3
sudo pip-3.6 install papermill
sudo pip-3.6 install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master
sudo su -l hadoop -c "/usr/local/bin/jupyter contrib nbextension install --user"
sudo su -l hadoop -c "/usr/local/bin/jupyter nbextension enable toc2/main"
sudo chown -hR hadoop /usr/local/share/jupyter/lab
sudo su -l hadoop -c "/usr/local/bin/jupyter labextension install @jupyterlab/toc"

# rmate
sudo wget -O /usr/local/bin/rmate \https://raw.github.com/aurora/rmate/master/rmate
sudo chmod a+x /usr/local/bin/rmate

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
