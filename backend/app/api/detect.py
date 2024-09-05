#app/api/service.py
from ultralytics import YOLO
from typing import Dict, Any
import requests
import base64
import json
import os
import dotenv


class FoodDetectionService:


    @staticmethod
    def encode_image_to_base64(image_bytes):
        return base64.b64encode(image_bytes).decode('utf-8')

    @staticmethod
    def initialize_model(model_path: str) -> YOLO:
        return YOLO(model_path)

    @staticmethod
    def detect_food_with_gpt(img):
    # Base64로 이미지를 인코딩
        base64_image = FoodDetectionService.encode_image_to_base64(img)

        headers = {
            "Content-Type": "application/json",
            "Authorization": "Bearer " + os.getenv("OPENAI_API_KEY")
        }

        payload = {
            "model": "gpt-4o-mini",
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": (
                                "Tell me about the foods in this image. Please return in JSON format and only JSON.\n"
                                "JSON structure:\n"
                                "{'detected': [food1, food2, food3, ....]}"
                            )
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{base64_image}"
                            }
                        }
                    ]
                }
            ],
            "max_tokens": 4096
        }

        response = requests.post("https://api.openai.com/v1/chat/completions", headers=headers, json=payload)
        content = response.json()['choices'][0]['message']['content']
        
        # 불필요한 문자열을 제거하여 순수 JSON 추출
        start_index = content.find('{')
        end_index = content.rfind('}') + 1
        pure_json_str = content[start_index:end_index]

        # JSON 문자열을 딕셔너리로 변환
        try:
            pure_json = json.loads(pure_json_str)
        except json.JSONDecodeError as e:
            print("JSON 변환 중 오류 발생:", e)
            pure_json = {}

        return pure_json


    @staticmethod
    def detect_food(img, model: YOLO) -> Dict[str, Any]:
        results = model.predict(img)
        print(results)
        detected_items = []
        for b in results[0].boxes:
            cls = model.names[int(b.cls)]
            detected_items.append(cls)
        if not detected_items:
            detected_items = ['nothing detected']

        return {'detected': list(set(detected_items))}
    
