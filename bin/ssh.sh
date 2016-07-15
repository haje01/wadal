if [[ $# -lt 1 ]] ; then
    echo 'enter profile'
    exit 0
fi

source profiles/$1

ssh -i $AWS_KEY_PATH hadoop@$(aws emr describe-cluster --cluster-id `cat "$1_cluster.id"` --region=$AWS_REGION | grep MasterPublicDns | cut -d':' -f2 | tr -d ' ",')
