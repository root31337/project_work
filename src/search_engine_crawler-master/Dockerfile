FROM python:3.6-alpine

RUN apk add --no-cache bash

ENV APP_HOME /opt/se_crawler
RUN mkdir $APP_HOME
ADD . $APP_HOME
WORKDIR $APP_HOME

RUN pip install --no-cache-dir -r requirements.txt -r requirements-test.txt

ENV MONGO srv-mongodb
ENV MONGO_PORT 27017
ENV RMQ_HOST my-rabbit-rabbitmq-headless
ENV RMQ_QUEUE crawler
ENV RMQ_USERNAME user
ENV RMQ_PASSWORD crawler_pass
ENV CHECK_INTERVAL 10
ENV EXCLUDE_URLS '.*github.com'

EXPOSE 8000

CMD ["python", "-u", "crawler/crawler.py", "https://vitkhab.github.io/search_engine_test_site/"]