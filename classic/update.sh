#!/bin/sh

kubectl create configmap influxdb-config --from-file=configmaps/influxdb/ --dry-run -o=yaml | kubectl replace -f -
kubectl create configmap grafana-provisioning-datasources --from-file=configmaps/grafana/grafana-provisioning-datasources.yaml --dry-run -o=yaml | kubectl replace -f -
kubectl create configmap grafana-provisioning-dashboards --from-file=configmaps/grafana/grafana-provisioning-dashboards.yaml --dry-run -o=yaml | kubectl replace -f -
kubectl create configmap grafana-dashboards --from-file=configmaps/grafana/dashboards/ --dry-run -o=yaml | kubectl replace -f -
kubectl create configmap sensu-enterprise-defaults --from-file=configmaps/sensu-enterprise/server/ --dry-run -o=yaml | kubectl replace -f -
kubectl create configmap sensu-enterprise-checks --from-file=configmaps/sensu-enterprise/checks/ --dry-run -o=yaml | kubectl replace -f -
kubectl create configmap sensu-enterprise-handlers --from-file=configmaps/sensu-enterprise/handlers/ --dry-run -o=yaml | kubectl replace -f -
kubectl create configmap sensu-enterprise-integrations --from-file=configmaps/sensu-enterprise/integrations/ --dry-run -o=yaml | kubectl replace -f -
kubectl create configmap sensu-enterprise-dashboard-config --from-file=configmaps/sensu-enterprise-dashboard/dashboard.json --dry-run -o=yaml | kubectl replace -f -
kubectl create configmap sensu-client-defaults --from-file=configmaps/sensu-client/defaults.json --dry-run -o=yaml | kubectl replace -f -
kubectl create configmap sensu-client-daemonset --from-file=configmaps/sensu-client/daemonsets.json --dry-run -o=yaml | kubectl replace -f -
kubectl apply -f=deploy/sensu-enterprise/
kubectl apply -f=deploy/daemonsets/
kubectl apply -f=deploy/influxdb/
kubectl apply -f=deploy/grafana/
kubectl apply -f=deploy/network-device/
kubectl apply -f=deploy/service-a/
kubectl patch deployment sensu-enterprise --patch "{\"spec\": {\"template\": {\"metadata\": {\"labels\": {\"timestamp\": \"$(date +%s)\"}}}}}"
