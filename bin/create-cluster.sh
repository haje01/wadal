CLUSTER_NAME="Wadal Cluster"
AWS_REGION="ap-northeast-1"
AWS_EMR_LABEL="emr-4.7.1"
NUM_TASK_INSTANCE=3
SPOT_BID_PRICE=0.06
EC2_TYPE="m3.xlarge"
EMR_LOG_URI="s3n://aws-logs-415742736303-ap-northeast-1/elasticmapreduce/"
AWS_KEY_NAME="wzdat-emr"

aws emr create-cluster --name "$CLUSTER_NAME" --region $AWS_REGION \
    --release-label $AWS_EMR_LABEL \
    --applications Name=Ganglia Name=Spark \
    --service-role EMR_DefaultRole \
    --instance-groups \
    InstanceGroupType=MASTER,InstanceType=$EC2_TYPE,InstanceCount=1 \
    InstanceGroupType=CORE,InstanceType=$EC2_TYPE,InstanceCount=1 \
    InstanceGroupType=TASK,InstanceType=$EC2_TYPE,InstanceCount=$NUM_TASK_INSTANCE,BidPrice=$SPOT_BID_PRICE \
    --configurations '[{"Classification":"spark","Properties":{"maximizeResourceAllocation":"true"},"Configurations":[]}]' \
    --bootstrap-actions Name=Init_for_Wadal,Path=s3://wzdat/scripts/wadal/init.sh \
    --enable-debugging \
    --log-uri $EMR_LOG_URI \
    --ec2-attributes \
KeyName=$AWS_KEY_NAME,\
InstanceProfile=EMR_EC2_DefaultRole,\
EmrManagedMasterSecurityGroup=sg-0c074868,\
EmrManagedSlaveSecurityGroup=sg-5807483c \
    --steps Type=CUSTOM_JAR,Name=RunCustomScript,ActionOnFailure=CANCEL_AND_WAIT,Jar=s3://ap-northeast-1.elasticmapreduce/libs/script-runner/script-runner.jar,Args=["s3://wzdat/scripts/wadal/cp-csvlib.sh"] Type=CUSTOM_JAR,Name=RunCustomScript,ActionOnFailure=CANCEL_AND_WAIT,Jar=s3://ap-northeast-1.elasticmapreduce/libs/script-runner/script-runner.jar,Args=["s3://wzdat/scripts/wadal/run-jupyter.sh"]
