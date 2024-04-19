#!/bin/bash

# Update to wanted version here and in Dockerfile

sudo docker build --tag thorjoerger/nextcloud:26.0.13 .
sudo docker push thorjoerger/nextcloud:26.0.13
