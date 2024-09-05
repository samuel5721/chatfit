#app/api/controller.py
from fastapi import APIRouter, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
import numpy as np
import cv2
from app.api.detect import FoodDetectionService


api_router = APIRouter()

# Initialize the model in a global scope
model = FoodDetectionService.initialize_model("backend/app/weight/yolov8s.pt")

@api_router.post("/detect_cnn")
async def detect_objects(image: UploadFile = File(...)):
    try:
        contents = await image.read()
        nparr = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        if img is None:
            raise HTTPException(status_code=400, detail="Invalid image file")
        result = FoodDetectionService.detect_food(img, model)
        return JSONResponse(status_code=200, content=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@api_router.post("/detect_gpt")
async def detect_objects(image: UploadFile = File(...)):
    try:
        img = await image.read()
        if img is None:
            raise HTTPException(status_code=400, detail="Invalid image file")
        result = FoodDetectionService.detect_food_with_gpt(img)
        return JSONResponse(status_code=200, content=result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))