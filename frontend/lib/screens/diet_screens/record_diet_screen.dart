import 'dart:convert';
import 'dart:io';
import 'package:chatfit/components/buttons.dart';
import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/navigations.dart';
import 'package:chatfit/components/texts.dart';
import 'package:chatfit/module/cnn_food_convert.dart';
import 'package:chatfit/module/load_login.dart';
import 'package:chatfit/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  XFile? _image; // 이미지를 담을 변수 선언
  String _imageId = ''; // 이미지 이름을 담을 변수 선언
  String _imageUrl = '';
  final ImagePicker picker = ImagePicker(); // ImagePicker 초기화
  bool _isRecognizing = false; // 인식 상태를 추적하는 변수
  bool _isRecognized = false;
  bool _isSubmitting = false;
  bool _isSubmit = false;

  String time = ''; // will get in arguments
  String menu = '';

  // 이미지를 갤러리에서 가져오는 함수
  Future getImage() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        _image = XFile(pickedFile.path); // 가져온 이미지를 _image에 저장
      });
    }
  }

  // 이미지를 Firebase Storage에 업로드하는 함수
  Future<void> _uploadImage() async {
    if (_image == null) return;

    File file = File(_image!.path);

    setState(() {
      _imageId =
          '${DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '')}.png';
      _isSubmitting = true;
    });

    try {
      String? userEmail = await getUserEmail(context);

      if (userEmail.isEmpty) {
        throw Exception("User email is not available.");
      }

      final storageRef = FirebaseStorage.instance.ref();
      final mountainsRef = storageRef.child('uploads/$userEmail/$_imageId');

      await mountainsRef.putFile(file);

      _imageUrl = await mountainsRef.getDownloadURL();

      if (mounted && _imageUrl.isNotEmpty) {
        _recognizeDiet();
        setState(() {
          _isSubmitting = false;
          _isSubmit = true;
        });
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('파일 업로드 실패: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    }
  }

  Future _recognizeDiet() async {
    setState(() {
      _isRecognizing = true;
    });

    if (_image == null) return;

    try {
      File imageFile = File(_image!.path);

      // 이미지를 Multipart로 변환
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://3.38.71.7:8000/api/detect_cnn'), // 백엔드 엔드포인트
      );

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await http.Response.fromStream(response);

        // utf8 디코딩을 추가하여 깨짐 현상 해결
        String decodedBody = utf8.decode(responseBody.bodyBytes);

        print('응답 내용: $decodedBody'); // 응답 내용을 확인하기 위해 출력

        var jsonResponse = jsonDecode(decodedBody);

        if (jsonResponse['detected'].length == 0) {
          // GPT로 요청을 보내는 로직
          var gptRequest = http.MultipartRequest(
            'POST',
            Uri.parse('http://3.38.71.7:8000/api/detect_gpt'),
          );

          gptRequest.files.add(await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
          ));

          var gptResponse = await gptRequest.send();

          if (gptResponse.statusCode == 200) {
            var gptResponseBody = await http.Response.fromStream(gptResponse);

            // GPT 응답도 utf8 디코딩
            String gptDecodedBody = utf8.decode(gptResponseBody.bodyBytes);

            print('GPT 응답 내용: $gptDecodedBody');

            var gptJsonResponse = jsonDecode(gptDecodedBody);

            if (gptJsonResponse['detected'].length == 0) {
              setState(() {
                menu = '식단을 인식하지 못했어요.';
                _isRecognized = true;
              });
              return;
            }

            setState(() {
              menu = gptJsonResponse['detected'][0];
              _isRecognized = true;
            });
          } else {
            throw Exception(
                'Failed to recognize diet with GPT. Status code: ${gptResponse.statusCode}');
          }
        } else {
          //cnn으로 정의
          setState(() {
            menu = cnnMenuTranslations[jsonResponse['detected'][0]]!;
            _isRecognized = true;
          });
        }
      } else {
        throw Exception(
            'Failed to recognize diet. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
        print('오류: $e');
      }
    } finally {
      setState(() {
        _isRecognizing = false;
      });
    }
  }

  void _removeImage() async {
    if (_imageId != '') {
      try {
        String userEmail = await getUserEmail(context);

        final storageRef = FirebaseStorage.instance.ref();
        await storageRef.child('/uploads/$userEmail/$_imageId').delete();
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete file: ${e.message}')),
        );
      }
    }
  }

  void _onPopPressed() async {
    _removeImage();
    return;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getImage());
  }

  @override
  Widget build(BuildContext context) {
    time = ModalRoute.of(context)!.settings.arguments as String;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _onPopPressed();
        }
      },
      child: Scaffold(
        appBar: const Header(),
        body: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            children: [
              const Navigation(
                child: TitleText(text: '식단을 입력하세요!', fontSize: 20),
              ),
              (_isSubmitting)
                  ? const CircularProgressIndicator()
                  : (_isSubmit)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 20.h),
                            _buildReconizeDiet(),
                            SizedBox(height: 30.h),
                            _buildPhotoArea(context),
                            SizedBox(height: 20.h),
                            _buildWrite(),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 20.h),
                            _buildContinue(),
                            SizedBox(height: 30.h),
                            _buildPhotoArea(context),
                            SizedBox(height: 20.h),
                            _buildUpload(),
                          ],
                        )
            ],
          ),
        ),
      ),
    );
  }

  Column _inputImageBtns() {
    return Column(
      children: [
        const SizedBox(height: 20),
        PrimaryButton(
          text: '갤러리에서 열기',
          onPressed: () {
            getImage();
          },
        ),
      ],
    );
  }

  Widget _buildContinue() {
    return _isRecognizing
        ? const CircularProgressIndicator()
        : const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleText(text: '이 사진으로 계속할까요?'),
            ],
          );
  }

  Widget _buildUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrimaryButton(
          onPressed: _uploadImage,
          text: '계속하기',
        ),
        SizedBox(height: 15.h),
        SecondButton(
          onPressed: () {
            getImage();
          },
          text: "다시 선택하기",
        ),
      ],
    );
  }

  Widget _buildReconizeDiet() {
    return _isRecognizing
        ? const CircularProgressIndicator()
        : SizedBox(
            width: Layout.entireWidth(context) * 0.9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ContentText(text: '지금 드시고 있는 음식을'),
                TitleText(text: ' $menu', fontSize: 20),
                const ContentText(text: ' 로 인식했어요.'),
              ],
            ),
          );
  }

  Widget _buildPhotoArea(BuildContext context) {
    return SizedBox(
      child: (_image == null)
          ? Container(
              width: Layout.entireWidth(context) * 0.1,
              height: Layout.bodyHeight(context) * 0.1,
              color: KeyColor.grey200,
            )
          : Image.file(
              File(_image!.path),
              width: Layout.entireWidth(context) * 0.9,
              height: Layout.bodyHeight(context) * 0.5,
              fit: BoxFit.cover,
            ), // 가져온 이미지를 화면에 띄워주는 코드
    );
  }

  Widget _buildWrite() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrimaryButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/diet_write', arguments: {
              'imageId': _imageId,
              'imageUrl': _imageUrl,
              'menu': menu,
              'time': time
            });
          },
          text: '계속하기',
        ),
        SizedBox(height: 15.h),
        SecondButton(
          onPressed: () {
            Navigator.pushNamed(context, '/diet_hand_record', arguments: {
              'imageId': _imageId,
              'imageUrl': _imageUrl,
              'menu': '',
              'time': time
            });
            // Navigator.pushReplacementNamed(context, '/diet_hand_record',
            // arguments: {
            //   'imageId': _imageId,
            //   'imageUrl': _imageUrl,
            //   'menu': '',
            //   'time': time
            // });
          },
          text: "직접 입력하기",
        ),
      ],
    );
  }
}
