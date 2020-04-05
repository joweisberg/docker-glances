# Docker Glances - System monitoring

![version](https://img.shields.io/pypi/v/glances.svg)![](https://pypi.python.org/pypi/Glances)
![downloads](https://pepy.tech/badge/glances/month)![](https://pepy.tech/project/glances)

**Glances** is a cross-platform monitoring tool which aims to present a large amount of monitoring information through a curses or Web based interface. The information dynamically adapts depending on the size of the user interface.

A Glances container is available. It includes the latest development HEAD version. You can use it to monitor your server and all your other containers!

This is a fork of [nicolargo/glances](https://github.com/nicolargo/glances)

![webui](https://raw.githubusercontent.com/nicolargo/glances/develop/docs/_static/glances-responsive-webdesign.png)

## Available only for Docker

This Docker image uses the correct latest version!
- ``aarch64`` (Rapsberry Pi 4 B w/ Ubuntu 18.04 LTS, Docker 19.03)
- ``amd64`` (Linux Ubuntu 18.04 LTS, Docker 19.03)

## Requirements

- ``python 2.7,>=3.4``
- ``psutil>=5.3.0`` (better with latest version)

Optional dependencies:

- ``bernhard`` (for the Riemann export module)
- ``bottle`` (for Web server mode)
- ``cassandra-driver`` (for the Cassandra export module)
- ``couchdb`` (for the CouchDB export module)
- ``docker`` (for the Docker monitoring support) [Linux/macOS-only]
- ``elasticsearch`` (for the Elastic Search export module)
- ``hddtemp`` (for HDD temperature monitoring support) [Linux-only]
- ``influxdb`` (for the InfluxDB export module)
- ``kafka-python`` (for the Kafka export module)
- ``netifaces`` (for the IP plugin)
- ``nvidia-ml-py3`` (for the GPU plugin)
- ``pika`` (for the RabbitMQ/ActiveMQ export module)
- ``potsdb`` (for the OpenTSDB export module)
- ``prometheus_client`` (for the Prometheus export module)
- ``py-cpuinfo`` (for the Quicklook CPU info module)
- ``pygal`` (for the graph export module)
- ``pymdstat`` (for RAID support) [Linux-only]
- ``pySMART.smartx`` (for HDD Smart support) [Linux-only]
- ``pysnmp`` (for SNMP support)
- ``pystache`` (for the action script feature)
- ``pyzmq`` (for the ZeroMQ export module)
- ``requests`` (for the Ports, Cloud plugins and RESTful export module)
- ``scandir`` (for the Folders plugin) [Only for Python < 3.5]
- ``statsd`` (for the StatsD export module)
- ``wifi`` (for the wifi plugin) [Linux-only]
- ``zeroconf`` (for the autodiscover mode)

## Installation via Docker

Please follow the official documentation:

    https://docs.docker.com/install/

You can test with your web browser:

    http://localhost:61208

### Docker

Get the container:

```bash
$ docker pull joweisberg/glances
```
Run the container in *Web server mode* (notice the `GLANCES_OPT` environment variable setting parameters for the startup command):

```bash
$ docker run -d --restart="unless-stopped" -p 61208-61209:61208-61209 -e GLANCES_OPT="-w" -v /var/run/docker.sock:/var/run/docker.sock:ro --pid host joweisebrg/glances
```

### Docker Compose

```yml
version: "3.5"
services:
  glances:
    container_name: glances
    image: joweisberg/glances:latest
    restart: unless-stopped
    pid: host
    ports:
      - 61208:61208
    environment:
      - GLANCES_OPT=--webserver
    healthcheck:
      test: ["CMD", "/usr/bin/healthcheck"]
      interval: 30s
      timeout: 10s
      retries: 5
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
```
