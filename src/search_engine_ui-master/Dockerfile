FROM python:3.6-alpine

RUN apk --no-cache add gcc musl-dev
RUN apk add --no-cache bash

ENV APP_HOME /opt/se_ui

RUN mkdir $APP_HOME
ADD . $APP_HOME
WORKDIR $APP_HOME/ui

RUN pip install -r ../requirements.txt -r ../requirements-test.txt

ENV MONGO srv-mongodb
ENV MONGO_PORT 27017
ENV FLASK_APP ui.py

EXPOSE 8000

CMD ["gunicorn", "ui:app", "-b", "0.0.0.0"]