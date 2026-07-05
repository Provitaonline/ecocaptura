import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart'; // Import the package

class FullScreenPhotoView extends StatelessWidget {
  final String imagePath;

  const FullScreenPhotoView({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoView(
            imageProvider: FileImage(File(imagePath)),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),

          // THE CLOSE BUTTON (Layered ON TOP of the PhotoView)
          Positioned(
            top: 40,
            right: 20,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8), 
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5), 
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close, 
                    color: Colors.white, 
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}