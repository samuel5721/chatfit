# app/__init__.py
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from app.api.route import api_router


def create_app() -> FastAPI:
    app = FastAPI()
    # API 라우터 포함
    app.include_router(api_router, prefix="/api")

    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"], 
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    return app

app = create_app()
