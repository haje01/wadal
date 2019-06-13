#!/usr/bin/env bash

# Environments
JUPYTER_LOG=/home/hadoop/.jupyter/jupyter.log

# Configure s3fs
sudo su -l hadoop -c "mkdir ~/works"
if [ "$1" = "NA" ]; then
    # using git for notebook storage
    sudo su -l hadoop -c "cd ~/works && git clone ${4/\/\//\/\/$5:$6@} > /tmp/git-clone.log 2>&1"
else
    # using s3 for notebook storage
    sudo su -l hadoop -c "echo -e $1:$2 > ~/.passwd-s3fs"
    sudo su -l hadoop -c "chmod 600 ~/.passwd-s3fs"
    sudo su -l hadoop -c "/usr/bin/s3fs $3 /home/hadoop/works"
fi

# Configure Jupyter
sudo su -l hadoop -c "/usr/local/bin/jupyter notebook --generate-config"

JUPYTER_NOTEBOOK_CONFIG=/home/hadoop/.jupyter/jupyter_notebook_config.py
sudo sed -i -e '3a c.NotebookApp.iopub_data_rate_limit = 10000000' $JUPYTER_NOTEBOOK_CONFIG
sudo sed -i -e '3a c.NotebookApp.password = "sha1:8c1b53def426:12eefe9afd49d7345bfb71c4463aa61ca644ef4a"' $JUPYTER_NOTEBOOK_CONFIG
sudo sed -i -e '3a c.NotebookApp.notebook_dir = "/home/hadoop/works"' $JUPYTER_NOTEBOOK_CONFIG
sudo sed -i -e '3a c.NotebookApp.allow_remote_access = True' $JUPYTER_NOTEBOOK_CONFIG
sudo sed -i -e '3a c.NotebookApp.allow_origin = "*"' $JUPYTER_NOTEBOOK_CONFIG
sudo sed -i -e '3a c.NotebookApp.ip = "*"' $JUPYTER_NOTEBOOK_CONFIG
sudo sed -i -e '3a c.NotebookApp.open_browser = False' $JUPYTER_NOTEBOOK_CONFIG
sudo sed -i -e '3a c.NotebookApp.port = 8192' $JUPYTER_NOTEBOOK_CONFIG
sudo sed -i -e '3a c = get_config()' $JUPYTER_NOTEBOOK_CONFIG

sudo su -l hadoop -c "mkdir -p ~/.jupyter/custom"
cat << EOF > ~/.jupyter/custom/custom.css
.CodeMirror pre, .output pre, .CodeMirror-dialog, .CodeMirror-dialog .CodeMirror-search-field, .terminal-app .terminal {
    font-family: courier !important;
    font-size: 11pt;
}
EOF

IPYTHON_KERNEL_CONFIG=/home/hadoop/.ipython/profile_default/ipython_kernel_config.py
IPYTHON_STARTUP_SCRIPT=/home/hadoop/.ipython/profile_default/startup/init.py
sudo su -l hadoop -c "ipython profile create"
sudo sed -i -e '3a c.InteractiveShellApp.matplotlib = "inline"' $IPYTHON_KERNEL_CONFIG
cat << EOF > $IPYTHON_STARTUP_SCRIPT
import sys
sys.path.append('/home/hadoop/works/')

import numpy as np
import matplotlib.pyplot as plt
plt.style.use('ggplot')
import matplotlib as mlp
mlp.rcParams['font.family'] = u'NanumGothic'
mlp.rcParams['font.size'] = 10

# import seaborn as sns
# sns.set_style('darkgrid', {'font.family': [u'NanumGothic']})
from IPython.display import HTML

import pandas as pd
EOF


# Launch Jupyter by executing "pyspark"
JUPYTER_PYSPARK_BIN=/home/hadoop/.jupyter/start-jupyter-pyspark.sh

cat << EOF > $JUPYTER_PYSPARK_BIN
export SPARK_HOME=/usr/lib/spark/
export PYSPARK_PYTHON=/usr/bin/python36
export PYSPARK_DRIVER_PYTHON=/usr/local/bin/jupyter
export PYSPARK_DRIVER_PYTHON_OPTS='lab'
set -a
eval "$7"
set +a
nohup pyspark > $JUPYTER_LOG 2>&1 &
EOF

chmod +x $JUPYTER_PYSPARK_BIN
sudo su -l hadoop $JUPYTER_PYSPARK_BIN
