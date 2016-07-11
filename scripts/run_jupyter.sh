#!/usr/bin/env bash

#Environments
SPARK_PACKAGES=com.databricks:spark-csv_2.11:1.4.0
JUPYTER_LOG=/home/hadoop/.jupyter/jupyter.log

##Configure s3fs
sudo su -l hadoop bash -c "echo -e $1:$2 > ~/.passwd-s3fs"
sudo chmod 600 /etc/passwd-s3fs
sudo su -l hadoop -c "mkdir ~/notebooks"
sudo /usr/local/bin/s3fs wzdat-notebooks /home/hadoop/notebooks -o passwd_file=/etc/passwd-s3fs

##Configure Jupyter
sudo su -l hadoop -c "/usr/local/bin/jupyter notebook --generate-config"

JUPYTER_NOTEBOOK_CONFIG=/home/hadoop/.jupyter/jupyter_notebook_config.py
sudo sed -i -e '3a c.NotebookApp.notebook_dir = "/home/hadoop/notebooks"' $JUPYTER_NOTEBOOK_CONFIG
sudo sed -i -e '3a c.NotebookApp.ip = "*"' $JUPYTER_NOTEBOOK_CONFIG
sudo sed -i -e '3a c.NotebookApp.open_browser = False' $JUPYTER_NOTEBOOK_CONFIG
sudo sed -i -e '3a c.NotebookApp.port = 8192' $JUPYTER_NOTEBOOK_CONFIG
sudo sed -i -e '3a c = get_config()' $JUPYTER_NOTEBOOK_CONFIG

IPYTHON_KERNEL_CONFIG=/home/hadoop/.ipython/profile_default/ipython_kernel_config.py
sudo su -l hadoop -c "ipython profile create"
sudo sed -i -e '3a c.InteractiveShellApp.matplotlib = "inline"' $IPYTHON_KERNEL_CONFIG


##Launch Jupyter by executing "pyspark"
JUPYTER_PYSPARK_BIN=/home/hadoop/.jupyter/start-jupyter-pyspark.sh

cat << EOF > $JUPYTER_PYSPARK_BIN
export SPARK_HOME=/usr/lib/spark/
export PYSPARK_PYTHON=/usr/bin/python3
export PYSPARK_DRIVER_PYTHON=/usr/local/bin/ipython3
export PYSPARK_DRIVER_PYTHON_OPTS='notebook'
export SPARK_PACKAGES=$SPARK_PACKAGES
nohup pyspark --packages $SPARK_PACKAGES > $JUPYTER_LOG 2>&1 &
EOF

chmod +x $JUPYTER_PYSPARK_BIN
$JUPYTER_PYSPARK_BIN
