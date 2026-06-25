import 'package:flutter/material.dart';
// Adjust these paths based on where your model and controller are located
import '../data/models/capture_model.dart'; 
import './controllers/capture_controller.dart'; 

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
    
    // Construct the final model
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
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _finishCapture,
            tooltip: "Save Capture",
          )
        ],
      ),
      // Wrapped in GestureDetector to dismiss keyboard on tap
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _descController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                  hintText: "Enter details about this observation...",
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text("Photos", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              
              // Photo Grid
              Expanded(
                child: _photoEntries.isEmpty
                    ? Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(child: Text("No photos added yet")),
                      )
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _photoEntries.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              // Thumbnail container
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Center(child: Icon(Icons.photo)),
                              ),
                              // Remove button
                              Positioned(
                                right: 0,
                                top: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _photoEntries.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
              
              const SizedBox(height: 16),
              
              // Add Photo Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text("Add Photo"),
                  onPressed: () {
                    setState(() {
                      // Placeholder logic until camera is wired up
                      _photoEntries.add(PhotoEntry(
                        id: DateTime.now().toString(),
                        description: "Photo #${_photoEntries.length + 1}",
                      ));
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}