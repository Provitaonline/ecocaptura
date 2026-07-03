import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../data/models/capture_model.dart'; 
import './controllers/capture_controller.dart';
import 'camera_capture_screen.dart';

class CaptureEditorScreen extends StatefulWidget {
  final CaptureController controller;
  final CaptureModel? existingCapture;

  const CaptureEditorScreen({
    super.key, 
    required this.controller, 
    this.existingCapture,
  });

  @override
  State<CaptureEditorScreen> createState() => _CaptureEditorScreenState();
}

class _CaptureEditorScreenState extends State<CaptureEditorScreen> {
  late TextEditingController _descController;
  late List<PhotoEntry> _photoEntries;
  
  bool get isEditing => widget.existingCapture != null;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.existingCapture?.description ?? '');
    _photoEntries = List.from(widget.existingCapture?.photos ?? []);
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _finishCapture() {
    if (isEditing) {
      final updatedCapture = widget.existingCapture!.copyWith(
        description: _descController.text,
        photos: _photoEntries,
      );
      widget.controller.updateCapture(updatedCapture);
    } else {
      final newCapture = CaptureModel(
        id: DateTime.now().millisecondsSinceEpoch.remainder(1000000),
        description: _descController.text,
        photos: _photoEntries,
        status: CaptureStatus.ready,
        timestamp: DateTime.now(),
      );
      widget.controller.addCapture(newCapture);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? i18n.editCapture : i18n.newCapture),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(i18n.photos, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 85,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _photoEntries.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _photoEntries.length) return _buildAddPhotoPlaceholder();
                            return _buildPhotoThumbnail(_photoEntries[index], index);
                          },
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(i18n.captureDetails, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _descController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => FocusScope.of(context).unfocus(),
                        decoration: InputDecoration(
                          labelText: i18n.description,
                          border: const OutlineInputBorder(),
                          hintText: i18n.descriptionHint,
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _finishCapture,
                    child: Text(isEditing ? i18n.saveChanges : i18n.saveCapture),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Methods (Same as your original code) ---
  Widget _buildPhotoThumbnail(PhotoEntry photo, int index) {
    return Container(
      width: 85,
      height: 85,
      margin: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          // The image container
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: photo.imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(photo.imagePath!),
                      fit: BoxFit.cover, // This correctly handles the square crop
                      width: 85,
                      height: 85,
                    ),
                  )
                : const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
          ),
          
          // Delete button
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => setState(() => _photoEntries.removeAt(index)),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cancel, 
                  color: Colors.grey.shade600, // Non-red neutral color
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoPlaceholder() {
    return InkWell(
      onTap: () async {
        final PhotoEntry? newEntry = await Navigator.push<PhotoEntry>(
          context, MaterialPageRoute(builder: (context) => const CameraCaptureScreen()),
        );
        if (newEntry != null && mounted) {
          setState(() {
            newEntry.id = DateTime.now().millisecondsSinceEpoch.toString();
            _photoEntries.add(newEntry);
          });
        }
      },
      child: Container(
        width: 85, height: 85,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}