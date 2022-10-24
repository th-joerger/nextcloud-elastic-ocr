#!/bin/bash

# Update to wanted version here and in Dockerfile

sudo docker build --tag thorjoerger/nextcloud:25.0.0 .
sudo docker push thorjoerger/nextcloud:25.0.0
