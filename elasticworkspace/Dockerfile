FROM python:3.7-alpine

ADD main.py requirements.txt /src/

WORKDIR /src

RUN pip install -r requirements.txt

CMD ["python", "main.py", "start"]