#!/bin/bash

# Update to wanted version here and in Dockerfile

sudo docker build --tag thorjoerger/nextcloud:28.0.5 .
sudo docker push thorjoerger/nextcloud:28.0.5
