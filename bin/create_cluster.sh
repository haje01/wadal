aws emr create-cluster --name "$CLUSTER_NAME" --region $AWS_REGION \
    --release-label $AWS_EMR_LABEL \
    --applications Name=Ganglia Name=Spark \
    --service-role EMR_DefaultRole \
    --instance-groups \
    InstanceGroupType=MASTER,InstanceType=$EC2_TYPE,InstanceCount=1 \
    InstanceGroupType=CORE,InstanceType=$EC2_TYPE,InstanceCount=1 \
    InstanceGroupType=TASK,InstanceType=$EC2_TYPE,InstanceCount=$NUM_TASK_INSTANCE,BidPrice=$TASK_SPOT_BID_PRICE \
    --configurations '[{"Classification":"spark","Properties":{"maximizeResourceAllocation":"true"},"Configurations":[]}]' \
    --bootstrap-actions Name=Init_for_Wadal,Path=s3://wzdat/scripts/wadal/init.sh \
    --enable-debugging \
    --log-uri $EMR_LOG_URI \
    --ec2-attributes \
KeyName=$AWS_KEY_NAME,\
InstanceProfile=EMR_EC2_DefaultRole,\
EmrManagedMasterSecurityGroup=$EMR_MASTER_SG,\
EmrManagedSlaveSecurityGroup=$EMR_SLAVE_SG \
    --steps Type=CUSTOM_JAR,Name=CopyCSVLib,ActionOnFailure=CANCEL_AND_WAIT,Jar=s3://$AWS_REGION.elasticmapreduce/libs/script-runner/script-runner.jar,Args=["s3://wzdat/scripts/wadal/cp_csvlib.sh"] Type=CUSTOM_JAR,Name=RunJupyter,ActionOnFailure=CANCEL_AND_WAIT,Jar=s3://$AWS_REGION.elasticmapreduce/libs/script-runner/script-runner.jar,Args=["s3://wzdat/scripts/wadal/run_jupyter.sh","$AWS_S3_ACCESS_KEY","$AWS_S3_SECRET_KEY"] | sed -n '/ClusterId/p' | cut -d':' -f2 | tr -d ' "'> cluster_id.txt
