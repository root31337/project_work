project_work

 README #



## Проектная работа:
## Создание процесса непрерывной поставки для приложения с применением Практик CI/CD и быстрой обратной связью ##

### Требования ###
* Автоматизированные процессы создания и управления платформой
* Ресурсы Ya.cloud
* Инфраструктура для CI/CD
* Инфраструктура для сбора обратной связи
* Использование практики IaC (Infrastructure as Code) для управления
конфигурацией и инфраструктурой
* Настроен процесс CI/CD
* Все, что имеет отношение к проекту хранится в Git

### Дано: 
* Микросервисное приложение
* База данных
* Менеджер очередей сообщений
* Пример сайта для парсинга


## Установка ##
### Используемые локальные инструменты

Рабочая станция с OS – Arch Linux
С установленными:

* Yandex CLI
* Packer (1.51)
* Terraform
* Ansible
* Kubectl
* HELM
* Установлены модули python-kubernetse, python-jsonpatch, python-pyaml

### Используемые внешние ресурсы

* Yandex Cloud
* Домен secureitzone.online с прописанными DNS серверами ns1.yandexcloud.net. и ns2.yandexcloud.net.

### Предварительная подготовка рабочего места

Необходимо иметь аккаунт на Yandex Cloud https://console.cloud.yandex.ru/

Для доступа к созываемым ресурсам сгенерировать пару ключей

> 
    ssh-keygen -t rsa -f ~/.ssh/ubuntu -C ubuntu -P ""

Создать профиль для  Yandex  CLI https://cloud.yandex.ru/docs/cli/operations/profile/profile-create
Создать сервисный аккаунт в Yandex.Cloud

> 
    $ yc config list - Получить Folder-id
    $ SVC_ACCT="прописать свое имя"
    $ FOLDER_ID="вписать полученный Folder-id" 
 
Создать аккаунт и назначить права:

>
    $ yc iam service-account create --name $SVC_ACCT --folder-id $FOLDER_ID
    $ ACCT_ID=$(yc iam service-account get $SVC_ACCT | \
    grep ^id | \
    awk '{print $2}') 
 
> 
    $ yc resource-manager folder add-access-binding --id $FOLDER_ID \
    --role editor \ 
    --service-account-id $ACCT_

Создать IAM key и экспортировать его в файл

> 
    yc iam key create --service-account-id $ACCT_ID --output ~/key.json

Склонировать репозиторий проекта и перейти в каталог с проектом

    git clone https://github.com/root31337/project_work.git
    cd project_work/infra

Подготовить образ для MongoDB сервера:
Переименовать файл infra/packer/variables.pkr.hcl.example в variables.pkr.hcl и вставить свои значения

Выполнить сборку:
> 
    packer build -var-file="./packer/variables.pkr.hcl" ./packer/db.pkr.hcl 

Получить id созданного образа:
> 
    yc compute image list

Переименовать файл infra/terraform/ terraform.tfvars.example в variables.json и вставить свои значения
Перейти и выполнить
>
  cd terraform
  terraform init
  terraform apply

Terraform произведет установку:
* VM для  MongoDB на базе созданного образа без публичного IP
* VM для  Gitlab 
* Managed Service for Kubernetes с тремя нодами
* Создаст 3 диска в YC для кластера ElasticSearch
* Создаст файл переменных для Ansible
* Передаст управление Ansible

Ansible создаст:
* Сервер Gitlab с адресом https://gitlab.secureitzone.online 
* В K8s создаст 3 PersistentVolume для ElasticSearch

После того как закончит работу Ansible, найти в экране вывода пароль root, скопировать.

Перейти по адресу https://gitlab.secureitzone.online, залогинится.

Создать два проекта crawler и ui

В каждом из проектов 
* Создать переменные СI_REGISTRY_USER CI_REGISTRY_PASSWORD с реквизитами от DockerHub (Settings/CI/CD)
* Получить токены регистрации gitlab-runner 

Добавить репозитарий Helm:
>
    helm repo add bitnami https://charts.bitnami.com/bitnami

Выполнить с добавлением токенов:
>
    helm install --namespace gitlab gitlab-runner-ui \
    --set gitlabUrl=https://gitlab.secureitzone.online/ \
    --set runnerRegistrationToken="..." \
    --set runners.privileged=true \
     gitlab/gitlab-runner

>
    helm install --namespace gitlab gitlab-runner-crawler \
    --set gitlabUrl=https://gitlab.secureitzone.online/ \
    --set runnerRegistrationToken="..." \
    --set runners.privileged=true \
     gitlab/gitlab-runner

Добавить права раннеру
>
    kubectl create clusterrolebinding gitlab-cluster-admin \
    --clusterrole=cluster-admin \
    --serviceaccount=gitlab:default

