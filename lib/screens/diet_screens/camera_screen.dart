import 'dart:io';
import 'package:chatfit/components/buttons.dart';
import 'package:chatfit/components/header.dart';
import 'package:chatfit/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  XFile? _image; // 이미지를 담을 변수 선언
  final ImagePicker picker = ImagePicker(); // ImagePicker 초기화
  bool _isUploading = false; // 업로드 상태를 추적하는 변수

  // 이미지를 가져오는 함수
  Future getImage(ImageSource imageSource) async {
    // pickedFile에 ImagePicker로 가져온 이미지가 담긴다.
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path); // 가져온 이미지를 _image에 저장
      });
    }
  }

  // 이미지를 Firebase Storage에 업로드하는 함수
  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() {
      _isUploading = true; // 업로드 상태를 true로 설정
    });

    File file = File(_image!.path);

    const uuid = Uuid();
    String fileName = '${uuid.v4()}.png';
    try {
      await FirebaseStorage.instance.ref('uploads/$fileName').putFile(file);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File uploaded successfully')),
      );
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload file: ${e.message}')),
      );
    } finally {
      setState(() {
        _isUploading = false; // 업로드 상태를 false로 설정
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          _buildPhotoArea(context),
          const SizedBox(height: 20),
          _buildButton(),
          const SizedBox(height: 20),
          _buildUploadButton(),
        ],
      ),
    );
  }

  Widget _buildPhotoArea(BuildContext context) {
    return SizedBox(
      width: Layout.entireWidth(context) * 0.8,
      height: Layout.bodyHeight(context) * 0.6,
      child: (_image == null)
          ? Container(
              color: KeyColor.grey200,
            )
          : Image.file(
              File(_image!.path),
            ), // 가져온 이미지를 화면에 띄워주는 코드
    );
  }

  Widget _buildButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PrimaryButton(
          onPressed: () {
            getImage(ImageSource.camera); // getImage 함수를 호출해서 카메라로 찍은 사진 가져오기
          },
          text: '카메라에서 가져오기',
        ),
        SizedBox(height: 10.h),
        PrimaryButton(
          onPressed: () {
            getImage(ImageSource.gallery); // getImage 함수를 호출해서 갤러리에서 사진 가져오기
          },
          text: "갤러리에서 가져오기",
        ),
        SizedBox(height: 10.h),
        SecondButton(
          onPressed: () {},
          text: "직접 입력",
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return _image != null
        ? _isUploading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _uploadImage,
                child: const Text("업로드하기"),
              )
        : Container();
  }
}
