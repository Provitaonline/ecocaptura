import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/capture_model.dart'; 
import './controllers/capture_controller.dart';
import 'camera_capture_screen.dart';

class NewCaptureScreen extends StatefulWidget {
  final CaptureController controller;

  const NewCaptureScreen({super.key, required this.controller});

  @override
  State<NewCaptureScreen> createState() => _NewCaptureScreenState();
}

class _NewCaptureScreenState extends State<NewCaptureScreen> {
  final TextEditingController _descController = TextEditingController();
  final List<PhotoEntry> _photoEntries = [];

  void _finishCapture() {
    final int uniqueId = DateTime.now().millisecondsSinceEpoch.remainder(1000000);
    
    // Construct the final model (Preserved from original)
    final newCapture = CaptureModel(
      id: uniqueId,
      description: _descController.text,
      photos: _photoEntries,
      status: CaptureStatus.ready,
      timestamp: DateTime.now(),
    );

    // Save to controller
    widget.controller.addCapture(newCapture);

    // Go back to the list
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Capture"),
        // 5. ABORT MECHANISM: Replaced the standard back arrow with a distinct close 'X'
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: "Abort Capture",
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Wrapped in GestureDetector to dismiss keyboard on tap
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            children: [
              // Scrollable area for input forms so keyboard doesn't cause overflows
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Photos", style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      
                      // 2. HORIZONTALLY SCROLLABLE THUMBNAIL ROW
                      SizedBox(
                        height: 85, // Fixed square container bounds
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          // Length is photos list + 1 permanent trailing adder item
                          itemCount: _photoEntries.length + 1,
                          itemBuilder: (context, index) {
                            // Render trailing 'Add Photo' button placeholder
                            if (index == _photoEntries.length) {
                              return _buildAddPhotoPlaceholder();
                            }

                            // Render existing square photo thumbnails
                            final photo = _photoEntries[index];
                            return _buildPhotoThumbnail(photo, index);
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // 3. DESCRIPTION FIELD (BELOW THE THUMBNAILS)
                      Text("Details", style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _descController,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => FocusScope.of(context).unfocus(),
                        decoration: const InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(),
                          hintText: "Enter details about this observation...",
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              
              // 1 & 4. SAVE CAPTURE BUTTON ANCHORED AT THE BOTTOM
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _finishCapture,
                    child: const Text(
                      "Save Capture",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a captured square photo preview with a built-in delete button
  Widget _buildPhotoThumbnail(PhotoEntry photo, int index) {
    return Container(
      width: 85,
      height: 85,
      margin: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            // Updated conditional rendering below:
            child: photo.imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(photo.imagePath!),
                      fit: BoxFit.cover, // Ensures image fills the square perfectly
                    ),
                  )
                : const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
          ),
          
          // ... Your position close badge button block stays exactly the same
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _photoEntries.removeAt(index);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the empty trailing square template with camera + plus badge icons
  Widget _buildAddPhotoPlaceholder() {  
    return InkWell(
      onTap: () async {
        // Navigate to camera and await the captured file path string
        final String? capturedPath = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (context) => const CameraCaptureScreen()),
        );

        // If a photo was actually taken (not aborted)
        if (capturedPath != null && mounted) {
          setState(() {
            _photoEntries.add(PhotoEntry(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              imagePath: capturedPath,
              timestamp: DateTime.now(),
            ));
          });
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 85,
        height: 85,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.camera_alt, size: 28, color: Colors.grey.shade600),
            Positioned(
              right: 6,
              bottom: 6,
              child: CircleAvatar(
                radius: 9,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.add, size: 12, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}