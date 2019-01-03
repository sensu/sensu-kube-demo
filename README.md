# Sensu Kubernetes Monitoring Demo

## Prerequisites

- Kubernetes
- A functional Kubernetes Ingress Controller (included with most hosted
  Kubernetes offerings, such as GKE)

## Configure Kubernetes

### Install Kube State Metrics

1. Deploy `kube-state-metrics`:

   ```
   $ git clone git@github.com:kubernetes/kube-state-metrics.git

   $ kubectl apply -f kube-state-metrics/kubernetes
   ```

   _NOTE: Google Kubernetes Engine (GKE) Users - GKE has strict role permissions
   that will prevent the kube-state-metrics roles and role bindings from being
   created. To work around this, you can give your GCP identity the
   `cluster-admin` role by running the following one-liner (before deploying
   `kube-state-metrics`; if you ran the above command and received an error, try
   it again after granting your GCP identity `cluster-admin` privileges):_

   ```
   $ kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud info | grep Account | cut -d '[' -f 2 | cut -d ']' -f 1)
   ```

## Sensu Classic Demo

1. Deploy Redis

   ```
   $ kubectl apply -f classic/deploy/sensu-redis-service.yaml
   $ kubectl apply -f classic/deploy/sensu-redis-deployment.yaml
   ```

1. Configure your environment to access private Docker images.

   The official Sensu Enterprise (classic) Docker images are only available from
   a private repository on Docker Hub. Kubernetes either needs to be configured
   to use private Docker Registry images, or a Docker image needs to be uploaded
   to a Docker registry that is accessible via Kubernetes (e.g. such as Google
   Container Registry for GKE users).

   The Kubernetes Deployment definition in `classic/deploy/sensu-enterprise-deployment.yaml`
   references a Private Docker image
   ([https://hub.docker.com/r/sensu/sensu-classic-enterprise/][sensu-classic-enterprise]).

   To configure Kubernetes to pull this image (or any other private images
   hosted in a Docker container registry), create a Kubernetes secret as
   follows:

   ```
   $ kubectl create secret docker-registry docker-registry-creds --docker-server=https://index.docker.io/v1/ --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email>
   ```

   _NOTE: replace `<your-name`, `<your-pword>`, and `<your-email>` with your
   Docker Hub username, password, and email address._

   Reference: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/

   [sensu-classic-enterprise]: https://hub.docker.com/r/sensu/sensu-classic-enterprise/

1. Configure and deploy Sensu Enterprise and the Sensu Enterprise Dashboard

   ```
   $ kubectl create configmap sensu-enterprise-defaults --from-file=./classic/configmaps/sensu-enterprise/defaults/
   $ kubectl create configmap sensu-enterprise-checks --from-file=./classic/configmaps/sensu-enterprise/checks/
   $ kubectl create configmap sensu-enterprise-handlers --from-file=./classic/configmaps/sensu-enterprise/handlers/
   $ kubectl create configmap sensu-enterprise-integrations --from-file=./classic/configmaps/sensu-enterprise/integrations/
   $ kubectl create configmap sensu-enterprise-dashboard-config --from-file=./classic/configmaps/sensu-enterprise-dashboard/dashboard.json
   $ kubectl create configmap sensu-client-defaults --from-file=./classic/configmaps/sensu-client/defaults.json
   $ kubectl apply -f classic/deploy/sensu-enterprise/
   ```

   > _PROTIP: to edit and replace, or add new configuration files to a configmap,
   rerun any of the above commands with `-o yaml --dry-run | kubectl replace -f
   -` appended on the end; for example:._
   >
   > ```
   > $ kubectl create configmap sensu-enterprise-checks --from-file=./classic/configmaps/sensu-enterprise/checks/ -o yaml --dry-run | kubectl replace -f -
   > ```
   >
   > _This instructs kubernetes to do a dry run (`--dry-run`) of the `create
   > configmap` command and output the resulting yaml (`-o yaml`), which can be
   > piped to `kubectl replace -f` using the bash `-` syntax (a synonym for
   > `/dev/stdin`).


1. Configure and deploy InfluxDB

   ```
   $ kubectl create configmap influxdb-config --from-file=./classic/configmaps/influxdb/influxdb.conf
   $ kubectl apply -f classic/deploy/influxdb/
   ```

1. Configure and deploy Grafana

   ```
   $ kubectl create configmap grafana-provisioning-datasources --from-file=./classic/configmaps/grafana/grafana-provisioning-datasources.yaml
   $ kubectl create configmap grafana-provisioning-dashboards --from-file=./classic/configmaps/grafana/grafana-provisioning-dashboards.yaml
   $ kubectl create configmap grafana-dashboards --from-file=./classic/configmaps/grafana/dashboards
   $ kubectl apply -f classic/deploy/grafana/
   ```

1. Deploy Prometheus Node Exporters

   ```
   $ kubectl apply -f classic/deploy/node-exporter/
   ```

1. Deploy Sensu Client daemonsets

   ```
   $ kubectl apply -f classic/deploy/sensu-client/
   ```

1. Deploy an application

   ```
   $ kubectl apply -f classic/deploy/dummy-backend/
   ```

-----

## Sensu Go Demo

### Install the Sensu CLI

1. __Download and install the Sensu CLI tool (sensuctl)__

   **On macOS**

   ```
   $ curl -LO https://s3-us-west-2.amazonaws.com/sensu.io/sensu-go/5.0.0/sensu-go-5.0.0-darwin-amd64.tar.gz

   $ tar -xvf sensu-go-5.0.0-darwin-amd64.tar.gz

   $ sudo cp bin/sensuctl /usr/local/bin/
   ```

   **On Debian/Ubuntu Linux**

   ```
   $ curl -s \
   https://packagecloud.io/install/repositories/sensu/stable/script.deb.sh \
   | sudo bash

   $ sudo apt-get install sensu-go-cli
   ```

   **On RHEL/CentOS Linux**

   ```
   $ curl -s \
   https://packagecloud.io/install/repositories/sensu/stable/script.rpm.sh \
   | sudo bash

   $ sudo yum install sensu-go-cli
   ```

### Deploy an Application

1. Deploy dummy app pods

   ```
   $ kubectl apply -f go/deploy/dummy.yaml

   $ kubectl get pods

   $ curl -i http://dummy.local
   ```

### Deploy the Sensu Backend

1. Deploy Sensu Backend

   ```
   $ kubectl apply -f go/deploy/sensu-backend.yaml

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

   $ sensuctl namespace list

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
    $ kubectl apply -f go/deploy/influxdb.sensu.yaml

    $ kubectl get pods

    $ sensuctl entity list
    ```

### Sensu InfluxDB Event Handler

1. Register a Sensu 2.0 Asset for influxdb handler

   ```
   $ cat go/config/assets/influxdb-handler.yaml

   $ sensuctl create -f go/config/assets/influxdb-handler.yaml

   $ sensuctl asset info influxdb-handler
   ```

2. Create "influxdb" event handler for sending Sensu 2.0 metrics to InfluxDB

   ```
   $ cat go/config/handlers/influxdb.yaml

   $ sensuctl create -f go/config/handlers/influxdb.yaml

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
   $ sensuctl create -f go/config/assets/check-plugins.yaml

   $ sensuctl asset info check-plugins
   ```

2. Create a check to monitor dummy app /healthz

   ```
   $ sensuctl create -f go/config/checks/dummy-app-healthz.yaml

   $ sensuctl check info dummy-app-healthz

   $ sensuctl event list
   ```

3. Toggle the dummy app /healthz status

   ```
   $ curl -i -XPOST http://dummy.local/healthz

   $ sensuctl event list
   ```

### Prometheus Scraping

1. Register a Sensu 2.0 Asset for the Prometheus metric collector

   ```
   $ sensuctl create -f go/config/assets/prometheus-collector.yaml
   ```

2. Create a check to collect dummy app Prometheus metrics

   ```
   $ sensuctl create -f go/config/checks/dummy-app-metrics.yaml

   $ sensuctl check info dummy-app-metrics
   ```

3. Query InfluxDB to list the stored series

   ```
   $ curl -GET 'http://influxdb.local/query' --data-urlencode 'q=SHOW SERIES ON sensu'
   ```

4. Deploy Sensu Agent as a DaemonSet

   ```
   $ kubectl apply -f go/deploy/sensu-agent-daemonset.yaml
   ```

5. Create checks to collect Kubernetes metrics

   ```
   $ kubectl apply -f go/config/checks/node-exporter-metrics.yaml
   $ kubectl apply -f go/config/checks/kube-state-metrics.yaml
   $ kubectl apply -f go/config/checks/kubelet-metrics.yaml
   $ kubectl apply -f go/config/checks/cadvisor-metrics.yaml
   ```

### Deploy Grafana

1. Create Kubernetes ConfigMaps for Grafana configuration

   ```
   $ kubectl create configmap grafana-provisioning-datasources --from-file=./go/configmaps/grafana-provisioning-datasources.yaml

   $ kubectl create configmap grafana-provisioning-dashboards --from-file=./go/configmaps/grafana-provisioning-dashboards.yaml
   ```

2. Deploy Grafana with a Sensu Agent sidecar

    ```
    $ kubectl apply -f go/deploy/grafana.sensu.yaml

    $ kubectl get pods

    $ sensuctl entity list
    ```
