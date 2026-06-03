import time
import logging
from fastapi import FastAPI, Request
import uvicorn

import json

app = FastAPI()

logger = logging.getLogger("pipeline-logger")
logger.setLevel(logging.INFO)
handler = logging.StreamHandler()
handler.setFormatter(logging.Formatter("%(message)s"))
logger.addHandler(handler)

@app.middleware("http")
async def log_requests(request: Request, call_next):
        start = time.time()
        response = await call_next(request)

        log_text = {
                "timestamp": start,
                "method": request.method,
                "path": request.url.path,
                "status": response.status_code,
                "user_agent": request.headers.get("user-agent"),
        }

        logger.info(json.dumps(log_text))

        return response

_PORT_ = 8080

@app.get("/")
async def heartBeat():
        return {
                "status": "healthy",
                "message": "No interruptions in the pipeline"
        }

if __name__ == "__main__":
        print(f"Server starting on port {_PORT_}", flush=True)
        uvicorn.run(app=app, host="0.0.0.0", port=_PORT_)