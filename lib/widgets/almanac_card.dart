import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kHeaderGreen = Color(0xFF587F59);
const Color kDarkGreen = Color(0xFF304E40);
const Color kTextGreen = Color(0xFF315A47);
const Color kCardColor = Color(0xFFE9E7DC);
const Color kBorderGreen = Color(0xFFC4C9B4);

class AlmanacCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const AlmanacCard({super.key, required this.data, required this.onTap});

  ImageProvider? _getImageProvider(String base64Str) {
    try {
      if (base64Str.isEmpty) return null;
      // Strip out data URI scheme prefix if present (e.g., "data:image/jpeg;base64,")
      if (base64Str.contains(',')) {
        base64Str = base64Str.split(',').last;
      }
      // Remove any whitespace or newlines
      base64Str = base64Str.replaceAll(RegExp(r'\s+'), '');
      return MemoryImage(base64Decode(base64Str));
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    String name = data['name'] ?? 'Unnamed Plant';
    String type = data['type'] ?? 'Plant';
    String imageBase64 = data['plantImage'] ?? '';
    final imageProvider = _getImageProvider(imageBase64);

    Timestamp? startTimestamp = data['startDate'];
    String addedDateStr = '';
    if (startTimestamp != null) {
      DateTime date = startTimestamp.toDate();
      addedDateStr =
          '${['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'][date.month - 1]} ${date.day}, ${date.year}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderGreen, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 70,
                    height: 70,
                    color: kHeaderGreen.withValues(alpha: 0.15),
                    child: imageProvider != null
                        ? Image(
                            image: imageProvider,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.broken_image_outlined,
                                  color: kHeaderGreen,
                                  size: 32,
                                ),
                          )
                        : const Icon(
                            Icons.yard_outlined,
                            color: kHeaderGreen,
                            size: 36,
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: kDarkGreen,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        type,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kTextGreen,
                        ),
                      ),
                      if (addedDateStr != '') ...[
                        const SizedBox(height: 4),
                        Text(
                          'Added: $addedDateStr',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: kDarkGreen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
