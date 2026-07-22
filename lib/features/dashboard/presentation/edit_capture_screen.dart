import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ecocaptura/core/extensions/content_extensions.dart';
import '../data/models/capture_model.dart'; 
import './controllers/capture_controller.dart';
import 'camera_capture_screen.dart';
import './widgets/full_screen_photo_view.dart';
import 'package:ecocaptura/core/constants/app_constants.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CaptureEditorScreen extends StatefulWidget {
  final CaptureController controller;
  final CaptureModel? existingCapture;
  final bool isReadOnly;

  const CaptureEditorScreen({
    super.key, 
    required this.controller, 
    this.existingCapture,
    this.isReadOnly = false,
  });

  @override
  State<CaptureEditorScreen> createState() => _CaptureEditorScreenState();
}

class _CaptureEditorScreenState extends State<CaptureEditorScreen> {
  late TextEditingController _descController;
  late List<PhotoEntry> _photoEntries;
  late int _selectedQuality;
  late String? _selectedReason;
  late bool _shouldRetain;

  late int _initialQuality;
  String? _initialReason;
  late String _initialDescription;
  late List<PhotoEntry> _initialPhotos;
  late bool _initialRetain;
  
  bool get isEditing => widget.existingCapture != null;

  @override
  void initState() {
    super.initState();

    _initialQuality = widget.existingCapture?.qualityScore ?? 3;
    _initialReason = widget.existingCapture?.qualityReason;
    _initialDescription = widget.existingCapture?.description ?? '';
    _initialPhotos = List.from(widget.existingCapture?.photos ?? []);
    _initialRetain = widget.existingCapture?.shouldRetain ?? false;

    _descController = TextEditingController(text: widget.existingCapture?.description ?? '');
    _descController.addListener(_updateButtonState);
    _photoEntries = List.from(widget.existingCapture?.photos ?? []);
    _selectedQuality = widget.existingCapture?.qualityScore ?? 3;
    _selectedReason = widget.existingCapture?.qualityReason;
    _shouldRetain = _initialRetain;
  }

  void _updateButtonState() {
    setState(() {}); 
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  bool _isSaveEnabled() {
    final hasPhoto = _photoEntries.isNotEmpty;
    final hasDescription = _descController.text.trim().isNotEmpty;
    
    return hasPhoto && hasDescription;
  }

  bool _isDirty() {
    if (_descController.text != _initialDescription) return true;
    if (_selectedQuality != _initialQuality) return true;
    if (_shouldRetain != _initialRetain) return true;
    
    final currentReason = (_selectedReason == null || _selectedReason == "") ? null : _selectedReason;
    final initialReason = (_initialReason == null || _initialReason == "") ? null : _initialReason;
    if (currentReason != initialReason) return true;
    if (_photoEntries.length != _initialPhotos.length) return true;
    
    return false;
  }

  void _finishCapture() {
    final CaptureModel captureToSave;

    if (isEditing) {
      captureToSave = widget.existingCapture!.copyWith(
        description: _descController.text,
        photos: _photoEntries,
        qualityScore: _selectedQuality,
        qualityReason: _selectedReason,
        shouldRetain: _shouldRetain,
      );
      widget.controller.updateCapture(captureToSave);
    } else {
      captureToSave = CaptureModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: _descController.text,
        photos: _photoEntries,
        qualityScore: _selectedQuality, 
        qualityReason: _selectedReason,
        shouldRetain: _shouldRetain,
        status: CaptureStatus.inProgress,
        timestamp: DateTime.now(),
      );
      widget.controller.addCapture(captureToSave);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_isDirty()) {
          final navigator = Navigator.of(context);
          final shouldQuit = await _showExitConfirmationDialog(context);
          
          if (shouldQuit == true && mounted) {
            navigator.pop();
          }
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isReadOnly 
                ? context.i18n.captureDetails 
                : (isEditing ? context.i18n.editCapture : context.i18n.newCapture)
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.maybePop(context),
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
                        Text(context.i18n.photosCount(_photoEntries.length), style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 85,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _photoEntries.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _photoEntries.length) return _buildAddPhotoPlaceholder();
                              return _buildPhotoThumbnail(index, _photoEntries);
                            },
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(context.i18n.captureInfo, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 10),
                        _buildQualityFields(),
                        TextField(
                          controller: _descController,
                          readOnly: widget.isReadOnly,
                          enabled: !widget.isReadOnly,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                          decoration: InputDecoration(
                            labelText: context.i18n.description,
                            border: const OutlineInputBorder(),
                            hintText: context.i18n.descriptionHint,
                            alignLabelWithHint: true,
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!widget.isReadOnly)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaveEnabled() ? _finishCapture : null,
                        child: Text(isEditing ? context.i18n.saveChanges : context.i18n.saveCapture),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Methods ---
  Widget _buildPhotoThumbnail(int index, List<PhotoEntry> photoEntries) {
    return Container(
      width: 85,
      height: 85,
      margin: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (photoEntries[index].imagePath != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenPhotoView(photoEntries: photoEntries, initialIndex: index),
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
              child: photoEntries[index].imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(photoEntries[index].imagePath!),
                        fit: BoxFit.cover,
                        width: 85,
                        height: 85,
                        cacheWidth: 170,
                        errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 85),
                      ),
                    )
                  : const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
            ),
          ),

          if (!widget.isReadOnly)
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () async {
                    final bool? shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(context.i18n.deletePhotoTitle),
                        content: Text(context.i18n.deletePhotoMessage),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(context.i18n.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(context.i18n.delete, style: const TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete == true) {
                      setState(() {
                        _photoEntries.removeAt(index);
                        _updateButtonState();
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
    if (widget.isReadOnly) return const SizedBox.shrink();
    return InkWell(
      onTap: () async {
        final PhotoEntry? newEntry = await Navigator.push<PhotoEntry>(
          context, MaterialPageRoute(builder: (context) => const CameraCaptureScreen()),
        );
        if (newEntry != null && mounted) {
          setState(() {
            newEntry.id = DateTime.now().millisecondsSinceEpoch.toString();
            _photoEntries.add(newEntry);
            _updateButtonState();
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

  Widget _buildQualityFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.i18n.dataQuality, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  RatingBar.builder(
                    ignoreGestures: widget.isReadOnly,
                    initialRating: _selectedQuality.toDouble(),
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 3,
                    itemSize: 28.0,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _selectedQuality = rating.toInt();
                        if (_selectedQuality == 3) {
                          _selectedReason = "";
                        } else {
                          if (_selectedReason == "" || _selectedReason == null) {
                            _selectedReason = QualityReasons.other; 
                          }
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Retain',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Checkbox(
                    value: _shouldRetain,
                    onChanged: widget.isReadOnly 
                        ? null 
                        : (val) => setState(() => _shouldRetain = val ?? true),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (_selectedQuality < 3)
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _selectedReason,
            decoration: InputDecoration(
              labelText: context.i18n.qualityReason,
              border: const OutlineInputBorder(),
            ),
            items: QualityReasons.all.map((key) {
              String label;
              switch (key) {
                case QualityReasons.poorGps: label = context.i18n.reasonPoorGps; break;
                case QualityReasons.blurry: label = context.i18n.reasonBlurry; break;
                case QualityReasons.obstructed: label = context.i18n.reasonObstructed; break;
                default: label = context.i18n.reasonOther;
              }
              
              return DropdownMenuItem<String>(
                value: key,
                child: Text(label),
              );
            }).toList(),
            onChanged: widget.isReadOnly ? null : (val) => setState(() => _selectedReason = val),
          ),
        const SizedBox(height: 28),
      ],
    );
  }

  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.i18n.discardChangesTitle),
        content: Text(context.i18n.discardChangesMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.i18n.keepEditing)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(context.i18n.discard)),
        ],
      ),
    );
  }
}