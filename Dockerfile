FROM python:3.15.0b1-alpine3.23

WORKDIR /pipeline

COPY application/serverAndLog.py .

EXPOSE 8080

CMD ["python", "-u", "serverAndLog.py"]