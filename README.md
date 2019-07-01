# wadal

wadal은 AWS EMR의 단속적(transient) 클러스터를 띄우고, 거기에 PySpark 환경을 설정해주는 유틸리티이다. 다음과 같은 특징이 있다.

- 다양한 셋팅의 EMR 클러스터를 사용할 수 있는 프로파일 기능
- Jupyter 노트북 환경에서 EMR의 PySpark을 사용
- 분석 노트북을 지정한 git 저장소에서 가져옴
- 기타 각종 편의 기능

*wadal은 bash shell의 명령어를 사용하기에 Mac OS나 Linux 기반에서 동작한다.*

## 먼저 필요한 것들

### aws cli

우선 AWS Command Line Interface 툴을 설치하고, EMR과 S3 권한이 있는 Credential을 설정해야한다. 아래 링크를 참고하여 진행하자.

1. [AWS 명령줄 인터페이스 설치](https://aws.amazon.com/ko/cli/)
2. [AWS CLI 설정](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)

### EC2 키 페어

만들어진 EMR 클러스터에 접속하기 위해서 [EC2 키 페어](http://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/ec2-key-pairs.html)가 필요하다.

### S3

클러스터 이용에 관련해 다음과 같은 S3 리소스를 준비해야 한다.

#### EMR 관련 애셋을 올릴 S3 경로

EMR 클러스터 초기화 및 이용에 다음과 같은 애셋(스크립트+바이너리)가 필요하다.

    assets/init_py.sh
    assets/init_r.sh
    assets/run_jupyter.sh
    assets/cp_assets.sh
    assets/NanumGothic.ttf
    ...

이 애셋들을 올릴 S3 경로를 정해둔다. 예) `s3://my-bucket/wadal_assets`
이 경로를 아래에서 설명할 프로파일 파일의 `INIT_ASSET_DIR_S3`로 설정하고, 애셋 올리기(`bin/upload_asset`)를 수행 하면 해당 경로가 만들어 지고 애셋 파일들이 올라간다.

#### EMR 초기화 로그를 올릴 S3 경로

EMR 클러스터 초기화시에 이런 저런 문제가 발생할 수 있는데, 이때 로그가 있으면 편리하다.
로그를 올린 S3 경로를 정하여 프로파일 파일의 `EMR_LOG_DIR_S3`에 설정하면, 클러스터 초기화에 발생하는 로그를 살펴볼 수 있다.

#### 분석 노트북 용 S3 버킷과 키

EMR 클러스터는 사용 후 제거되기에, 분석 노트북을 저장해둘 S3 버킷을 하나 생성한다. 예) `s3://my-notebooks`
그리고 노트북용 버킷에 읽기/쓰기가 가능한 IAM 계정을 준비하여, 정보를 프로파일의 `AWS_S3_ACCESS_KEY`와 `AWS_S3_SECRET_KEY`로 설정한다. 이 키는 클러스터에 저장되기에, 가급적 **S3 권한만 있는 별도 IAM 계정**을 만들어 사용할 것을 권한다.


##### Git 저장소
노트북 또는 코드를 관리하기 위해 git 저장소가 필요하다. github 등의 서비스에서 저장소를 만들고 관련 정보를 확인해 두자. git 저장소의 URL, 유저 이름, 암호, 유저 정보가 필요하다. 이 정보를 설정파일에 설정하면, 클러스터가 마스터 노드에 작업 폴더(`/home/hadoop/works`)를 만들고, 그 아래에 git에서 clone한 코드가 놓이게 된다.

예를 들어 저장소 이름이 `myrepo` 라면

    /home/hadoop/works/myrepo

아래에 코드가 생성된다.

### 사용할 정보 결정

#### AWS 리전

분석할 데이터가 S3에 올라가 있다면, 그 S3 버킷과 같은 리전에 EMR 클러스터를 만드는 것이 좋다.

#### EMR 버전

가급적 최신의 버전을 추천한다. AWS EMR 클러스터 생성 페이지에서 확인할 수 있다. 이 글을 쓰는 시점에서 4.7.1이 최신이다.

#### 인스턴스 타입

일반적인 분석에는 m5.xlarge(4 코어 16 GB 램) 정도가 괜찮을 것이다. 초기 테스트 용도라면 이것보다 낮은 사양으로도 충분하다.

#### Task 노드 수 결정

Task 노드는 HDFS 스토리지를 가지지 않는 워커노드이다. Spot으로 쓰기에 큰 부담이 되지는 않는다. 시작은 3대로 하고, 다량의 데이터 처리 또는 램이 많이 필요한 경우 더 늘려주자.

#### Core 노드 수 결정

Core 노드는 HDFS 스토리지를 가지는 워커노드이다. 기본은 1대이고 EBS 볼륨의 크기는 32GB이다. 다량의 데이터를 HDFS에 저장해야할 때는 명시적으로 늘려주자.

#### Subnet 선택

최근 인스턴스 타입은 VPC안에서 실행되기에 SubnetID를 필요로 한다. 클러스터를 만들 VPC와 거기에 속하는 Subnet을 정하고 SubnetID를 알아두자.

#### Spot Instance 가격 파악

Spot Instance를 사용하는 경우 자신이 원하는 환경(인스턴스 타입, 리전, Subnet이 속한 AZ) 등)에서의 시세를 알아두자. 시세보다 약간 높은 가격으로 프로파일에 기입한다.

#### 부트스트랩 스크립트

부트스트랩(bootstrap) 스크립트는 EMR의 부트스트랩 과정에서 수행되어, 패키지 설치나 환경 설정등의 작업을 한다. 기본으로 제공하는 아래의 두 스크립트 중 하나를 선택할 수 있고,

    assets/boot_eda.sh  # ETL 및 EDA를 위한 다양한 패키지를 설치 (시간이 오래 걸림)
    assets/boot_etl.sh  # ETL을 위한 최소한의 패키지를 설치 (시간이 조금 걸림)

스스로 bash 쉘 스크립트 형식으로 부트스트랩 스크립트를 작성해, `프로파일` 의 `BOOTSTRAP_SCRIPT` 에 명시할 수 있다.

```bash
    sudo yum -y install python36 python36-pip python36-devel
    sudo pip-3.6 install jupyter
    sudo pip-3.6 install boto3

    cat << EOF > /home/hadoop/.vimrc
    syntax on
    set tabstop=4
    set shiftwidth=4
    EOF
```

명시하지 않으면 기본 부트스트랩 스크립트인 `assets/boot_eda.sh`를 이용하게 된다.

#### Jupyter 노트북 모드 결정

다음과 같은 세 가지 모드 중 하나를 선택하자

- `notebook` - Jupyter Notebook 형태로 사용
- `lab` - Jupyter Lab 형태로 사용
- `remote` - VS Code의 Jupyter Server URI로 지정하여 사용

명시하지 않으면 기본은 `lab` 모드로 동작한다. VS Code에서 사용은 [이곳](https://code.visualstudio.com/docs/python/jupyter-support)을 참고하자.

## 프로파일 만들기

1. `profile.template`을 복사해 용도에 맞는 이름으로 `profiles/`아래에 넣음

        cp profile.template profiles/myprof

    앞으로 이 파일 `myprof`을 **프로파일 명** 으로 한다.

2. 에디터로 파일을 편집

앞에서 준비해둔 정보로 각 변수의 값을 채워 넣는다.

```bash
    export CLUSTER_NAME="YOUR-CLUSTER-NAME"
    export AWS_REGION=YOUR-AWS-REGION
    export AWS_EMR_LABEL=EMR-LABEL ex)emr-5.0.0
    # 사용할 region의 subnet
    export AWS_EMR_SUBNET=EMR-VPC-SUBNET ex)subnet-a55xxxxx
    # master 노드 인스턴스 타입
    export MASTER_EC2_TYPE=MASTER-NODE-EC2-INSTNACE-TYPE  ex) m4.large
    # core 노드 정보
    export CORE_EC2_TYPE=CORE-NODE-EC2-INSTANCE-TYPE  ex) m4.xlarge
    export CORE_EBS_SIZE=CORE-NODE-EBS-SIZE-IN-GB  ex) 100
    export NUM_CORE_INSTANCE=CORE-NODE-INSTNACE-NUMBER  ex) 2
    # task 노드 정보
    export TASK_EC2_TYPE=TASK-NODE-EC2-INSTANCE-TYPE  ex) r3.xlarge
    export NUM_TASK_INSTANCE=TASK-NODE-INSTANCE-NUMBER  ex) 3
    export TASK_SPOT_BID_PRICE=TASK-SPOT-INSTANCE-BID-PRICE  ex)0.06
    # master, core, task 공통으로 instance type 지정하는 경우
    export EC2_TYPE=EC2-INSTANCE-TYPE ex)m3.xlarge
    export EC2_KEY_PAIR_NAME=EC2-KEY-PAIR-NAME
    export EC2_KEY_PAIR_PATH="EC2-KEY-PAIR-PATH(include .pem)"
    export INIT_ASSET_DIR_S3=S3-URI-FOR-INIT-ASSET
    export EMR_LOG_DIR_S3=S3-URI-FOR-EMR-LOG
    export JUPYTER_MODE=JUPYTER-MODE  # 주피터 노트북 모드
    # 분석 코드 git 정보
    export GIT_REPO=GIT-REPO  # https:// 로 시작하는 git 저장소 URL
    export GIT_USER=GIT-USER  # 저장소 유저명
    export GIT_PASS=GIT-PASS  # 저장소 암호
    export GIT_MAIL=GIT-MAIL  # git config에 필요한 메일주소
    # 분석 노트북에 환경변수를 전달 (암호등에 이용하자)
    export RUN_NOTEBOOK_ENVS=ENV-VARS-TO-RUN-NOTEBOOK
    # 큰 HDFS 용량이 필요한 경우는 아래의 변수도 활용하자
    export NUM_CORE_INSTANCE=2  # 필요한 Core 노드 수
    export CORE_EBS_SIZE=500    # 각 Core 노드의 EBS 볼륨 크기(GB)
```

## 사용

앞에서 만들어둔 프로파일 이름을 아래와 같은 두 가지 방법으로 사용할 수 있다:
1. 미리 환경 변수(`PROFILE`)로 export 해두기
2. 매 명령의 첫 번째 인자로 건네기

2 번 방식은 매 명령의 첫 인자로 프로파일 이름은 지정해야 하기에 여러 명령을 수행할 때는 1 번 방법을 추천한다. 아래와 같이 한 번 호출해두면 편리하다.
```
export PROFILE=myprof
```

지금부터 다양한 명령어를 소개하겠다. 사용시 현재 디렉토리는 Wadal이 설치된 디렉토리여야 하며, 명령어는 `bin/` 디렉토리에 위치한다.

### 애셋 올리기

EMR 클러스터 초기화에 필요한 애셋을 업로드한다. 이 과정은 *Region 당 한번만 수행*하면 된다.

    bin/upload_assets

### 클러스터 생성

클러스터는 다음과 같이 생성한다.

    bin/create_cluster

생성된 클러스터의 ID는 `wadal` 아래 `clusters` 폴더에 저장되기에, 다음과 같이 현재 생성된 클러스터를 확인할 수 있다.

    ls clusters/

### 클러스터 상태 확인

    bin/state

클러스터 상태는 `STARTING`, `BOOTSTRAPPING`, `RUNNING`, `WAITING` 으로 나뉘어 진다. `RUNNING` 이나 `WAITING` 상태면 클러스터를 사용할 수 있다.

### Jupyter 노트북 열기

    bin/jupyter

웹브라우저를 띄워 생성된 클러스터의 Jupyter 노트북에 접속한다. 처음 클러스터를 생성했으면 아래 Security Group 설정을 참고해서 *Jupyter 노트북 용 포트를 열어주어야* 한다.

만약 노트북 초기 페이지에서 암호를 물어보면 `wadal`을 입력하자.

### 클러스터 생성후 준비가 되면 동작하기

클러스터 생성에는 시간이 꽤 걸린다. 어떤 명령을 내리기 위해 계속 보고 있기가 지루하다. `wait_ready`는 클러스터가 가용한 상태가 될 때까지 기다려 주기에, 다른 명령과 조합해서 사용하면 편리하다.

    bin/create_cluster && bin/wait_ready && bin/jupyter

위의 명령은 클러스터 생성 후 준비가 되면 Jupyter 노트북을 열어준다.


### 하둡 마스터 노드에 SSH 접속

    bin/ssh

### 특정 노트북 실행

미리 작업된 분석 노트북을 특정 조건에 맞게 실행할 수 있다. 단, 이 기능을 사용하기 위해서는 EMR 측에 [papermill](https://github.com/nteract/papermill)이 설치되어 있어야 한다.

예를 들어 아래와 같은 노트북이 있다면,

    works/myrepo/mynote.ipynb

다음과 같이 커맨드 라인에서 실행할 수 있다.

    bin/run_notebook myrepo/mynote.ipynb

만약 노트북의 특정 변수를 바꿔서 실행하고 싶으면 아래와 같이 한다. 미리 변수를 선언한 노트북 셀에 `parameters` 태그 설정이 필요한데, 자세한 것은 [papermill 도큐먼트](https://papermill.readthedocs.io/en/latest/)를 참고하자.

    bin/run_notebook myrepo/mynote.ipynb -p key1 val1 -p key2 val2

실행 결과는 노트북 파일명 + `.out.ipynb` 형식으로 저장된다.

    works/myrepo/mynote.out.ipynb

### VS Code나 Sublime Text 에디트로 원격 파일 편집하기

먼저 아래의 명령어로 EMR 마스터 노드에 접속한 뒤

    bin/rmate

다음과 같은 명령으로 마스터 노드의 파일을 로컬 Sublime Text 에디트로 편집할 수 있다. (단 Security Group 설정에서 52698포트가 열려있어야 하고, 로컬에 Sublime Text를 띄워둔 상태여야 한다.)

    rmate path/to/file.txt

### 특정 Python 스크립트 실행

작업된 파이썬 스크립트 파일(.py)을 다음과 같이 커맨드 라인에서 실행할 수 있다.

    bin/run_pyspark mycode.py


### 환경 변수 건네기

노트북이나 파이썬 스크립트를 실행할 때, 환경변수를 건넬 수 있으면 편리하다. 아래와 같이 `ENVS` 변수를 통해 할 수 있다.

    ENVS="SRC=/data/mydata.csv DATE=20161010" bin/run_notebook mynote.ipynb htmlr

위에서는 `SRC`와 `DATE` 변수가 노트북 또는 파이썬 스크립트에 환경변수로 건네진다. 다음과 같이 얻어낼 수 있겠다.

    import os
    SRC = os.environ['SRC']
    DATE = os.environ['DATE']

### 파일 올리기

로컬 파일을 작업 폴더로 올릴 수 있다. 예를 들어,

    bin/upload README.md

와 같이 하면 작업 폴더에

    works/README.md

가 생성된다.

### 파일 내려받기

작업 폴더의 파일을 현재 폴더로 내려받을 수 있다. 예를 들어,

    works/README.md

파일이 있다면,

    bin/download README.md

와 같이 하면 작업 폴더에 있는 파일을 `download` 폴더로 내려 받는다.


### 파일 내려받은 후 지우기

작업 폴더의 파일을 `download` 폴더로 내려받고 지울 수 있다. 예를 들어,

    works/README.md

파일이 있다면,

    bin/move README.md

와 같이 하면 작업 폴더에 있는 파일을 `download` 폴더로 내려 받은 후, 작업 폴더의 원본 파일은 지워진다.


### 작업 폴더 내용 보기

다음과 같이 작업 폴더에 있는 파일들을 볼 수 있다.

    bin/ls

`ls`의 옵션을 지정할 수도 있다.

    bin/ls -al


### EMR 클러스터 종료

아래와 같이 생성한 클러스터를 종료할 수 있다.

    bin/terminate

새로 생성되었지만 git 에 add 되지 않은 파일은 무시되기에 주의하자. add 되었으나 commit 되지 않은 파일이나 push 되지 않은 커밋이 있다면, 클러스터 종료 전 아래처럼 경고를 한다.

    There are        1 uncommitted file(s) and        1 unpushed commit(s)!!

    Uncommitted file(s)
    -------------------
    M muo2/gp/etl.ipynb

    Unpushed commit(s)
    -------------------
    + 97c378a961216683ae76bc6c8b914567b1a45665 test

    Are you sure to terminate (y/n)?

만약 배치 작업 등에서 경고를 무시하고 종료해야 할 때는 `bin/terminate_force`를 사용한다.


### 클러스터 자동으로 제거하기 (고급)

시간이 오래 걸리는 분석 노트북은 실행 후 클러스터 제거를 잊어먹는 경우가 많다. 다음과 같이 하면 분석 작업이 끝난 후 노트북에서 스스로 클러스터를 제거할 수 있다.(번거롭지만 보안을 위해 별도의 IAM 계정이 필요하다.)

1. AWS IAM에서 EMR 제거를 위한 새 유저를 만든다. 이때 Access Key와 Secret Key를 잘 기록해둔다.

2. 아래와 같이 EMR의 JobFlow 제거 권한이 있는 Policy를 만든다.

    ```
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "Stmt1479263896000",
                "Effect": "Allow",
                "Action": [
                    "elasticmapreduce:TerminateJobFlows"
                ],
                "Resource": [
                    "*"
                ]
            }
        ]
    }
    ```

3. 1에서 만든 유저에 2에서 만든 Policy를 붙여준다.

4. 프로파일에 다음과 같은 항목들을 추가한다.

    ```
    export EMR_TERM_ACCESS_KEY={IAM 유저의 Access Key}
    export EMR_TERM_SECRET_KEY={IAM 유저의 Secret Key}
    ```

5. 클러스터가 준비된 후 다음과 같이 호출한다.

    ```
    bin/add_termcmd
    ```

    이렇게 하면 클러스터 master 노드의 `/usr/bin` 아래에 클러스터를 제거할 수 있는 `terminate_cluster` 명령이 추가된다.

6. 분석 노트북 마지막에 `terminate_cluster`를 호출한다.

이런 식으로 분석 노트북에서 클러스터를 제거하면, 클러스터를 원래 생성했던 `wadal` 아래 `clusters` 폴더에는 여전히 클러스터 정보가 남아있다. 나중에 명시적으로 제거하거나 `bin/terminate`를 호출해주자.

## 주의할 것

### 제한된 권한의 IAM 유저를 사용하기

AWS 리소스의 권한이 필요 이상으로 부여된 IAM 유저 키가 해킹 등으로 유출되면, 큰 금전적 피해를 입을 수도 있다. 반드시 제한된 권한의 IAM 유저를 만들어서 사용하도록 하자.

### Security Group 설정

기본적으로 EMR 클러스터를 생성할 때 하둡 Master와 Slave를 위한 Security Group(이하 SG)이 자동적으로 만들어지게 된다. 그러나 기본 SG를 그대로 쓰지 말고 다음과 같이 수정해주자.

- 기본적으로 SSH 포트(22)가 모든 대역에 대해 열려 있다. 이것을 필요한 IP 대역으로 제한하자.
- Jupyter 노트북은 포트 8192 로 열려있다. 기본 SG에는 이것이 빠져있기에, 접속이 필요한 IP 대역으로 열어주자

이 작업은 AWS 대쉬보드에서 EMR 클러스터의 Master 노드의 SG에 대해 한번만 해주면 된다. 이후는 이 기본 SG가 그대로 사용된다.


### 클러스터 제거

다 사용한 클러스터는 꼭 terminate 해 비용을 절감하자.

