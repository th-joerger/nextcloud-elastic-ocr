#!/bin/bash

# Update to wanted version here and in Dockerfile

sudo docker build --tag thorjoerger/elasticsearch:7.17.27 .
sudo docker push thorjoerger/elasticsearch:7.17.27
