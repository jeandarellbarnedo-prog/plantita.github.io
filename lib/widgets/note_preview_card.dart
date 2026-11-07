import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kHeaderGreen = Color(0xFF587F59);
const Color kDarkGreen = Color(0xFF304E40);
const Color kCardColor = Color(0xFFE9E7DC);
const Color kBorderGreen = Color(0xFFC4C9B4);

class PlantNoteCard extends StatelessWidget {
  final Map<String, dynamic> noteData;
  final VoidCallback onTap;

  const PlantNoteCard({super.key, required this.noteData, required this.onTap});

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

  @override
  Widget build(BuildContext context) {
    final String title = noteData['title'] ?? 'Untitled';
    final String imageBase64 = noteData['image'] ?? '';
    final imageProvider = _getImageProvider(imageBase64);

    Timestamp? timestamp = noteData['createdAt'];
    String dateStr = '';
    if (timestamp != null) {
      DateTime date = timestamp.toDate();
      dateStr =
          '${['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'][date.month - 1]} ${date.day}, ${date.year}';
    }

    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderGreen, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Portrait Image Area
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    color: kHeaderGreen.withValues(alpha: 0.15),
                    child: imageProvider != null
                        ? Image(
                            image: imageProvider,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.broken_image,
                                  color: kHeaderGreen,
                                  size: 32,
                                ),
                          )
                        : const Icon(
                            Icons.image_outlined,
                            color: kHeaderGreen,
                            size: 36,
                          ),
                  ),
                ),
              ),
              // Text Area (Title & Date)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: kDarkGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (dateStr.isNotEmpty)
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
