#!/bin/bash

. env.sh

function log {
	echo $(date +%D-%T) "$1"
}

function run_python {
  opentelemetry-instrument python3.9 tracer.py
}

function generateSpans {
 for port in {12000..12050}; do curl -m 7 localhost:$port/apm/random; done
 sleep 10
}

function fire {
for i in {1..1000}; do generateSpans; done
}
