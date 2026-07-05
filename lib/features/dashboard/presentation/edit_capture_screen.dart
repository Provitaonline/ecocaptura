import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../data/models/capture_model.dart'; 
import './controllers/capture_controller.dart';
import 'camera_capture_screen.dart';
import './widgets/full_screen_photo_view.dart';

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
  late int _selectedQuality;
  late String? _selectedReason;
  
  bool get isEditing => widget.existingCapture != null;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.existingCapture?.description ?? '');
    _photoEntries = List.from(widget.existingCapture?.photos ?? []);
    _selectedQuality = widget.existingCapture?.qualityScore ?? 3;
    _selectedReason = widget.existingCapture?.qualityReason;
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
        qualityScore: _selectedQuality,
        qualityReason: _selectedReason,
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
                      _buildQualityFields(i18n),
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

  // --- Helper Methods ---
  Widget _buildPhotoThumbnail(PhotoEntry photo, int index) {
    final i18n = AppLocalizations.of(context)!;
    return Container(
      width: 85,
      height: 85,
      margin: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          // 1. The Image - Now wrapped in a GestureDetector for full-screen view
          GestureDetector(
            onTap: () {
              if (photo.imagePath != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenPhotoView(imagePath: photo.imagePath!),
                  ),
                );
              }
            },
            child: Container(
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
                        fit: BoxFit.cover,
                        width: 85,
                        height: 85,
                      ),
                    )
                  : const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
            ),
          ),

          // 2. The Delete Button - Placed on top of the image in the Stack
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () async {
                  // 1. Show the confirmation dialog
                  final bool? shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title:  Text(i18n.deletePhotoTitle),
                      content:  Text(i18n.deletePhotoMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false), // Cancel
                          child:  Text(i18n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true), // Confirm
                          child:  Text(i18n.delete, style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  // 2. If the user clicked "Delete", perform the removal
                  if (shouldDelete == true) {
                    setState(() {
                      _photoEntries.removeAt(index);
                    });
                  }
                },
                child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cancel,
                  color: Colors.grey.shade600,
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

  Widget _buildQualityFields(AppLocalizations i18n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quality Rating
        DropdownButtonFormField<int>(
          initialValue: _selectedQuality, // Initialize this in initState from model
          decoration: InputDecoration(
            labelText: i18n.dataQuality,
            border: const OutlineInputBorder(),
          ),
          items: [1, 2, 3].map((int val) {
            return DropdownMenuItem<int>(
              value: val,
              child: Text("$val Star"),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedQuality = val!;
              if (_selectedQuality == 3) {
                _selectedReason = "";
              }
            });
          },
        ),
        const SizedBox(height: 16),
        // Reason (Visible if quality < 3)
        if (_selectedQuality < 3)
          DropdownButtonFormField<String>(
            initialValue: _selectedReason,
            decoration: InputDecoration(
              labelText: i18n.qualityReason,
              border: const OutlineInputBorder(),
            ),
            items: ["Poor GPS", "Blurry", "Obstructed", "Other"].map((String reason) {
              return DropdownMenuItem<String>(
                value: reason,
                child: Text(reason),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedReason = val),
          ),
        const SizedBox(height: 28), // Spacer before description
      ],
    );
  }
}