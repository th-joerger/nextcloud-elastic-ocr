#!/bin/bash

# Update to wanted version here and in Dockerfile

sudo docker build --tag thorjoerger/nextcloud:32.0.7 .
sudo docker push thorjoerger/nextcloud:32.0.7
