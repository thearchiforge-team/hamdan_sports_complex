from fastapi import FastAPI
from src.routes import router as domain_router

app = FastAPI(
    title="Shared Team Blueprints API",
    version="1.0.0",
    description="Initialized by The ArchiForge Governed Spec-to-Repo Engine",
)

app.include_router(domain_router)


@app.get("/health", tags=["System"])
async def health_check():
    return {"status": "healthy", "service": "Shared Team Blueprints", "governed_by": "ArchiForge"}
