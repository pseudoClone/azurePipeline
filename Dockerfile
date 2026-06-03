FROM python:3.12-alpine

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /pipeline

RUN uv pip install --system fastapi uvicorn

COPY application/serveAndLog.py .

EXPOSE 8080

CMD ["python", "-u", "serveAndLog.py"]