FROM python:3.15.0b1-alpine3.23

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /pipeline

RUN uv pip install --system fastapi uvicorn

COPY application/serveAndLog.py .

EXPOSE 8080

CMD ["python", "-u", "serveAndLog.py"]