if [[ $# -lt 1 ]] ; then
    echo 'enter profile'
    exit 0
fi

source profiles/$1

aws emr terminate-clusters --cluster-ids `cat "$1_cluster.id"` --region=$AWS_REGION

