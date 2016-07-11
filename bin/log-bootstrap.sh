ssh -i $AWS_KEY_PATH hadoop@$(aws emr describe-cluster --cluster-id `cat cluster_id.txt` --region=$AWS_REGION | grep MasterPublicDns | cut -d':' -f2 | tr -d ' ",') "tail -f /mnt/var/log/bootstrap-actions/master.log"

