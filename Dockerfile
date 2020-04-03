#
# Glances Dockerfile (based on Ubuntu)
#
# https://github.com/joweisberg/glances
#

# Pull base image.
FROM ubuntu
MAINTAINER Jonathan Weisberg <jo.weisberg@gmail.com>

# Install Pyhton packages.
RUN apt-get update && apt-get install -y --no-install-recommends \
    python \
    python-pip \
    python-setuptools \
    python-dev \
    gcc \
    libzmq3-dev \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN pip install --upgrade pip

# Install Glances (master branch)
RUN pip install glances psutil
RUN pip install glances[action,browser,cloud,cpuinfo,chart,docker,export,folders,gpu,ip,raid,snmp,web,wifi]

# Define working directory.
WORKDIR /glances

# EXPOSE PORT (For XMLRPC)
EXPOSE 61209

# EXPOSE PORT (For Web UI)
EXPOSE 61208

# Define default command.
CMD python -m glances -C /glances/conf/glances.conf $GLANCES_OPT
