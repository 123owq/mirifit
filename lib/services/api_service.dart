import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = "https://mirifit.shop";


  /// 이미지와 사용자 데이터를 서버로 전송하여 이미지 변환을 요청합니다.
  ///
  /// [imageFile]은 변환할 이미지 파일입니다.
  /// [sex], [height], [currentWeight], [age], [dailyCaloriesBurned],
  /// [days], [bellySize]는 변환에 필요한 추가 데이터입니다.
  ///
  /// 성공 시, 서버로부터 받은 JSON 응답을 [Map<String, dynamic>] 형태로 반환합니다.
  /// 실패 시, 예외를 발생시킵니다.
  Future<Map<String, dynamic>> transformImage({
    required File imageFile,
    required String sex,
    required double height,
    required double currentWeight,
    required int age,
    required int dailyCaloriesBurned,
    int? dailyCaloriesIntake, // Optional
    required int days,
    double bellySize = 0.0,
    String returnFormat = "base64",
  }) async {
    final url = Uri.parse('$_baseUrl/transform');
    
    // Multipart 요청 생성
    var request = http.MultipartRequest('POST', url);

    // 텍스트 필드 추가
    request.fields['sex'] = sex;
    request.fields['height'] = height.toString();
    request.fields['current_weight'] = currentWeight.toString();
    request.fields['age'] = age.toString();
    request.fields['daily_calories_burned'] = dailyCaloriesBurned.toString();
    if (dailyCaloriesIntake != null) {
      request.fields['daily_calories_intake'] = dailyCaloriesIntake.toString();
    }
    request.fields['days'] = days.toString();
    request.fields['belly_size'] = bellySize.toString();
    request.fields['return_format'] = returnFormat;

    // 이미지 파일 추가
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
    ));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // UTF-8로 디코딩하여 JSON 파싱
        final responseBody = utf8.decode(response.bodyBytes);
        return json.decode(responseBody) as Map<String, dynamic>;
      } else {
        // 에러 처리
        throw Exception('Failed to transform image. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      // 네트워크 에러 등
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<Map<String, dynamic>> getFutureImage({
    required double targetWeight,
    required File imageFile,
    required String sex,
    required double height,
    required double currentWeight,
    required int age,
  }) async {
    final url = Uri.parse('$_baseUrl/future');
    
    // Multipart 요청 생성
    var request = http.MultipartRequest('POST', url);

    // 텍스트 필드 추가
    request.fields['target_weight'] = targetWeight.toString();
    request.fields['sex'] = sex;
    request.fields['height'] = height.toString();
    request.fields['current_weight'] = currentWeight.toString();
    request.fields['age'] = age.toString();

    // 이미지 파일 추가
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
    ));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // UTF-8로 디코딩하여 JSON 파싱
        final responseBody = utf8.decode(response.bodyBytes);
        return json.decode(responseBody) as Map<String, dynamic>;
      } else {
        // 에러 처리
        throw Exception('Failed to get future image. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      // 네트워크 에러 등
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
