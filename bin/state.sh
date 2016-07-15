if [[ $# -lt 1 ]] ; then
    echo 'enter profile'
    exit 0
fi

source profiles/$1

aws emr describe-cluster --cluster-id `cat "$1_cluster.id"` --region=ap-northeast-1 | grep '"State"' | head -n1 | cut -d':' -f2 | tr -d ' ",'
