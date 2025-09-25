from fastapi import FastAPI
import os, socket

app = FastAPI(title="ACA Demo")

@app.get("/")
def root():
    return {
        "message": "Hello from Azure Container Apps 👋",
        "host": socket.gethostname(),
        "env_message": os.getenv("MESSAGE", "no MESSAGE env set"),
    }

@app.get("/healthz")
def health():
    return {"status": "ok"}
