from fastapi import FastAPI

app = FastAPI(title="AI Chat Analysis Service")

@app.get("/health")
def health_check():
    return {"status": "ok", "ai_model": "gemini-2.0-flash"}
