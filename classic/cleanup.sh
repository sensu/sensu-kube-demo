#!/bin/bash

kubectl delete deployment dummy
kubectl delete service dummy

kubectl delete deployment influxdb
kubectl delete service influxdb

kubectl delete deployment grafana
kubectl delete service grafana

kubectl delete deployment sensu-enterprise-dashboard
kubectl delete service sensu-enterprise-dashboard

kubectl delete daemonset sensu-client

kubectl delete daemonset node-exporter

kubectl delete deployment sensu-enterprise
kubectl delete service sensu-enterprise

kubectl delete deployment sensu-redis
kubectl delete service sensu-redis
