#!/usr/bin/env bash

# Environments
JUPYTER_LOG=/home/hadoop/.jupyter/jupyter.log

# Configure s3fs
sudo su -l hadoop -c "echo -e $1:$2 > ~/.passwd-s3fs"
sudo su -l hadoop -c "chmod 600 ~/.passwd-s3fs"
sudo su -l hadoop -c "mkdir ~/works"
sudo su -l hadoop -c "/usr/local/bin/s3fs $3 /home/hadoop/works"

# Configure Jupyter
sudo su -l hadoop -c "/usr/local/bin/jupyter notebook --generate-config"

JUPYTER_NOTEBOOK_CONFIG=/home/hadoop/.jupyter/jupyter_notebook_config.py
sudo sed -i -e '3a c.NotebookApp.notebook_dir = "/home/hadoop/works"' $JUPYTER_NOTEBOOK_CONFIG
sudo sed -i -e '3a c.NotebookApp.ip = "*"' $JUPYTER_NOTEBOOK_CONFIG
sudo sed -i -e '3a c.NotebookApp.open_browser = False' $JUPYTER_NOTEBOOK_CONFIG
sudo sed -i -e '3a c.NotebookApp.port = 8192' $JUPYTER_NOTEBOOK_CONFIG
sudo sed -i -e '3a c = get_config()' $JUPYTER_NOTEBOOK_CONFIG

IPYTHON_KERNEL_CONFIG=/home/hadoop/.ipython/profile_default/ipython_kernel_config.py
IPYTHON_STARTUP_SCRIPT=/home/hadoop/.ipython/profile_default/startup/init.py
sudo su -l hadoop -c "ipython profile create"
sudo sed -i -e '3a c.InteractiveShellApp.matplotlib = "inline"' $IPYTHON_KERNEL_CONFIG
cat << EOF > $IPYTHON_STARTUP_SCRIPT
import numpy as np
import matplotlib.pyplot as plt 

import matplotlib as mlp 
mlp.rcParams['font.family'] = u'NanumGothic'
mlp.rcParams['font.size'] = 10

import seaborn as sns 
sns.set_style('darkgrid', {'font.family': [u'NanumGothic']})
from IPython.display import HTML
EOF


# Launch Jupyter by executing "pyspark"
JUPYTER_PYSPARK_BIN=/home/hadoop/.jupyter/start-jupyter-pyspark.sh

cat << EOF > $JUPYTER_PYSPARK_BIN
export SPARK_HOME=/usr/lib/spark/
export PYSPARK_PYTHON=/usr/bin/python3
export PYSPARK_DRIVER_PYTHON=/usr/local/bin/ipython3
export PYSPARK_DRIVER_PYTHON_OPTS='notebook'
# export SPARK_PACKAGES=graphframes:graphframes:0.2.0-spark2.0-s_2.11
# nohup pyspark --packages $SPARK_PACKAGES > $JUPYTER_LOG 2>&1 &
nohup pyspark > $JUPYTER_LOG 2>&1 &
EOF

chmod +x $JUPYTER_PYSPARK_BIN
sudo su -l hadoop $JUPYTER_PYSPARK_BIN
