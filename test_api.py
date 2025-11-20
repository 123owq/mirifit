"""API 테스트 스크립트"""
import requests
import base64
from PIL import Image
import io


# API 서버 URL
API_URL = "https://mirifit.shop"


def test_health():
    """헬스 체크 테스트"""
    print("=" * 60)
    print("헬스 체크 테스트")
    print("=" * 60)

    response = requests.get(f"{API_URL}/health")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    print()


def test_predict_weight():
    """체중 예측 테스트"""
    print("=" * 60)
    print("체중 예측 테스트")
    print("=" * 60)

    data = {
        "current_weight": 80.0,
        "height": 175.0,
        "age": 30,
        "sex": "male",
        "daily_calories_burned": 500,
        "daily_calories_intake": 2000,  # Optional
        "days": 90
    }

    response = requests.post(f"{API_URL}/predict-weight", data=data)

    if response.status_code == 200:
        result = response.json()
        print("✓ 예측 성공!")
        print(f"\n현재 체중: {result['prediction']['current_weight_kg']} kg")
        print(f"예상 체중 (90일 후): {result['prediction']['predicted_weight_kg']:.1f} kg")
        print(f"체중 변화: {result['prediction']['weight_change_kg']:+.1f} kg")
        print(f"\n칼로리 정보:")
        print(f"  - 소비: {result['calories']['daily_calories_burned']} kcal")
        print(f"  - 섭취: {result['calories']['daily_calories_intake']} kcal")
        print(f"  - 적자: {result['calories']['daily_calorie_deficit']} kcal")
        print(f"\n현재 BMI: {result['current_stats']['bmi']}")
        print(f"예상 BMI: {result['predicted_stats']['bmi']}")
    else:
        print(f"✗ 실패: {response.status_code}")
        print(response.text)

    print()


def test_transform(image_path: str):
    """전체 파이프라인 테스트"""
    print("=" * 60)
    print("전체 파이프라인 테스트")
    print("=" * 60)

    # 이미지 파일 열기
    with open(image_path, 'rb') as f:
        files = {'image': f}
        data = {
            "sex": "male",
            "height": 175.0,
            "current_weight": 80.0,
            "age": 30,
            "daily_calories_burned": 500,
            # "daily_calories_intake": 2000,  # Optional - 없으면 자동 계산
            "days": 90,
            "belly_size": 0.0,
            "return_format": "base64"
        }

        print("요청 전송 중...")
        response = requests.post(f"{API_URL}/transform", files=files, data=data)

    if response.status_code == 200:
        result = response.json()
        print("✓ 변형 성공!")

        # 예측 정보
        pred = result['prediction']
        print(f"\n체중 예측:")
        print(f"  현재: {pred['current_weight_kg']} kg")
        print(f"  예상: {pred['predicted_weight_kg']:.1f} kg ({pred['days']}일 후)")
        print(f"  변화: {pred['weight_change_kg']:+.1f} kg")

        # 칼로리 정보
        cal = result['calories']
        print(f"\n칼로리:")
        print(f"  소비: {cal['daily_calories_burned']} kcal")
        print(f"  섭취: {cal['daily_calories_intake']} kcal")
        print(f"  적자: {cal['daily_calorie_deficit']} kcal/day")

        # 체성분
        print(f"\n체성분 변화:")
        print(f"  현재 BMI: {result['current_stats']['bmi']} → {result['predicted_stats']['bmi']}")
        print(f"  현재 체지방률: {result['current_stats']['body_fat_percentage']}% → {result['predicted_stats']['body_fat_percentage']}%")

        # 이미지 저장
        if 'images' in result:
            print("\n이미지 저장 중...")

            # 원본 이미지
            original_data = base64.b64decode(result['images']['original'])
            original_img = Image.open(io.BytesIO(original_data))
            original_img.save("output_original.png")
            print("  ✓ output_original.png")

            # 메쉬 이미지
            mesh_data = base64.b64decode(result['images']['mesh'])
            mesh_img = Image.open(io.BytesIO(mesh_data))
            mesh_img.save("output_mesh.png")
            print("  ✓ output_mesh.png")

            # 변형된 이미지
            transformed_data = base64.b64decode(result['images']['transformed'])
            transformed_img = Image.open(io.BytesIO(transformed_data))
            transformed_img.save("output_transformed.png")
            print("  ✓ output_transformed.png")

            print("\n모든 이미지 저장 완료!")
    else:
        print(f"✗ 실패: {response.status_code}")
        print(response.text)

    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("Body Shape Transformation API 테스트")
    print("=" * 60 + "\n")

    # 1. 헬스 체크
    test_health()

    # 2. 체중 예측
    test_predict_weight()

    # 3. 전체 파이프라인
    # 이미지 경로를 실제 파일로 변경하세요
    test_transform("20251103.png")

    print("=" * 60)
    print("테스트 완료!")
    print("=" * 60)
    print("\n전체 파이프라인을 테스트하려면:")
    print("  test_transform('your_image.jpg')")
    print("주석을 해제하고 실행하세요.")
