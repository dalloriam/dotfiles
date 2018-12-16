FROM python:3.7-alpine

LABEL maintainer="William Dussault <dalloriam@gmail.com>"

ADD main.py requirements.txt /src/

WORKDIR /src

RUN pip install -r requirements.txt

ENTRYPOINT ["python", "main.py", "start"]