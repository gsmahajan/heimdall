#! /bin/bash
export LMOTEL_ENDPOINT="http://localhost:55680"
export OTEL_RESOURCE_ATTRIBUTES=service.namespace=topology-service,service.name=portal,host.name=mac,resource.type=docker
opentelemetry-instrument  python tracer.py
