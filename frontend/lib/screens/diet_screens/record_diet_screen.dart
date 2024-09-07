import 'dart:convert';
import 'dart:io';
import 'package:chatfit/components/buttons.dart';
import 'package:chatfit/components/header.dart';
import 'package:chatfit/components/navigations.dart';
import 'package:chatfit/components/texts.dart';
import 'package:chatfit/theme.dart';
import 'package:chatfit/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

//! 사진 입력 확인 받은 후 식단 인식 -> 계속하기 진행

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

  // 이미지를 가져오는 함수
  Future getImage(ImageSource imageSource) async {
    // pickedFile에 ImagePicker로 가져온 이미지가 담긴다.
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
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
      String? userEmail =
          Provider.of<UserProvider>(context, listen: false).getUserEmail();

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
        Uri.parse('http://127.0.0.1:8000/api/detect_cnn'), // 백엔드 엔드포인트
      );

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await http.Response.fromStream(response);
        print('응답 내용: ${responseBody.body}'); // 응답 내용을 확인하기 위해 출력

        var jsonResponse = jsonDecode(responseBody.body);

        // 서버에서 반환된 결과를 menu에 저장
        setState(() {
          menu = jsonResponse['detected'].join(", "); // 음식 이름들을 쉼표로 구분
          _isRecognized = true;
        });
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
        String userEmail =
            Provider.of<UserProvider>(context, listen: false).getUserEmail();

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
              (_image == null)
                  ? Center(
                      child: _inputImageBtns(),
                    )
                  : (_isSubmitting)
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
          text: '카메라에서 열기',
          onPressed: () {
            getImage(ImageSource.camera);
          },
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          text: '갤러리에서 열기',
          onPressed: () {
            getImage(ImageSource.gallery);
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
            getImage(ImageSource.camera);
          },
          text: "다시 촬영하기",
        ),
      ],
    );
  }

  Widget _buildReconizeDiet() {
    return _isRecognizing
        ? const CircularProgressIndicator()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ContentText(text: '지금 드시고 있는 음식을'),
              Row(children: [
                TitleText(text: ' $menu', fontSize: 20),
                const ContentText(text: ' 로 인식했어요.'),
              ]),
            ],
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
            Navigator.pushNamed(context, '/diet_write', arguments: {
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
            _removeImage();
            setState(() {
              _image = null;
            });
          },
          text: "직접 입력하기",
        ),
      ],
    );
  }
}
