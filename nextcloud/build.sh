#!/bin/bash

# Update to wanted version here and in Dockerfile

sudo docker build --tag thorjoerger/nextcloud:27.1.8 .
sudo docker push thorjoerger/nextcloud:27.1.8
