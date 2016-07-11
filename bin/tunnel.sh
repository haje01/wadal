ssh -i $AWS_KEY_PATH -N -D 8157 hadoop@$(aws emr describe-cluster --cluster-id `cat cluster_id.txt` --region=$AWS_REGION | grep MasterPublicDns | cut -d':' -f2 | tr -d ' ",')
