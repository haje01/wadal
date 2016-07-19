# Wadal

Webzen Advanced Data Analysis Lab

## 먼저 필요한 것들

### aws cli

1. [AWS 명령줄 인터페이스 설치](https://aws.amazon.com/ko/cli/)
2. [AWS CLI 설정](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)

## 사용 방법

### 설정 파일 만들기

1. `env.template`을 복사해 용도에 맞는 이름으로 `profiles/`아래에 넣음

    cp env.template profiles/myenv

앞으로 이 파일 `myenv`을 *프로파일 명* 으로 한다.

2. 에디터로 설정 파일을 편집

**Spot Instance를 사용하는 경우 미리 해당 리전의 시세를 알아둔다.**

    export CLUSTER_NAME="YOUR-CLUSTER-NAME"
    export AWS_REGION=YOUR-AWS-REGION
    export AWS_EMR_LABEL=EMR-LABEL ex)emr-4.7.1
    export NUM_TASK_INSTANCE=3
    export TASK_SPOT_BID_PRICE=TASK-SPOT-INSTANCE-BID-PRICE ex)0.06
    export EC2_TYPE=EC2-INSTANCE-TYPE ex)m3.xlarge
    export EMR_LOG_URI="s3n://YOUR-BUCKET//YOUR-PATH-FOR-AWS-LOG/elasticmapreduce/"
    export AWS_KEY_NAME=EMR-KEY-NAME
    export AWS_KEY_PATH="AWS-KEY-FILE-PATH(include .pem)"
    export AWS_S3_ACCESS_KEY=AWS-S3-ACCESS-KEY-FOR-NOTEBOOK-SYNC
    export AWS_S3_SECRET_KEY=AWS-S3-SECRET-KEY-FOR-NOTEBOOK-SYNC
    export EMR_MASTER_SG=YOUR-EMR-MASTER-SECURITY-GROUP
    export EMR_SLAVE_SG=YOUR-EMR-SLAVE-SECURITY-GROUP
    export NOTEBOOK_S3_BUCKET=YOUR-S3-BUCKET-FOR-ANALYSIS-NOTEBOOKS

### EMR 클러스터 관리

위에서 만든 프로파일 명을 끝에 넣어주고, 아래와 같은 다양한 명령을 수행한다.

#### 클러스터 생성

    bin/create-cluster myenv

#### 클러스터 상태 확인

    bin/state myenv

#### Jupyter 노트북 열기

    bin/notebooks myenv

#### 하둡 마스터 노드에 로그인

    bin/ssh myenv

### EMR 클러스터 제거

    bin/terminate myenv


## 주의할 것

다 사용한 클러스터는 꼭 terminate 하자

