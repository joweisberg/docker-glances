# Docker Glances - System monitoring

![version](https://img.shields.io/pypi/v/glances.svg)![](https://pypi.python.org/pypi/Glances)
![downloads](https://pepy.tech/badge/glances/month)![](https://pepy.tech/project/glances)

**Glances** is a cross-platform monitoring tool which aims to present a large amount of monitoring information through a curses or Web based interface. The information dynamically adapts depending on the size of the user interface.

A Glances container is available. It includes the latest development HEAD version. You can use it to monitor your server and all your other containers!

This is a fork of [nicolargo/glances](https://github.com/nicolargo/glances)

![webui](https://raw.githubusercontent.com/nicolargo/glances/develop/docs/_static/glances-responsive-webdesign.png)

## Requirements

- ``python>=3.4``
- ``psutil>=5.3.0`` (better with latest version)
- ``defusedxml`` (in order to monkey patch xmlrpc)
- ``future`` (for Python 2 support)

Glances version 4.0 will no longer supports Python 2.x

Optional dependencies:

- ``bernhard`` (for the Riemann export module)
- ``bottle`` (for Web server mode)
- ``cassandra-driver`` (for the Cassandra export module)
- ``chevron`` (for the action script feature)
- ``couchdb`` (for the CouchDB export module)
- ``docker`` (for the Docker monitoring support) [Linux/macOS-only]
- ``elasticsearch`` (for the Elastic Search export module)
- ``graphitesender`` (For the Graphite export module)
- ``hddtemp`` (for HDD temperature monitoring support) [Linux-only]
- ``influxdb`` (for the InfluxDB version 1 export module)
- ``influxdb-client``  (for the InfluxDB version 2 export module) [Only for Python >= 3.6]
- ``kafka-python`` (for the Kafka export module)
- ``netifaces`` (for the IP plugin)
- ``py3nvml`` (for the GPU plugin) [Only for Python 3]
- ``pika`` (for the RabbitMQ/ActiveMQ export module)
- ``potsdb`` (for the OpenTSDB export module)
- ``prometheus_client`` (for the Prometheus export module)
- ``py-cpuinfo`` (for the Quicklook CPU info module)
- ``pygal`` (for the graph export module)
- ``pymdstat`` (for RAID support) [Linux-only]
- ``pysnmp`` (for SNMP support)
- ``pySMART.smartx`` (for HDD Smart support) [Linux-only]
- ``pyzmq`` (for the ZeroMQ export module)
- ``requests`` (for the Ports, Cloud plugins and RESTful export module)
- ``scandir`` (for the Folders plugin) [Only for Python < 3.5]
- ``sparklines`` (for the Quick Plugin sparklines option)
- ``statsd`` (for the StatsD export module)
- ``wifi`` (for the wifi plugin) [Linux-only]
- ``zeroconf`` (for the autodiscover mode)

## Installation via Docker

Please follow the official documentation:

    https://docs.docker.com/install/

You can test with your web browser:

    http://localhost:61208

### Docker image platform / architecture

The Docker image to use `joweisberg/glances:amd64`.
Build on Linux Ubuntu 20.04 LTS, Docker 19.03 and above for:

| Platform | Architecture / Tags |
|---|---|
| x86_64 | amd64 |
| aarch64 | arm64 |
| arm | arm32 |

### Docker

Get the container:

```bash
$ docker pull joweisberg/glances:amd64
```
Run the container in *Web server mode* (notice the `GLANCES_OPT` environment variable setting parameters for the startup command):

```bash
$ docker run -d --restart="unless-stopped" -p 61208-61209:61208-61209 -e TZ="Europe/Paris" -e GLANCES_OPT="-w" -v /var/run/docker.sock:/var/run/docker.sock:ro --pid host joweisberg/glances:amd64
```

### Docker Compose

```yml
version: "3.5"
services:
  glances:
    container_name: glances
    image: joweisberg/glances:amd64
    restart: unless-stopped
    pid: host
    ports:
      - 61208:61208
    environment:
      - TZ=Europe/Paris
      - GLANCES_OPT=--webserver
    healthcheck:
      test: ["CMD", "/usr/bin/healthcheck"]
      interval: 30s
      timeout: 10s
      retries: 5
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /var/docker/glances:/glances/conf
```
