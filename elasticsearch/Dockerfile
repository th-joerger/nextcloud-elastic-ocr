FROM elasticsearch:7.17.5
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch ingest-attachment
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y tesseract-ocr tesseract-ocr-deu tesseract-ocr-eng

