sudo yum -y install git
git clone https://github.com/awslabs/git-secrets.git
cd git-secrets
sudo make install
sudo yum -y install graphviz
sudo yum -y install graphviz-devel
# install node
sudo yum install -y curl-devel
sudo yum install -y python3-devel
sudo su -l hadoop -c "curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash"
sudo su -l hadoop -c ". ~/.nvm/nvm.sh"
sudo su -l hadoop -c "nvm install 10.0"

# python3.7
sudo yum -y install tkinter tcl-devel tk-devel
# sudo sed -i -e '/secure_path/ s[=.*[&:/usr/local/bin[' /etc/sudoers

# cmake
wget http://www.cmake.org/files/v3.7/cmake-3.7.1.tar.gz
tar -zxvf cmake-3.7.1.tar.gz
cd cmake-3.7.1
./bootstrap
make
sudo make install
cd

# for pydata
sudo pip3.7 install tornado==5.1.1  # 6.0.0 has Jupyter kernel connection problem
sudo pip3.7 install jupyter
sudo pip3.7 install jupyterlab
sudo pip3.7 install matplotlib
sudo pip3.7 install cython
sudo pip3.7 install pandas
sudo pip3.7 install runipy
sudo pip3.7 install plotly
sudo pip3.7 install cufflinks
sudo pip3.7 install seaborn
sudo pip3.7 install boto3
sudo pip3.7 install rarfile
sudo pip3.7 install pycrypto
sudo pip3.7 install bokeh
sudo pip3.7 install sklearn
sudo pip3.7 install networkx
sudo pip3.7 install pyathena==1.11.2
# sudo pip3.7 install nxviz
sudo pip3.7 install pygraphviz
sudo pip3.7 install pydotplus
sudo pip3.7 install munch
sudo pip3.7 install jellyfish
sudo pip3.7 install xgboost
sudo pip3.7 install auto_ml
sudo pip3.7 install xlrd
sudo pip3.7 install s3fs
sudo pip3.7 install 'tqdm>=4.29.1'
sudo pip3.7 install papermill
sudo pip3.7 install https://github.com/ipython-contrib/jupyter_contrib_nbextensions/tarball/master
sudo su -l hadoop -c "/usr/local/bin/jupyter contrib nbextension install --user"
sudo su -l hadoop -c "/usr/local/bin/jupyter nbextension enable toc2/main"
sudo chown -hR hadoop /usr/local/share/jupyter/lab
sudo su -l hadoop -c "/usr/local/bin/jupyter labextension install @jupyterlab/toc"
# sudo pip3.7 install http://download.pytorch.org/whl/cpu/torch-0.3.1-cp36-cp36m-linux_x86_64.whl 
sudo pip3.7 install torchvision
sudo pip3.7 install geoip2
sudo pip3.7 install tensorboardX
sudo pip3.7 install scikit-plot

cat << EOF > /home/hadoop/.config/matplotlib/matplotlibrc
backend : agg
EOF

# GeoIP2
wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
mkdir -p geoip/city
tar xzvf GeoLite2-City.tar.gz -C geoip/city --strip-components=1
wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz
mkdir -p geoip/country
tar xzvf GeoLite2-Country.tar.gz -C geoip/country/ --strip-components=1
cd

# dateglob
git clone https://github.com/Yelp/dateglob.git
cd dateglob/
sudo pip3.7 install -e .
cd

# rar
wget http://www.rarlab.com/rar/rarlinux-x64-5.4.0.tar.gz
tar xzvf rarlinux-x64-5.4.0.tar.gz
cd rar
sudo cp rar unrar /usr/bin
cd ..
rm -fr rar
rm rarlinux-x64-5.4.0.tar.gz 

# snappy & snzip 
sudo yum install -y libtool
wget https://github.com/google/snappy/tarball/master -O snappy.tar.gz
mkdir google-snappy
tar xzvf snappy.tar.gz -C google-snappy --strip-components=1
cd  google-snappy
if [ ! -f README ]; then
    cp README.md README
fi
mkdir build
cd build 
/usr/local/bin/cmake -DBUILD_SHARED_LIBS=ON ../ 
make
sudo make install
cd
wget https://bintray.com/kubo/generic/download_file?file_path=snzip-1.0.4.tar.gz -O snzip-1.0.4.tar.gz
tar xzvf snzip-1.0.4.tar.gz
cd snzip-1.0.4/
./configure
make
sudo make install
cd ..
rm snzip-1.0.4.tar.gz
rm -fr snzip-1.0.4
sudo ldconfig

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
export PYSPARK_PYTHON=/usr/bin/python3.7
export PYSPARK_DRIVER_PYTHON=/usr/local/bin/jupyter
export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/local/lib
alias python=python3.7
alias pip=pip3.7
EOF

cat tmpenv >> /home/hadoop/.bash_profile
sudo cat tmpenv >> /root/.bash_profile
rm tmpenv

cat << EOF > /home/hadoop/report.tpl
{%- extends 'basic.tpl' -%}
{% from 'mathjax.tpl' import mathjax %}

{%- block header -%}
<!DOCTYPE html>
<html>
<head>
{%- block html_head -%}
<meta charset="utf-8" />
<title>{{resources['metadata']['name']}}</title>

<style type="text/css">
    .highlight .hll { background-color: #ffffcc }
.highlight  { background: #f8f8f8; }
.highlight .c { color: #408080; font-style: italic } /* Comment */
.highlight .err { border: 1px solid #FF0000 } /* Error */
.highlight .k { color: #008000; font-weight: bold } /* Keyword */
.highlight .o { color: #666666 } /* Operator */
.highlight .ch { color: #408080; font-style: italic } /* Comment.Hashbang */
.highlight .cm { color: #408080; font-style: italic } /* Comment.Multiline */
.highlight .cp { color: #BC7A00 } /* Comment.Preproc */
.highlight .cpf { color: #408080; font-style: italic } /* Comment.PreprocFile */
.highlight .c1 { color: #408080; font-style: italic } /* Comment.Single */
.highlight .cs { color: #408080; font-style: italic } /* Comment.Special */
.highlight .gd { color: #A00000 } /* Generic.Deleted */
.highlight .ge { font-style: italic } /* Generic.Emph */
.highlight .gr { color: #FF0000 } /* Generic.Error */
.highlight .gh { color: #000080; font-weight: bold } /* Generic.Heading */
.highlight .gi { color: #00A000 } /* Generic.Inserted */
.highlight .go { color: #888888 } /* Generic.Output */
.highlight .gp { color: #000080; font-weight: bold } /* Generic.Prompt */
.highlight .gs { font-weight: bold } /* Generic.Strong */
.highlight .gu { color: #800080; font-weight: bold } /* Generic.Subheading */
.highlight .gt { color: #0044DD } /* Generic.Traceback */
.highlight .kc { color: #008000; font-weight: bold } /* Keyword.Constant */
.highlight .kd { color: #008000; font-weight: bold } /* Keyword.Declaration */
.highlight .kn { color: #008000; font-weight: bold } /* Keyword.Namespace */
.highlight .kp { color: #008000 } /* Keyword.Pseudo */
.highlight .kr { color: #008000; font-weight: bold } /* Keyword.Reserved */
.highlight .kt { color: #B00040 } /* Keyword.Type */
.highlight .m { color: #666666 } /* Literal.Number */
.highlight .s { color: #BA2121 } /* Literal.String */
.highlight .na { color: #7D9029 } /* Name.Attribute */
.highlight .nb { color: #008000 } /* Name.Builtin */
.highlight .nc { color: #0000FF; font-weight: bold } /* Name.Class */
.highlight .no { color: #880000 } /* Name.Constant */
.highlight .nd { color: #AA22FF } /* Name.Decorator */
.highlight .ni { color: #999999; font-weight: bold } /* Name.Entity */
.highlight .ne { color: #D2413A; font-weight: bold } /* Name.Exception */
.highlight .nf { color: #0000FF } /* Name.Function */
.highlight .nl { color: #A0A000 } /* Name.Label */
.highlight .nn { color: #0000FF; font-weight: bold } /* Name.Namespace */
.highlight .nt { color: #008000; font-weight: bold } /* Name.Tag */
.highlight .nv { color: #19177C } /* Name.Variable */
.highlight .ow { color: #AA22FF; font-weight: bold } /* Operator.Word */
.highlight .w { color: #bbbbbb } /* Text.Whitespace */
.highlight .mb { color: #666666 } /* Literal.Number.Bin */
.highlight .mf { color: #666666 } /* Literal.Number.Float */
.highlight .mh { color: #666666 } /* Literal.Number.Hex */
.highlight .mi { color: #666666 } /* Literal.Number.Integer */
.highlight .mo { color: #666666 } /* Literal.Number.Oct */
.highlight .sb { color: #BA2121 } /* Literal.String.Backtick */
.highlight .sc { color: #BA2121 } /* Literal.String.Char */
.highlight .sd { color: #BA2121; font-style: italic } /* Literal.String.Doc */
.highlight .s2 { color: #BA2121 } /* Literal.String.Double */
.highlight .se { color: #BB6622; font-weight: bold } /* Literal.String.Escape */
.highlight .sh { color: #BA2121 } /* Literal.String.Heredoc */
.highlight .si { color: #BB6688; font-weight: bold } /* Literal.String.Interpol */
.highlight .sx { color: #008000 } /* Literal.String.Other */
.highlight .sr { color: #BB6688 } /* Literal.String.Regex */
.highlight .s1 { color: #BA2121 } /* Literal.String.Single */
.highlight .ss { color: #19177C } /* Literal.String.Symbol */
.highlight .bp { color: #008000 } /* Name.Builtin.Pseudo */
.highlight .vc { color: #19177C } /* Name.Variable.Class */
.highlight .vg { color: #19177C } /* Name.Variable.Global */
.highlight .vi { color: #19177C } /* Name.Variable.Instance */
.highlight .il { color: #666666 } /* Literal.Number.Integer.Long */
.highlight_text {
  color: blue;
}
/* Overrides of notebook CSS for static HTML export */
body {
  overflow: visible;
  padding: 8px;
}
div#notebook {
  overflow: visible;
  border-top: none;
}
@media print {
  div.cell {
    display: block;
    page-break-inside: avoid;
  } 
  div.output_wrapper { 
    display: block;
    page-break-inside: avoid; 
  }
  div.output { 
    display: block;
    page-break-inside: avoid; 
  }
}
div.prompt {
  display: none;
}
table {
  border-collapse: collapse;
  margin: 10px;
}
th {
  text-align: center;
}
tr:nth-child(even) {
  background-color: #f2f2f2;
}
th, td {
  padding: 5px 10px 5px 10px;
}
table, th, td {
  border: 1px solid black;
}
div.text_cell,
div.text_cell_render {
 font-family: "Open Sans", sans-serif;
 letter-spacing: 0.01rem;
 font-size: 15pt;
 line-height: 150% !important;
 color: #293340;
}
p code {
 border: #E3EDF3 1px solid;
 border-radius: 2px;
}
div.text_cell_render pre,
pre code {
 font-family: "Open Sans", sans-serif;
 font-size: 10pt;
 line-height: 120% !important;
 padding: 0;
 color: #cdd2e9;
 background: #252e3a;
}
div.text_cell_render h1,
div.text_cell_render h2,
div.text_cell_render h3,
div.text_cell_render h4,
div.text_cell_render h5,
div.text_cell_render h6 {
 font-family: "Open Sans", sans-serif;
 text-align: left;
 font-weight: bolder;
 line-height: 150% !important;
 color: #293340;
}
a.anchor-link:link {
  display: none;
}
div.input_area {
 margin-left: 30px;
 display: none;
}
div.output_area pre {
 font-family: "Source Code Pro", monospace;
 font-size: 10.5pt !important;
 line-height: 100% !important;
 color: #bfbcbf;
 white-space: pre-wrap;
 display: none;
}
</style>

<!-- Loading mathjax macro -->
{{ mathjax() }}
{%- endblock html_head -%}
</head>
{%- endblock header -%}

{% block body %}
<body>
  <div tabindex="-1" id="notebook" class="border-box-sizing">
    <div class="container" id="notebook-container">
{{ super() }}
    </div>
  </div>
</body>
{%- endblock body %}

{% block footer %}
</html>
{% endblock footer %}
EOF
