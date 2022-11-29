# syntax = docker/dockerfile:1.4
FROM python:3.11-slim-bullseye

# Install tini and security updates
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends tini && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

# Run as non-root user:
RUN useradd --create-home runner
USER runner

COPY . .

ENV PYTHONFAULTHANDLER=1


# Use tini as an init process:
ENTRYPOINT ["tini", "--", "python", "main.py"]
