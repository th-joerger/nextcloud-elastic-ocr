#!/bin/bash

# Update to wanted version here and in Dockerfile

sudo docker build --tag thorjoerger/nextcloud:31.0.6 .
sudo docker push thorjoerger/nextcloud:31.0.6
