#!/bin/sh

kubectl create configmap influxdb-config --from-file=configmaps/influxdb/
kubectl create configmap grafana-provisioning-datasources --from-file=configmaps/grafana/grafana-provisioning-datasources.yaml
kubectl create configmap grafana-provisioning-dashboards --from-file=configmaps/grafana/grafana-provisioning-dashboards.yaml
kubectl create configmap grafana-dashboards --from-file=configmaps/grafana/dashboards/
kubectl create configmap sensu-enterprise-defaults --from-file=configmaps/sensu-enterprise/server/
kubectl create configmap sensu-enterprise-checks --from-file=configmaps/sensu-enterprise/checks/
kubectl create configmap sensu-enterprise-handlers --from-file=configmaps/sensu-enterprise/handlers/
kubectl create configmap sensu-enterprise-integrations --from-file=configmaps/sensu-enterprise/integrations/
kubectl create configmap sensu-enterprise-dashboard-config --from-file=configmaps/sensu-enterprise-dashboard/dashboard.json
kubectl create configmap sensu-client-defaults --from-file=configmaps/sensu-client/defaults.json
kubectl create configmap sensu-client-daemonset --from-file=configmaps/sensu-client/daemonsets.json
kubectl apply -f=deploy/kube-state-metrics/kubernetes/
kubectl apply -f=deploy/sensu-enterprise/
kubectl apply -f=deploy/daemonsets/
kubectl apply -f=deploy/influxdb/
kubectl apply -f=deploy/grafana/
kubectl apply -f=deploy/network-device/
kubectl apply -f=deploy/service-a/
kubectl apply -f=deploy/service-b/
