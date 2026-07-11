import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart'; 
import '../../data/models/capture_model.dart'; 

class FullScreenPhotoView extends StatelessWidget {
  final List<PhotoEntry> photoEntries;
  final int initialIndex;

  const FullScreenPhotoView({
    super.key, 
    required this.photoEntries, 
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: photoEntries.length,
            builder: (context, index) {
              final entry = photoEntries[index];
              final path = entry.imagePath ?? ''; 
              
              return PhotoViewGalleryPageOptions(
                imageProvider: path.isNotEmpty 
                    ? FileImage(File(path)) 
                    : const AssetImage('assets/placeholder.png'),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            pageController: PageController(initialPage: initialIndex),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),

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
                  child: const Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}