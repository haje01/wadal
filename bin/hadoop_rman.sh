open http://$(aws emr describe-cluster --cluster-id `cat cluster_id.txt` --region=$AWS_REGION | grep MasterPublicDns | cut -d':' -f2 | tr -d ' ",' | awk '{print$1":8088"}')
