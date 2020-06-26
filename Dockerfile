FROM python:3.8.3-slim-buster

RUN mkdir -p /prometheus/ecs && \
    chown -R nobody /prometheus && \
    mkdir -p /opt/prometheus && \
    chown -R nobody /opt/prometheus

COPY requirements.txt /opt/prometheus
COPY discoverecs.py /opt/prometheus
RUN pip3 install -r /opt/prometheus/requirements.txt

USER nobody

ENTRYPOINT ["python", "/opt/prometheus/discoverecs.py", "--directory", "/prometheus/ecs"]
