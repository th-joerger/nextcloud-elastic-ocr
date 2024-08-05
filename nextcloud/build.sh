#!/bin/bash

# Update to wanted version here and in Dockerfile

sudo docker build --tag thorjoerger/nextcloud:29.0.4 .
sudo docker push thorjoerger/nextcloud:29.0.4
