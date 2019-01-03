#!/bin/sh

kubectl create configmap sensu-rabbitmq-config --from-file=configmaps/sensu-enterprise/rabbitmq/ --dry-run -o=yaml | kubectl replace -f -
kubectl create configmap sensu-enterprise-defaults --from-file=configmaps/sensu-enterprise/server/ --dry-run -o=yaml | kubectl replace -f -
kubectl create configmap sensu-enterprise-checks --from-file=configmaps/sensu-enterprise/checks/ --dry-run -o=yaml | kubectl replace -f -
kubectl create configmap sensu-enterprise-plugins --from-file=configmaps/sensu-enterprise/plugins/ --dry-run -o=yaml | kubectl replace -f -
kubectl create configmap sensu-enterprise-handlers --from-file=configmaps/sensu-enterprise/handlers/ --dry-run -o=yaml | kubectl replace -f -
kubectl create configmap sensu-enterprise-integrations --from-file=configmaps/sensu-enterprise/integrations/ --dry-run -o=yaml | kubectl replace -f -
kubectl create configmap sensu-enterprise-dashboard-config --from-file=configmaps/sensu-enterprise-dashboard/dashboard.json --dry-run -o=yaml | kubectl replace -f -
kubectl create configmap sensu-client-defaults --from-file=configmaps/sensu-client/defaults.json --dry-run -o=yaml | kubectl replace -f -
kubectl apply -f=deploy/sensu-enterprise/
kubectl apply -f=deploy/daemonsets/
kubectl apply -f=deploy/influxdb/
kubectl apply -f=deploy/grafana/
kubectl apply -f=deploy/dummy-backend/
