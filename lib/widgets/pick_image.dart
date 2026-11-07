import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PlantImagePicker extends StatefulWidget {
  const PlantImagePicker({super.key});

  @override
  State<PlantImagePicker> createState() => _PlantImagePickerState();
}

class _PlantImagePickerState extends State<PlantImagePicker> {
  Uint8List? _webImageBytes;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _webImageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFFDAD8CE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF587F59), width: 1.5),
        ),
        child: _webImageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(_webImageBytes!, fit: BoxFit.cover),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 48,
                    color: Color(0xFF304E40),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap to upload plant photo',
                    style: TextStyle(
                      color: Color(0xFF304E40),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
