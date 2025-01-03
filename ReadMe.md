# Дипломный практикум в Yandex.Cloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:

### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер (неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте (создание бакета через TF) \
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)
3. Создайте конфигурацию Terrafrom, используя созданный бакет ранее как бекенд для хранения стейт файла. Конфигурации Terraform для создания сервисного аккаунта и бакета и основной инфраструктуры следует сохранить в разных папках.
4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий, стейт основной конфигурации сохраняется в бакете или Terraform Cloud
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---

### Решение 1

1. Создаём файлы конфигурации [terraform для bucket](https://github.com/SlavaZakariev/diploma/tree/main/terraform/bucket) для инфраструктуры в Yandex Cloud

- [bucket.tf](https://github.com/SlavaZakariev/diploma/blob/main/terraform/bucket/bucket.tf) - для создания bucket хранилища и сервисной учётной записи
- [var.bucket.tf](https://github.com/SlavaZakariev/diploma/blob/main/terraform/bucket/var.bucket.tf) - переменные для bucket в своём подкаталоге
- [provider.tf](https://github.com/SlavaZakariev/diploma/blob/main/terraform/bucket/provider.tf) - для указания настроек провайдера облака

2. Запускаем создание хранилища bucket

![init](https://github.com/SlavaZakariev/diploma/blob/ffaa06b378742674fe0af24870a2940bd4e1e2ba/images/dip_1_1.1.jpg)

3. Проверяем созданные ресурсы bucket и SA через терминал YC

![bucket-yc](https://github.com/SlavaZakariev/diploma/blob/ffaa06b378742674fe0af24870a2940bd4e1e2ba/images/dip_1_1.2.jpg)

4. Проверяем ресурс bucket через веб-интерфейс

![bucket-web](https://github.com/SlavaZakariev/diploma/blob/ffaa06b378742674fe0af24870a2940bd4e1e2ba/images/dip_1_1.3.jpg)

5. Создаём основные файлы конфигурации [terraform](https://github.com/SlavaZakariev/diploma/tree/main/terraform) для инфраструктуры в Yandex Cloud

- [network.tf](https://github.com/SlavaZakariev/diploma/blob/main/terraform/network.tf) - конфигурация сети
- [vars.network.tf](https://github.com/SlavaZakariev/diploma/blob/main/terraform/vars.network.tf) - переменные для сети
- [provider.tf](https://github.com/SlavaZakariev/diploma/blob/main/terraform/provider.tf) - конфигурация для облачного провайдера YC
- [vars.provider.tf](https://github.com/SlavaZakariev/diploma/blob/main/terraform/vars.provider.tf) - переменные для облачного провайдера YC
- [vm.tf](https://github.com/SlavaZakariev/diploma/blob/main/terraform/vm.tf) - конфигурация ресурсов виртуальных машин
- [vars.vm.tf](https://github.com/SlavaZakariev/diploma/blob/main/terraform/vars.vm.tf) - переменные для ресурсов виртуальных машин
- [locals.tf](https://github.com/SlavaZakariev/diploma/blob/main/terraform/locals.tf) - конфигурация ssh-ключа для виртуальных машин
- [metadata.yaml](https://github.com/SlavaZakariev/diploma/blob/main/terraform/metadata.yaml) - публичный ssh-ключ
- [outputs.tf](https://github.com/SlavaZakariev/diploma/blob/main/terraform/output.tf) - вывод IP адресов вновь созданных ресурсов в терминале

6. Запускаем создание ресурсов

![init-main](https://github.com/SlavaZakariev/diploma/blob/main/images/dip_2_1.1.jpg)

8. Проверяем созданные основные ресурсы через терминал YC (Ресурсы созданы в зоне a, b, d согласно условию)

![main-yc](https://github.com/SlavaZakariev/diploma/blob/main/images/dip_2_1.3.jpg)

8. Проверяем основные ресурсы через веб-интерфейс

![main-web](https://github.com/SlavaZakariev/diploma/blob/main/images/dip_2_1.2.jpg)

---

### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

---

### Решение 2

1. Устанавливаем статические внешние IP адреса, чтобы при выключении ВМ, адреса не сменялись

![IP-static](https://github.com/SlavaZakariev/diploma/blob/main/images/dip_2_1.4.jpg)

2. Устанавливаем через кластер Кубернетес через `kubespray`. Прописываем наши внешние адреса, чтобы сформировать файл **inventory**

```bash
declare -a IPS=(89.169.128.19 89.169.173.194 51.250.37.240)
```

3. Получаем файл [hosts.yaml](https://github.com/SlavaZakariev/diploma/blob/main/kubespray/hosts.yaml). Убеждаемся в правильности распределения узлов для `kube_control_plane`, `kube_node` и `etcd`

```yaml
all:
  hosts:
    k8s-master-01:
      ansible_host: 89.169.128.19
      ip: 10.10.1.11
      access_ip: 10.10.1.11
    k8s-worker-01:
      ansible_host: 89.169.173.194
      ip: 10.10.2.12
      access_ip: 10.10.2.12
    k8s-worker-02:
      ansible_host: 51.250.37.240
      ip: 10.10.3.13
      access_ip: 10.10.3.13
  children:
    kube_control_plane:
      hosts:
        k8s-master-01:
    kube_node:
      hosts:
        k8s-worker-01:
        k8s-worker-02:
    etcd:
      hosts:
        k8s-master-01:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
```

4. Запускаем сборник **ansible-playbook**

![ansible](https://github.com/SlavaZakariev/diploma/blob/main/images/dip_2_1.5.jpg)

5. Проверяем работоспособность кластера путём проверки статуса узлов и подов во всех пространствах имён

![get-pods](https://github.com/SlavaZakariev/diploma/blob/main/images/dip_2_1.6.jpg)

---

### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Regestry с собранным docker image. В качестве regestry может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный с помощью terraform.

---

### Решение 3

1. В папке проекта, создаём [Dockerfile](https://github.com/SlavaZakariev/diploma/blob/main/nginx-app/Dockerfile)

```dockerfile
# Root image
FROM nginx:1.25.5

# Author
LABEL author=Zakariev

# Configuration
COPY conf /ect/nginx
# Content file
COPY content /usr/share/nginx/html

# Workdir
WORKDIR /usr/share/nginx/html

# Health Check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -f http://localhost/ || exit 1

EXPOSE 80
```

2. Создаём каталог `conf` и внутри файл [nginx.conf](https://github.com/SlavaZakariev/diploma/blob/main/nginx-app/conf/nginx.conf) для конфигурации приложения

```java
user nginx;
worker_processes 1;
error_log /var/log/nginx/error.log warn;

events {
    worker_connections 1024;
    multi_accept on;
}

http {
    server {
        listen   80;

        location / {
            gzip off;
            root /var/www/html/;
            index index.html;
        }
    }
    keepalive_timeout  60;
}
```

3. Создаём каталог `content` и внутри файл [index.html](https://github.com/SlavaZakariev/diploma/blob/main/nginx-app/content/index.html) для страницы приложения

```html
<!DOCTYPE html>
<html lang="ru">

<head>
    <meta charset="utf-8" name="viewport" content="width=device-width, initial-scale=1" />
    <title>Diploma of Viacheslav Zakariev</title>
</head>

<body>
    <h2 style="margin-top: 150px; text-align: center;">Diploma of Viacheslav Zakariev (DevOps-engineer, group FOPS-12, Netology)</h2>
</body>

</html>
```

4. Запускаем создание снимка с тэгом `v1.0.0`

![build](https://github.com/SlavaZakariev/diploma/blob/d1087af6d5ada6952153e77a4cff946a805a497f/images/dip_3_1.1.jpg)

5. Проверяем наличие созданного снимка

![image](https://github.com/SlavaZakariev/diploma/blob/d1087af6d5ada6952153e77a4cff946a805a497f/images/dip_3_1.2.jpg)

6. Проверяем работоспособность нашего образа, запустив контейнер

![run](https://github.com/SlavaZakariev/diploma/blob/d1087af6d5ada6952153e77a4cff946a805a497f/images/dip_3_1.3.jpg)

7. Проверяем доступность страницы приложения

![web-index](https://github.com/SlavaZakariev/diploma/blob/main/images/dip_3_1.4.jpg)

8. Публикуем наш снимок в DockerHub

![push-dockerhub](https://github.com/SlavaZakariev/diploma/blob/d1087af6d5ada6952153e77a4cff946a805a497f/images/dip_3_1.5.jpg)

9. Проверяем наличие нашего снимка в [DockerHub](https://hub.docker.com/r/slavazakariev/nginx-app/tags)

![check-dockerhub](https://github.com/SlavaZakariev/diploma/blob/main/images/dip_3_1.6.jpg)

10. Снимок с тэгом `v1.0.0` доступен для скачивания по команде:

```bash
docker pull slavazakariev/nginx-app:v1.0.0
```

---

### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).

2. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ на 80 порту к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ на 80 порту к тестовому приложению.

---

### Решение 4

1. Создаём пространство имён `monitoring` на созданном нами кластере Кубернетес в YC

![ns](https://github.com/SlavaZakariev/diploma/blob/main/images/dip_4_1.1.jpg)

2. Устанавливаем HELM для удобства разворачивания приложений в Кубернетесе

![helm](https://github.com/SlavaZakariev/diploma/blob/main/images/dip_4_1.2.jpg)

3. Устанавливаем репозиторий `prometheus-community` с помощью HELM и обновляем репозиторий

![helm-repo](https://github.com/SlavaZakariev/diploma/blob/main/images/dip_4_1.3.jpg)

4. Устанавливаем готовый пакет `grafana + prometheus + alertingmanager` в пространстве имён `monitoring` с помощью HELM

![helm-install](https://github.com/SlavaZakariev/diploma/blob/main/images/dip_4_1.4.jpg)

5. Проверяем наличие на кластере вновь созданных объектов системы мониторинга в пространстве имён `monitoring`

![get-pods-monit](https://github.com/SlavaZakariev/diploma/blob/main/images/dip_4_1.5.jpg)

6. Для `prometheus` и `grafana` изменяем вручную порты и тип сервиса для возможности доступа к ним

![svc-port](https://github.com/SlavaZakariev/diploma/blob/main/images/dip_4_1.6.jpg)

7. Веб-страница [prometheus](http://89.169.128.19:30010/query)

![web-prometheus](https://github.com/SlavaZakariev/diploma/blob/main/images/dip_4_1.7.jpg)

8. Веб-страница [gragana](http://89.169.128.19:30020)

![web-grafana](https://github.com/SlavaZakariev/diploma/blob/main/images/dip_4_1.8.jpg)

9. Создадим [deployment.yaml](https://github.com/SlavaZakariev/diploma/blob/main/kubernetes/nginx-app/deployment.yaml) для нашего приложения `nginx-app` на порту 30080

```yaml
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: myapp
  namespace: monitoring
  labels:
    app: myapp
spec:
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: slavazakariev/nginx-app:v1.0.0
      restartPolicy: Always

---
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
  namespace: monitoring
spec:
  selector:
    app: myapp
  type: NodePort
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30080
```

10. Развернём приложение в пространство имён `monitoring`

![deploy](https://github.com/SlavaZakariev/diploma/blob/main/images/dip_4_1.9.jpg)

11. Проверим доступность приложение по ссылке: [http://89.169.128.19:30080/](http://89.169.128.19:30080/)

![nginx-app-check](https://github.com/SlavaZakariev/diploma/blob/main/images/dip_4_1.10.jpg)

---

### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

---

### Решение 5

1. Создаём новый репозиторий [diploma_cicd](https://github.com/SlavaZakariev/diploma_cicd) для конфигурирования CI\CD

2. Создаём токен на DockerHub для аутентификации при сборке.

![token](https://github.com/SlavaZakariev/diploma/blob/main/images/dip_5_1.1.jpg)

3. Добавляем пользователя, токен от DockerHub, а также конфигурационный файл нашего Kubernetes в GitHub для возможности полного цикла сборки и публикации CI\CD.

![token](https://github.com/SlavaZakariev/diploma/blob/main/images/dip_5_1.2.jpg)

---

## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)
