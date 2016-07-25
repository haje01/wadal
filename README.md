# wadal

wadal(Webzen Advance Data Analysis Lab)은 AWS EMR의 단속적(transient) 클러스터를 띄우고, 거기에 Jupyter + Pyspark을 환경을 설정해주는 유틸리티이다.

## 먼저 필요한 것들

### aws cli

AWS Command Line Interface 툴을 설치하고, EMR과 S3 권한이 있는 Credential로 설정한다.

1. [AWS 명령줄 인터페이스 설치](https://aws.amazon.com/ko/cli/)
2. [AWS CLI 설정](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)

### S3

클러스터 이용에 관련해 다음과 같은 S3 리소스를 준비하자.

#### EMR 관련 스크립트를 올릴 S3 경로

EMR 클러스터 초기화 및 이용에 다음과 같은 스크립트가 필요하다. 

    scripts/init.sh
    scripts/cp_csvlib.sh
    scripts/run_jupyter.sh

이 스크립트들을 올릴 S3 경로를 준비한다. 예) `s3://my-bucket/scripts`


#### 분석 노트북 용 S3 Bucket

EMR 클러스터는 사용 후 제거되기에 분석 노트북을 저장해둘 S3 Bucket을 하나 준비한다. 예) `s3://my-notebooks`


### Spot Instance 가격 파악

Spot Instance를 사용하는 경우 자신이 원하는 환경(인트턴스 타입, 리전 등)에서의 시세를 알아둔다


## 설정 파일 만들기

앞에서 준비해둔 정보로 설정파일을 만든다.

1. `env.template`을 복사해 용도에 맞는 이름으로 `profiles/`아래에 넣음

        cp env.template profiles/myenv

    앞으로 이 파일 `myenv`을 *프로파일 명* 으로 한다.

2. 에디터로 설정 파일을 편집


*Spot Instance를 사용하는 경우 미리 해당 리전의 시세를 알아둔다.*

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
    export INIT_SCRIPT_DIR_S3=S3-URL-FOR-INIT-SCRIPTS
    export NOTEBOOK_S3_BUCKET=YOUR-S3-BUCKET-FOR-ANALYSIS-NOTEBOOKS

## 사용

위에서 만든 프로파일 명을 끝에 넣어주고, 아래와 같은 다양한 명령을 수행한다.

### 스크립트 올리기

EMR 클러스터 초기화에 필요한 스크립트를 업로드한다. 이 과정은 최초 한번만 수행하면 된다.

    bin/upload-scripts myenv

### 클러스터 생성

    bin/create-cluster myenv

### 클러스터 상태 확인

    bin/state myenv

### Jupyter 노트북 열기

    bin/notebooks myenv

### 하둡 마스터 노드에 로그인

    bin/ssh myenv

### EMR 클러스터 제거

    bin/terminate myenv


## 주의할 것

다 사용한 클러스터는 꼭 terminate 하자

