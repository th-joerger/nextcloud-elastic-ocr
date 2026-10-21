#!/bin/bash

# Update to wanted version here and in Dockerfile

sudo docker build --tag thorjoerger/nextcloud:35.0.2 .
sudo docker push thorjoerger/nextcloud:35.0.2
