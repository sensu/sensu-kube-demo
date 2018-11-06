#!/bin/bash

kubectl delete deployment dummy
kubectl delete service dummy

kubectl delete daemonset sensu-agent

kubectl delete daemonset node-exporter

kubectl delete deployment grafana
kubectl delete service grafana

kubectl delete deployment influxdb
kubectl delete service influxdb

kubectl delete deployment sensu-backend
kubectl delete service sensu-backend
