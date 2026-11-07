import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color kBackground = Color(0xFFDAD8CE);
const Color kHeaderGreen = Color(0xFF587F59);
const Color kDarkGreen = Color(0xFF304E40);
const Color kBorderGreen = Color(0xFFC4C9B4);

class PlantNoteDetailScreen extends StatefulWidget {
  final String plantDocId;
  final String noteDocId;
  final Map<String, dynamic> noteData;

  const PlantNoteDetailScreen({
    super.key,
    required this.plantDocId,
    required this.noteDocId,
    required this.noteData,
  });

  @override
  State<PlantNoteDetailScreen> createState() => _PlantNoteDetailScreenState();
}

class _PlantNoteDetailScreenState extends State<PlantNoteDetailScreen> {
  ImageProvider? _getImageProvider(String base64Str) {
    try {
      if (base64Str.isEmpty) return null;
      if (base64Str.contains(',')) {
        base64Str = base64Str.split(',').last;
      }
      base64Str = base64Str.replaceAll(RegExp(r'\s+'), '');
      return MemoryImage(base64Decode(base64Str));
    } catch (e) {
      return null;
    }
  }

  Future<void> _confirmDeleteNote(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final title = widget.noteData['title'] ?? 'this note';

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kBackground,
        title: const Text('Delete Note?'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: kDarkGreen)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('plants')
            .doc(widget.plantDocId)
            .collection('notes')
            .doc(widget.noteDocId)
            .delete();

        if (!mounted) return;
        Navigator.pop(context); // Pops back to PlantInfoScreen
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Note deleted successfully')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete note: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.noteData['title'] ?? 'Untitled';
    final content = widget.noteData['content'] ?? '';
    final imageBase64 = widget.noteData['image'] ?? '';
    final imageProvider = _getImageProvider(imageBase64);

    Timestamp? timestamp = widget.noteData['createdAt'];
    String dateStr = '';
    if (timestamp != null) {
      DateTime date = timestamp.toDate();
      dateStr =
          '${['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'][date.month - 1]} ${date.day}, ${date.year}';
    }

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top Header Bar
            Container(
              width: double.infinity,
              height: 58,
              decoration: const BoxDecoration(
                color: kHeaderGreen,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text(
                    'PLANTITA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                      onPressed: () => _confirmDeleteNote(context),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Note Detail White Container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBorderGreen),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Centered Unstretched Image Container
                        if (imageProvider != null) ...[
                          Center(
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 280),
                              decoration: BoxDecoration(
                                color: kBackground.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image(
                                  image: imageProvider,
                                  fit: BoxFit.contain, // Prevents stretching
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          title.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: kDarkGreen,
                          ),
                        ),
                        if (dateStr.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                        const Divider(height: 24, color: kBorderGreen),
                        Text(
                          content,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
