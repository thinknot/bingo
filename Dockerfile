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

# Use tini when running as CLI app
CMD ["tini", "--", "python", "main.py"]
