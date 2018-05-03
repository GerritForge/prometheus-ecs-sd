# prometheus-ecs-sd
ECS Service Discovery for Prometheus

## Info
This tool provides Prometheus service discovery for Docker containers running on AWS ECS. You can easily instrument your app using a Prometheus
client and enable discovery adding an ENV variable at the Service Task Definition. Your container will then be added
to the list of Prometheus targets to be scraped. Requires python2, works with Prometheus 2.x.

## Setup
``discoverecs.py`` should run alongside the Prometheus server. It generates targets using JSON file service discovery. It can
be started by running:

``python discoverecs.py --directory /opt/prometheus-ecs`` 

Where ``/opt/prometheus-ecs`` is defined in your Prometheus config as a file_sd_config job:

```json
- job_name: 'ecs-1m'
  scrape_interval: 1m
  file_sd_configs:
    - files:
        - /opt/prometheus-ecs/1m-tasks.json
  relabel_configs:
    - source_labels: [metrics_path]
      action: replace
      target_label: __metrics_path__
      regex: (.+)
```

You can also specify a discovery interval with ``--interval`` (in seconds). Default is 60s. We also provide caching to minimize hitting query
rate limits with the AWS ECS API. ``discoverecs.py` runs in a loop until interrupted and will output target information to stdout.

To make your application discoverable by Prometheus, you need to set the following ENV variable in your task definition:

``{"name": "PROMETHEUS", "value": "true"}``

Metric path and scrape interval is supported via PROMETHEUS_ENDPOINT:

``"interval:/metric_path,..."``

Examples:

```
"5m:/mymetrics,30s:/mymetrics2"
"/mymetrics"
"30s:/mymetrics1,/mymetrics2"
```

Under ECS task definition (task.json):

``{"name": "PROMETHEUS_ENDPOINT", "value": "5m:/mymetrics,30s:/mymetrics2"}``

Available intervals: 15s, 30s, 1m, 5m.

Default metric path is /metrics. Default interval is 1m.

The following Prometheus configuration should be used to support all available intervals:

```json
  - job_name: 'ecs-15s'
    scrape_interval: 15s
    file_sd_configs:
      - files:
          - /opt/prometheus-ecs/15s-tasks.json
    relabel_configs:
      - source_labels: [metrics_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)

  - job_name: 'ecs-30s'
    scrape_interval: 30s
    file_sd_configs:
      - files:
          - /opt/prometheus-ecs/30s-tasks.json
    relabel_configs:
      - source_labels: [metrics_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)

  - job_name: 'ecs-1m'
    scrape_interval: 1m
    file_sd_configs:
      - files:
          - /opt/prometheus-ecs/1m-tasks.json
    relabel_configs:
      - source_labels: [metrics_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
        
  - job_name: 'ecs-5m'
    scrape_interval: 5m
    file_sd_configs:
      - files:
          - /opt/prometheus-ecs/5m-tasks.json
    relabel_configs:
      - source_labels: [metrics_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
```