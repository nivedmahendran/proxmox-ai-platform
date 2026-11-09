from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import httpx
import os

app = FastAPI(title="proxmox-ai demo-api", version="1.0.0")

# Ollama lives on the GPU-enabled ai-infer VM (private lab network) in
# production, but the container defaults to the co-located Ollama service so
# the demo works even without the GPU VM.
OLLAMA_URL = os.environ.get("OLLAMA_URL", "http://10.10.10.120:11434")
MODEL = os.environ.get("MODEL", "llama3.2:1b")


class ChatRequest(BaseModel):
    message: str


class ChatResponse(BaseModel):
    reply: str
    model: str


@app.get("/api/health")
async def health():
    try:
        async with httpx.AsyncClient(timeout=3) as client:
            r = await client.get(f"{OLLAMA_URL}/api/tags")
            r.raise_for_status()
        return {"status": "ok", "ollama": "reachable", "model": MODEL}
    except Exception as e:
        return {"status": "degraded", "ollama": str(e)}


@app.post("/api/chat", response_model=ChatResponse)
async def chat(req: ChatRequest):
    try:
        async with httpx.AsyncClient(timeout=120) as client:
            r = await client.post(
                f"{OLLAMA_URL}/api/generate",
                json={"model": MODEL, "prompt": req.message, "stream": False},
            )
            r.raise_for_status()
            data = r.json()
        return ChatResponse(reply=data["response"].strip(), model=MODEL)
    except httpx.HTTPError as e:
        raise HTTPException(status_code=502, detail=f"Ollama error: {e}")
