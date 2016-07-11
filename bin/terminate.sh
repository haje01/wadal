aws emr terminate-clusters --cluster-ids "`cat cluster_id.txt`" --region=$AWS_REGION

