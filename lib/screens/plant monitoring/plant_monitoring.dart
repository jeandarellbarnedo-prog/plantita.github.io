import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plantita/widgets/plant_card.dart';

const Color kBackground = Color(0xFFDAD8CE);
const Color kHeaderGreen = Color(0xFF587F59);
const Color kDarkGreen = Color(0xFF304E40);
const Color kTextGreen = Color(0xFF315A47);
const Color kCardColor = Color(0xFFE9E7DC);
const Color kBorderGreen = Color(0xFFC4C9B4);

class PlantMonitoringScreen extends StatelessWidget {
  const PlantMonitoringScreen({super.key});

  static const _months = [
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

  String _label(DateTime date, int index) {
    if (index == 0) return 'TODAY';
    if (index == 1) return 'TOMORROW';
    return '${_months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

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
                    'PLANTITA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: user == null
                  ? const Center(child: Text('Please log in.'))
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('plants')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: kDarkGreen),
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];
                        final plantsList = docs
                            .map((doc) => doc.data() as Map<String, dynamic>)
                            .toList();

                        return ListView(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                          children: [
                            const Center(
                              child: Text(
                                'PLANT MONITORING',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: kDarkGreen,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            if (plantsList.isEmpty)
                              const _EmptyState()
                            else
                              for (int i = 0; i < 5; i++)
                                _DaySection(
                                  label: _label(
                                    today.add(Duration(days: i)),
                                    i,
                                  ),
                                  isDate: i >= 2,
                                  date: today.add(Duration(days: i)),
                                  plants: plantsList,
                                ),
                          ],
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

class _DaySection extends StatelessWidget {
  final String label;
  final bool isDate;
  final DateTime date;
  final List<Map<String, dynamic>> plants;

  const _DaySection({
    required this.label,
    required this.isDate,
    required this.date,
    required this.plants,
  });

  bool _hasTaskOnDate(Map<String, dynamic> data, DateTime targetDate) {
    Timestamp? startTimestamp = data['startDate'];
    if (startTimestamp == null) return false;

    DateTime startDate = startTimestamp.toDate();
    DateTime cleanStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    int daysPassed = targetDate.difference(cleanStart).inDays;

    if (daysPassed < 0) return false;

    int waterInterval = data['waterIntervalDays'] ?? 0;
    if (waterInterval > 0 && daysPassed % waterInterval == 0) {
      return true;
    }

    int fertilizerInterval = data['fertilizerIntervalDays'] ?? 0;
    if (fertilizerInterval > 0 && daysPassed % fertilizerInterval == 0) {
      return true;
    }

    bool canBeHarvested = data['canBeHarvested'] ?? false;
    bool harvestRepeatedly = data['harvestRepeatedly'] ?? false;
    int harvestDays = data['harvestDays'] ?? 0;

    if (canBeHarvested && harvestDays > 0) {
      if (harvestRepeatedly) {
        if (daysPassed > 0 && daysPassed % harvestDays == 0) {
          return true;
        }
      } else {
        if (daysPassed == harvestDays) {
          return true;
        }
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final due = plants.where((p) => _hasTaskOnDate(p, date)).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 8, bottom: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: isDate ? 22 : 16,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (due.isEmpty)
            const Padding(
              padding: EdgeInsets.only(left: 6, bottom: 4),
              child: Text(
                'Nothing to do 🌿',
                style: TextStyle(color: kTextGreen, fontSize: 13),
              ),
            )
          else
            for (final plantData in due)
              PlantCard(data: plantData, cardDate: date),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Icon(Icons.yard_outlined, size: 70, color: kHeaderGreen),
          SizedBox(height: 12),
          Text(
            'No plants yet.\nTap "ADD A PLANT" on the dashboard to get started!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: kDarkGreen, height: 1.5),
          ),
        ],
      ),
    );
  }
}
