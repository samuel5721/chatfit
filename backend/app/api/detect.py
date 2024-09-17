#app/api/service.py
from ultralytics import YOLO
from typing import Dict, Any
import requests
import base64
import json
import os
import dotenv
import json

def load_valid_foods(file_path: str) -> set:
    with open(file_path, 'r') as f:
        food_data = [json.loads(line) for line in f]
    valid_foods = set()
    for entry in food_data:
        valid_foods.update(entry.get('food_items', [])) 
    return valid_foods



class FoodDetectionService:
    
    valid_foods = load_valid_foods('backend/app/weight/filtered_food_calories_no_partial_franchise.jsonl')

    @staticmethod
    def detect_food_with_gpt(img):
        base64_image = FoodDetectionService.encode_image_to_base64(img)

        headers = {
            "Content-Type": "application/json",
            "Authorization": "Bearer " + os.getenv("OPENAI_API_KEY")
        }

        # 음식 목록을 GPT에 전달하기 위한 텍스트 추가
        food_list_str = ', '.join(FoodDetectionService.valid_foods)
        
        payload = {
            "model": "gpt-4o-mini",
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": (
                                f"사진 안의 음식이 어떤 음식인지 알려줘. 그러나 너의 대답은 이 json의 음식 이름 중 하나로만 해야 해. {food_list_str}. "
                                "무조건 음식 이름만 위의 json 중 하나에서 알려줘야 해.\n"
                                "응답 형식은 다음과 같아.\n"
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

        # JSON 부분 추출 및 파싱
        start_index = content.find('{')
        end_index = content.rfind('}') + 1
        pure_json_str = content[start_index:end_index]

        try:
            pure_json = json.loads(pure_json_str)
        except json.JSONDecodeError as e:
            print("JSON 변환 중 오류 발생:", e)
            pure_json = {}

        # 응답에서 유효한 음식만 필터링
        detected_foods = pure_json.get('detected', [])
        filtered_foods = [food for food in detected_foods if food in FoodDetectionService.valid_foods]

        return {'detected': filtered_foods}
