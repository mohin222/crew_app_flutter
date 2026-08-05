import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  // Multiple selection
  final Set<int> _selectedIndices = {};
  bool _otherSelected = false;
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _otherController = TextEditingController();
  final List<File> _mediaFiles = [];
  final ImagePicker _picker = ImagePicker();

  static const Color darkNavy = Color(0xFF072D62);
  static const Color lightNavy = Color(0xFF114995);

  final List<Map<String, dynamic>> _incidents = [
    {'label': 'Room Cleanliness', 'icon': Icons.cleaning_services_rounded},
    {'label': 'Air Conditioning', 'icon': Icons.ac_unit_rounded},
    {'label': 'Plumbing Problems', 'icon': Icons.plumbing_rounded},
    {'label': 'Electrical Issues', 'icon': Icons.electrical_services_rounded},
    {'label': 'Access Card Issues', 'icon': Icons.credit_card_rounded},
  ];

  @override
  void dispose() {
    _descController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_mediaFiles.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 files allowed')),
      );
      return;
    }
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null) {
      setState(() => _mediaFiles.add(File(image.path)));
    }
  }

  Future<void> _pickVideo() async {
    if (_mediaFiles.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 files allowed')),
      );
      return;
    }
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      setState(() => _mediaFiles.add(File(video.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.3159, 1.0],
                colors: [Color(0xFF072D62), Color(0xFF114995)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.fromLTRB(16, topPad + 14, 16, 24),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Report Incident',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Incident Type — multiple selection
                  const Text('Incident Type',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: darkNavy)),
                  const SizedBox(height: 4),
                  const Text('Select all that apply',
                      style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
                  const SizedBox(height: 10),

                  ...List.generate(_incidents.length, (i) {
                    final selected = _selectedIndices.contains(i);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (selected) {
                          _selectedIndices.remove(i);
                        } else {
                          _selectedIndices.add(i);
                        }
                      }),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFFEEF2FF) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected ? lightNavy : const Color(0xFFDADADA),
                            width: selected ? 1.5 : 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: selected ? lightNavy : darkNavy,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(_incidents[i]['icon'] as IconData,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(_incidents[i]['label'] as String,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: selected ? lightNavy : Colors.black87)),
                            ),
                            if (selected)
                              const Icon(Icons.check_circle, color: lightNavy, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Other Issues — with text input
                  GestureDetector(
                    onTap: () => setState(() => _otherSelected = !_otherSelected),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: _otherSelected ? const Color(0xFFEEF2FF) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _otherSelected ? lightNavy : const Color(0xFFDADADA),
                          width: _otherSelected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text('Other Issues, Please Specify...',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: lightNavy)),
                          ),
                          if (_otherSelected)
                            const Icon(Icons.check_circle, color: lightNavy, size: 20),
                        ],
                      ),
                    ),
                  ),

                  // Other text input field
                  if (_otherSelected) ...[
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: lightNavy, width: 1.5),
                      ),
                      child: TextField(
                        controller: _otherController,
                        maxLines: 3,
                        autofocus: true,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Describe the other issue...',
                          hintStyle: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  const SizedBox(height: 20),

                  // Upload Media
                  const Text('Upload Media',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: darkNavy)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFDADADA)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 44,
                                height: 44,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F4FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.camera_alt_outlined, color: lightNavy),
                              ),
                            ),
                            GestureDetector(
                              onTap: _pickVideo,
                              child: Container(
                                width: 44,
                                height: 44,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F4FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.videocam_outlined, color: lightNavy),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text('Tap to add photos and videos',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: darkNavy)),
                        const SizedBox(height: 2),
                        Text('Max 3 files - 1 MB each (${_mediaFiles.length}/3)',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),

                        // Preview selected files
                        if (_mediaFiles.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 70,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _mediaFiles.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Container(
                                      width: 70,
                                      height: 70,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: FileImage(_mediaFiles[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () => setState(() => _mediaFiles.removeAt(index)),
                                        child: Container(
                                          width: 18,
                                          height: 18,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close, color: Colors.white, size: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  const Text('Description',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: darkNavy)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFDADADA)),
                    ),
                    child: TextField(
                      controller: _descController,
                      maxLines: 5,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Describe the incident in detail...\nAny contributing circumstances to the incident would be helpful',
                        hintStyle: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF), height: 1.6),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 49,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Incident reported successfully')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightNavy,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Submit Incident',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}