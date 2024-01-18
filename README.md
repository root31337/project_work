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
* Домен geckzone.ru с прописанными DNS серверами ns1.yandexcloud.net. и ns2.yandexcloud.net.

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

Переименовать файл infra/terraform/ terraform.tfvars.example в terraform.tfvars и вставить свои значения
В работе использовался k8s версии 1.27 (манифесты на старых версиях могут не работать)
Перейти в infra/terraform и выполнить:
>

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
* Сервер Gitlab с адресом https://gitlab.geckzone.ru 
* В K8s создаст 3 PersistentVolume для ElasticSearch

После того как закончит работу Ansible, найти в экране вывода пароль root, скопировать.

Перейти по адресу https://gitlab.geckzone.ru, залогинится.

Создать два проекта crawler и ui

В каждом из проектов 
* Создать переменные CI_REGISTRY_USER и CI_REGISTRY_PASSWORD с реквизитами от DockerHub (Settings/CI/CD)
* Запретить возможность регистрации аккаунтов сторонним пользователям
* Отключить публичные раннеры
* Получить токены регистрации gitlab-runner 

Создадим немспейс gitlab в кластере k8s:

$kubectl create namespace gitlab

Добавить репозитарий Helm:
>
    helm repo add bitnami https://charts.bitnami.com/bitnami

Выполнить с добавлением токенов:
>
    helm install --namespace gitlab gitlab-runner-ui \
    --set gitlabUrl=https://gitlab.geckzone.ru/ \
    --set runnerRegistrationToken="............" \
    --set runners.privileged=true \
     gitlab/gitlab-runner

>
    helm install --namespace gitlab gitlab-runner-crawler \
    --set gitlabUrl=https://gitlab.geckzone.ru/ \
    --set runnerRegistrationToken="............." \
    --set runners.privileged=true \
     gitlab/gitlab-runner

Добавить права раннеру
>
    kubectl create clusterrolebinding gitlab-cluster-admin \
    --clusterrole=cluster-admin \
    --serviceaccount=gitlab:default


### Установка микросервисов

Выполнить установку ingress-ngnix
>
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

Посмотреть IP LoadBalancer:
>
    kubectl get svc -n ingress-nginx

Через веб интерфейс YC создать А DNS записи поддоменов app, staging, prometheus,  grafana, zipkin , kibana  доменф geckzone.ru на внешний IP LoadBalancer.

Установить RabbitMQ
>
    export RABBITMQ_PASSWORD=crawler_pass
>
    helm install rabbitmq \
    --set auth.password=$RABBITMQ_PASSWORD \
    bitnami/rabbitmq \
    --namespace production

Перейти в папку 
project_work/microservices

Выполнить:
>
    kubectl apply -f app -n production
    kubectl apply -f tracing -n production
    kubectl apply -f logging -n logging
    kubectl apply -f monitoring -n monitoring
    helm repo add bitnami https://charts.bitnami.com/bitnami

После этого можно будет зайти на ресурсы:

http://app.geckzone.ru
http://prometheus.geckzone.ru
http://grafana.geckzone.ru
http://zipkin.geckzone.ru
http://kibana.geckzone.ru

В Kibana настроить Data View по индексу  filebeat-*
В Grafana установить пароль, и сменить у подключённого DataSourse Prometheus HttpMethod на POST

### CI/CD
В папках src/ui и src/crawler выполнить 
>
    git init
    git remote add origin https://gitlab.geckzone.ru/root/ui
    git remote add origin https://gitlab.geckzone.ru/root/crawler

Сделать коммит в репозитарии, запустится пайплайн со сборкой, тестом, деплоем на staging (по адресу http://staging.geckzone.ru ) и ручным деплоем на production (http://app.geckzone.ru )

