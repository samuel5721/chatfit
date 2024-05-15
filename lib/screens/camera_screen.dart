import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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
    try {
      await FirebaseStorage.instance
          .ref('uploads/${file.path.split('/').last}')
          .putFile(file);
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
      appBar: AppBar(title: const Text("Camera Screen")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30, width: double.infinity),
          _buildPhotoArea(),
          const SizedBox(height: 20),
          _buildButton(),
          const SizedBox(height: 20),
          _buildUploadButton(),
        ],
      ),
    );
  }

  Widget _buildPhotoArea() {
    return _image != null
        ? SizedBox(
            width: 200,
            height: 200,
            child: Image.file(File(_image!.path)), // 가져온 이미지를 화면에 띄워주는 코드
          )
        : Container(
            width: 200,
            height: 200,
            color: Colors.grey,
          );
  }

  Widget _buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            getImage(ImageSource.camera); // getImage 함수를 호출해서 카메라로 찍은 사진 가져오기
          },
          child: const Text("카메라"),
        ),
        const SizedBox(width: 30),
        ElevatedButton(
          onPressed: () {
            getImage(ImageSource.gallery); // getImage 함수를 호출해서 갤러리에서 사진 가져오기
          },
          child: const Text("갤러리"),
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return _image != null
        ? _isUploading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _uploadImage,
                child: const Text("업로드하기"),
              )
        : Container();
  }
}
