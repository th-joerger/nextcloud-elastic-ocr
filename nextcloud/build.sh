#!/bin/bash

# Update to wanted version

sudo docker build --tag thorjoerger/nextcloud:24.0.3 .
sudo docker push thorjoerger/nextcloud:24.0.3
