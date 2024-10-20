#!/bin/bash

# Update to wanted version here and in Dockerfile

sudo docker build --tag thorjoerger/nextcloud:30.0.1 .
sudo docker push thorjoerger/nextcloud:30.0.1
