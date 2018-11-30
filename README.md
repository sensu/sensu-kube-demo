# Sensu Kubernetes Monitoring Demo

## Prerequisites

1. __[Install Docker for Mac (Edge)](https://store.docker.com/editions/community/docker-ce-desktop-mac)__

2. __Enable Kubernetes (in the Docker for Mac preferences)__

<img src="https://github.com/sensu/sensu-kube-demo/raw/master/images/docker-kubernetes.png" width="600">

3. __Deploy the [Kubernetes NGINX Ingress Controller](https://github.com/kubernetes/ingress-nginx)__

   ```
   $ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml
   ```

   Then use the modified "ingress-nginx" Kubernetes Service definition (works with Docker for Mac):

   ```
   $ kubectl create -f classic/ingress-nginx/services/ingress-nginx.yaml
   ```

4. __Add hostnames to /etc/hosts__

   ```
   $ sudo vi /etc/hosts

   127.0.0.1       sensu.local webui.sensu.local sensu-enterprise.local dashboard.sensu-enterprise.local
   127.0.0.1       influxdb.local grafana.local dummy.local
   ```

5. __Create Kubernetes Ingress Resources__

   ```
   $ kubectl create -f classic/ingress-nginx/ingress/sensu-enterprise.yaml

   $ kubectl create -f go/ingress-nginx/ingress/sensu-go.yaml
   ```

6. __Deploy kube-state-metrics__

   ```
   $ git clone git@github.com:kubernetes/kube-state-metrics.git

   $ kubectl apply -f kube-state-metrics/kubernetes
   ```

7. __Download and install the Sensu CLI tool (sensuctl)__

   **On macOS**

   ```
   $ latest=$(curl -s https://storage.googleapis.com/sensu-binaries/latest.txt)

   $ curl -LO https://storage.googleapis.com/sensu-binaries/$latest/darwin/amd64/sensuctl

   $ chmod +x sensuctl

   $ sudo mv sensuctl /usr/local/bin/
   ```

   **On Debian/Ubuntu Linux**

   ```
   $ curl -s \
   https://packagecloud.io/install/repositories/sensu/beta/script.deb.sh \
   | sudo bash

   $ sudo apt-get install sensu-cli
   ```

   **On RHEL/CentOS Linux**

   ```
   $ curl -s \
   https://packagecloud.io/install/repositories/sensu/beta/script.rpm.sh \
   | sudo bash

   $ sudo yum install sensu-cli
   ```

## Sensu Go Demo

### Deploy Application

1. Deploy dummy app pods

   ```
   $ kubectl apply -f go/deploy/dummy.yaml

   $ kubectl get pods

   $ curl -i http://dummy.local
   ```

### Sensu Backend

1. Deploy Sensu Backend

   ```
   $ kubectl create -f go/deploy/sensu-backend.yaml

   $ kubectl get pods
   ```

2. Configure `sensuctl` to use the built-in "admin" user

   ```
   $ sensuctl configure
   ```

### Multitenancy

1. Create "demo" namespace

   ```
   $ sensuctl namespace create demo

   $ sensuctl config set-namespace demo
   ```

3. Create "dev" user role with full-access to the "demo" namespace

   ```
   $ sensuctl role create dev \
   --verb get,list,create,update,delete \
   --resource \* --namespace demo
   ```

4. Create "dev" role binding for "dev" group

   ```
   $ sensuctl role-binding create dev --role dev --group dev
   ```

5. Create "demo" user that is a member of the "dev" group

   ```
   $ sensuctl user create demo --interactive
   ```

6. Reconfigure `sensuctl` to use the "demo" user and "demo" namespace

   ```
   $ sensuctl configure
   ```

### Deploy InfluxDB

1. Create a Kubernetes ConfigMap for InfluxDB configuration

   ```
   $ kubectl create configmap influxdb-config --from-file go/configmaps/influxdb.conf
   ```

2. Deploy InfluxDB with a Sensu Agent sidecar

    ```
    $ kubectl create -f go/deploy/influxdb.sensu.yaml

    $ kubectl get pods

    $ sensuctl entity list
    ```

### Sensu InfluxDB Event Handler

1. Register a Sensu 2.0 Asset for influxdb handler

   ```
   $ cat go/config/assets/influxdb-handler.json

   $ sensuctl create -f go/config/assets/influxdb-handler.json

   $ sensuctl asset info influxdb-handler
   ```

2. Create "influxdb" event handler for sending Sensu 2.0 metrics to InfluxDB

   ```
   $ cat go/config/handlers/influxdb.json

   $ sensuctl create -f go/config/handlers/influxdb.json

   $ sensuctl handler info influxdb
   ```

### Deploy Application

1. Deploy dummy app Sensu Agent sidecars

   ```
   $ kubectl apply -f go/deploy/dummy.sensu.yaml

   $ kubectl get pods

   $ curl -i http://dummy.local
   ```

### Sensu Monitoring Checks

1. Register a Sensu 2.0 Asset for check plugins

   ```
   $ sensuctl create -f go/config/assets/check-plugins.json

   $ sensuctl asset info check-plugins
   ```

2. Create a check to monitor dummy app /healthz

   ```
   $ sensuctl create -f go/config/checks/dummy-app-healthz.json

   $ sensuctl check info dummy-app-healthz

   $ sensuctl event list
   ```

3. Toggle the dummy app /healthz status

   ```
   $ curl -iXPOST http://dummy.local/healthz

   $ sensuctl event list
   ```

### Prometheus Scraping

1. Register a Sensu 2.0 Asset for the Prometheus metric collector

   ```
   $ sensuctl create -f go/config/assets/prometheus-collector.json
   ```

2. Create a check to collect dummy app Prometheus metrics

   ```
   $ sensuctl create -f go/config/checks/dummy-app-prometheus.json

   $ sensuctl check info dummy-app-prometheus
   ```

3. Query InfluxDB to list the stored series

   ```
   $ curl -GET 'http://influxdb.local/query' --data-urlencode 'q=SHOW SERIES ON sensu'
   ```

### Deploy Grafana

1. Create Kubernetes ConfigMaps for Grafana configuration

   ```
   $ kubectl create configmap grafana-provisioning-datasources --from-file=./go/configmaps/grafana-provisioning-datasources.yaml

   $ kubectl create configmap grafana-provisioning-dashboards --from-file=./go/configmaps/grafana-provisioning-dashboards.yaml
   ```

2. Deploy Grafana with a Sensu Agent sidecar

    ```
    $ kubectl create -f go/deploy/grafana.sensu.yaml

    $ kubectl get pods

    $ sensuctl entity list
    ```

## Sensu Classic Demo

   ```
   $ kubectl create configmap sensu-enterprise-config --from-file=./classic/configmaps/sensu-enterprise-config.json

   $ kubectl create configmap sensu-enterprise-dashboard-config --from-file=./classic/configmaps/sensu-enterprise-dashboard-config.json

   $ kubectl create configmap sensu-client-config --from-file=./classic/configmaps/sensu-client-config.json

   $ kubectl create configmap influxdb-config --from-file=./classic/configmaps/influxdb.conf

   $ kubectl create configmap grafana-provisioning-datasources --from-file=./classic/configmaps/grafana-provisioning-datasources.yaml

   $ kubectl create configmap grafana-provisioning-dashboards --from-file=./classic/configmaps/grafana-provisioning-dashboards.yaml

   $ kubectl create configmap grafana-dashboards --from-file=./classic/configmaps/grafana-dashboards
   ```

   ```
   $ kubectl apply -f classic/deploy/node-exporter-daemonset.yaml

   $ kubectl apply -f classic/deploy/sensu-redis.yaml

   $ kubectl apply -f classic/deploy/sensu-enterprise.yaml

   $ kubectl apply -f classic/deploy/sensu-enterprise-dashboard.yaml

   $ kubectl apply -f classic/deploy/influxdb.sensu.yaml

   $ kubectl apply -f classic/deploy/grafana.yaml

   $ kubectl apply -f classic/deploy/sensu-client-daemonset.yaml

   $ kubectl apply -f classic/deploy/dummy.sensu.yaml
   ```
