FROM python:3.15.0b1-alpine3.23

WORKDIR /pipeline

COPY application/serveAndLog.py .

EXPOSE 8080

CMD ["python", "-u", "serveAndLog.py"]