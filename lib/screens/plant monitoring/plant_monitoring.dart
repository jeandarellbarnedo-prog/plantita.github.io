import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/plant_card.dart';

const Color kBackground = Color(0xFFDAD8CE);
const Color kHeaderGreen = Color(0xFF587F59);
const Color kDarkGreen = Color(0xFF304E40);
const Color kTextGreen = Color(0xFF315A47);

class PlantMonitoringScreen extends StatelessWidget {
  const PlantMonitoringScreen({super.key});

  String _formatDateHeader(DateTime date, DateTime today) {
    final targetDay = DateTime(date.year, date.month, date.day);
    final currentDay = DateTime(today.year, today.month, today.day);
    final diff = targetDay.difference(currentDay).inDays;

    if (diff == 0) return 'TODAY';
    if (diff == 1) return 'TOMORROW';

    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  bool _shouldShowPlantOnDate(Map<String, dynamic> data, DateTime targetDate) {
    final Timestamp? startDate = data['startDate'];
    if (startDate == null) return false;

    final start = startDate.toDate();
    final startDay = DateTime(start.year, start.month, start.day);
    final targetDay = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );
    final diff = targetDay.difference(startDay).inDays;

    if (diff < 0) return false;

    final int harvestInterval =
        data['harvestIntervalDays'] ?? data['harvestDays'] ?? 0;
    final bool isRepeatingHarvest = data['isRepeatingHarvest'] ?? false;

    // CRITICAL: If it's a one-time harvest and the harvest day has passed, do not show it at all!
    if (harvestInterval > 0 && !isRepeatingHarvest && diff > harvestInterval) {
      return false;
    }

    final int waterInterval = data['waterIntervalDays'] ?? 0;
    final int fertilizerInterval = data['fertilizerIntervalDays'] ?? 0;

    final bool waterDue = waterInterval > 0 && (diff % waterInterval == 0);
    final bool fertilizerDue =
        fertilizerInterval > 0 && (diff % fertilizerInterval == 0);

    bool harvestCardNeeded = false;
    if (harvestInterval > 0) {
      if (isRepeatingHarvest) {
        harvestCardNeeded = true;
      } else {
        if (diff <= harvestInterval) {
          harvestCardNeeded = true;
        }
      }
    }

    return waterDue || fertilizerDue || harvestCardNeeded;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final DateTime today = DateTime.now();

    final List<DateTime> next7Days = List.generate(
      7,
      (index) => DateTime(
        today.year,
        today.month,
        today.day,
      ).add(Duration(days: index)),
    );

    return Scaffold(
      backgroundColor: kBackground,
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
                    'PLANT MONITORING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('plants')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: kDarkGreen),
                    );
                  }

                  final plants = snapshot.data?.docs ?? [];

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: next7Days.length,
                    itemBuilder: (context, index) {
                      final targetDate = next7Days[index];
                      final headerText = _formatDateHeader(targetDate, today);

                      final scheduledPlants = plants.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return _shouldShowPlantOnDate(data, targetDate);
                      }).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            headerText,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: kDarkGreen,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (scheduledPlants.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 20.0),
                              child: Text(
                                'Nothing to do 🌿',
                                style: TextStyle(
                                  color: kTextGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else ...[
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: scheduledPlants.length,
                              separatorBuilder: (context, idx) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, idx) {
                                final doc = scheduledPlants[idx];
                                final data = doc.data() as Map<String, dynamic>;

                                return PlantCard(
                                  data: data,
                                  cardDate: targetDate,
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


