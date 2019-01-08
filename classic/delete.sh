#!/bin/sh

kubectl delete clusterrolebinding kube-state-metrics
kubectl delete clusterrole kube-state-metrics
kubectl delete rolebinding kube-state-metrics --namespace kube-system
kubectl delete role kube-state-metrics-resizer --namespace kube-system
kubectl delete serviceaccount kube-state-metrics --namespace kube-system
kubectl delete deployment kube-state-metrics --namespace kube-system
kubectl delete service kube-state-metrics --namespace kube-system

kubectl delete statefulset network-device
kubectl delete daemonset sensu-client
kubectl delete daemonset node-exporter
kubectl delete deployment sensu-enterprise
kubectl delete deployment sensu-enterprise-dashboard
kubectl delete deployment sensu-redis
kubectl delete deployment influxdb
kubectl delete deployment grafana
kubectl delete deployment service-a
kubectl delete deployment service-b
kubectl delete configmap influxdb-config
kubectl delete configmap grafana-provisioning-datasources
kubectl delete configmap grafana-provisioning-dashboards
kubectl delete configmap grafana-dashboards
kubectl delete configmap sensu-enterprise-defaults
kubectl delete configmap sensu-enterprise-checks
kubectl delete configmap sensu-enterprise-handlers
kubectl delete configmap sensu-enterprise-integrations
kubectl delete configmap sensu-enterprise-dashboard-config
kubectl delete configmap sensu-client-defaults
kubectl delete configmap sensu-client-daemonset
kubectl delete service sensu-enterprise
kubectl delete service sensu-enterprise-dashboard
kubectl delete service sensu-redis
kubectl delete service influxdb
kubectl delete service grafana
kubectl delete service network-device
kubectl delete service service-a
kubectl delete service service-b
