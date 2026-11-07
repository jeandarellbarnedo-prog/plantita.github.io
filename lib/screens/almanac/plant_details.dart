import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_plant.dart';
import 'note_form.dart';
import 'almanac_note.dart';
import 'package:plantita/widgets/note_preview_card.dart';

const Color kBackground = Color(0xFFDAD8CE);
const Color kHeaderGreen = Color(0xFF587F59);
const Color kDarkGreen = Color(0xFF304E40);
const Color kTextGreen = Color(0xFF315A47);
const Color kBorderGreen = Color(0xFFC4C9B4);

class PlantInfoScreen extends StatelessWidget {
  final String plantDocId;
  final Map<String, dynamic> plantData;

  const PlantInfoScreen({
    super.key,
    required this.plantDocId,
    required this.plantData,
  });

  ImageProvider? _getImageProvider(Map<String, dynamic> data) {
    try {
      String imageStr = data['plantImage'] ?? data['image'] ?? '';
      if (imageStr.isEmpty) return null;

      if (imageStr.startsWith('http://') || imageStr.startsWith('https://')) {
        return NetworkImage(imageStr);
      }

      if (imageStr.contains(',')) {
        imageStr = imageStr.split(',').last;
      }
      imageStr = imageStr.replaceAll(RegExp(r'\s+'), '');
      return MemoryImage(base64Decode(imageStr));
    } catch (e) {
      return null;
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final name = plantData['name'] ?? 'this plant';

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kBackground,
        title: const Text('Delete plant?'),
        content: Text('This removes $name from your almanac.'),
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
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('plants')
          .doc(plantDocId)
          .delete();

      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$name deleted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = plantData['name'] ?? 'Plant';
    final type = plantData['type'] ?? 'Plant';
    final waterAmount = plantData['waterAmountMl'] ?? 0;
    final waterInterval = plantData['waterIntervalDays'] ?? 0;
    final fertilizerName = plantData['fertilizerName'] ?? '';
    final fertilizerAmount = plantData['fertilizerAmountG'] ?? 0;
    final fertilizerInterval = plantData['fertilizerIntervalDays'] ?? 0;
    final imageProvider = _getImageProvider(plantData);

    Timestamp? startTimestamp = plantData['startDate'];
    String formattedDate = 'Unknown date';
    if (startTimestamp != null) {
      final date = startTimestamp.toDate();
      formattedDate =
          '${['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'][date.month - 1]} ${date.day}, ${date.year}';
    }

    return Scaffold(
      backgroundColor: kBackground,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kHeaderGreen,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPlantNoteScreen(plantDocId: plantDocId),
            ),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
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
                      onPressed: () => _confirmDelete(context),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBorderGreen),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 200,
                            height: 200,
                            color: kHeaderGreen.withValues(alpha: 0.15),
                            child: imageProvider != null
                                ? Image(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
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
                                name.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: kDarkGreen,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                type,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: kTextGreen,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Added: $formattedDate',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (waterInterval > 0)
                                Text(
                                  'Water: ${waterAmount}mL every $waterInterval days',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                              if (fertilizerInterval > 0)
                                Text(
                                  'Fertilizer: $fertilizerName (${fertilizerAmount}g) every $fertilizerInterval days',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kHeaderGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPlantScreen(
                            plantDocId: plantDocId,
                            plantData: plantData,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Edit Plant Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'PLANT LOGS & NOTES',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: kDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .collection('plants')
                        .doc(plantDocId)
                        .collection('notes')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(color: kDarkGreen),
                          ),
                        );
                      }

                      final notes = snapshot.data?.docs ?? [];

                      if (notes.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'No notes or logs added yet.',
                              style: TextStyle(
                                color: kDarkGreen,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notes.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // 3 columns per row
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio:
                                  0.7, // Portrait rectangle aspect ratio
                            ),
                        itemBuilder: (context, index) {
                          final doc = notes[index];
                          final data = doc.data() as Map<String, dynamic>;

                          return PlantNoteCard(
                            noteData: data,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlantNoteDetailScreen(
                                    plantDocId:
                                        plantDocId, // Pass the parent plant ID
                                    noteDocId: doc
                                        .id, // Pass the individual note document ID
                                    noteData: data,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
