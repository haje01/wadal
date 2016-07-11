aws emr describe-cluster --cluster-id `cat cluster_id.txt` --region=ap-northeast-1 | grep '"State"' | head -n1 | cut -d':' -f2 | tr -d ' ",'
