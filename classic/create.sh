#!/bin/sh

kubectl create configmap sensu-rabbitmq-config --from-file=configmaps/sensu-enterprise/rabbitmq/
kubectl create configmap sensu-enterprise-server --from-file=configmaps/sensu-enterprise/server/
kubectl create configmap sensu-enterprise-defaults --from-file=configmaps/sensu-enterprise/defaults/
kubectl create configmap sensu-enterprise-checks --from-file=configmaps/sensu-enterprise/checks/
kubectl create configmap sensu-enterprise-plugins --from-file=configmaps/sensu-enterprise/plugins/
kubectl create configmap sensu-enterprise-handlers --from-file=configmaps/sensu-enterprise/handlers/
kubectl create configmap sensu-enterprise-integrations --from-file=configmaps/sensu-enterprise/integrations/
kubectl create configmap sensu-enterprise-dashboard-config --from-file=configmaps/sensu-enterprise-dashboard/dashboard.json
kubectl create configmap sensu-client-defaults --from-file=configmaps/sensu-client/defaults.json
kubectl apply -f=deploy/sensu-enterprise/
kubectl apply -f=deploy/daemonsets/
kubectl apply -f=deploy/influxdb/
kubectl apply -f=deploy/grafana/
kubectl apply -f=deploy/dummy-backend/
