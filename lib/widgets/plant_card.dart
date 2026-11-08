import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kBackground = Color(0xFFDAD8CE);
const Color kHeaderGreen = Color(0xFF587F59);
const Color kDarkGreen = Color(0xFF304E40);
const Color kTextGreen = Color(0xFF315A47);
const Color kBorderGreen = Color(0xFFC4C9B4);
const Color kCardColor = Color(0xFFE9E7DC);

class PlantCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final DateTime cardDate;
  final VoidCallback? onTap;

  const PlantCard({
    super.key,
    required this.data,
    required this.cardDate,
    this.onTap,
  });

  bool _isTaskDue(Timestamp? startDate, int intervalDays, DateTime targetDate) {
    if (startDate == null || intervalDays <= 0) return false;
    final start = startDate.toDate();
    final startDay = DateTime(start.year, start.month, start.day);
    final targetDay = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    final difference = targetDay.difference(startDay).inDays;
    if (difference < 0) return false;
    return difference % intervalDays == 0;
  }

  @override
  Widget build(BuildContext context) {
    final name = data['name'] ?? 'Plant';
    final type = data['type'] ?? 'Plant';
    final waterAmount = data['waterAmountMl'] ?? 0;
    final waterInterval = data['waterIntervalDays'] ?? 0;
    final fertilizerName = data['fertilizerName'] ?? 'Manure';
    final fertilizerAmount = data['fertilizerAmountG'] ?? 0;
    final fertilizerInterval = data['fertilizerIntervalDays'] ?? 0;

    final int harvestInterval =
        data['harvestIntervalDays'] ?? data['harvestDays'] ?? 0;
    final bool isRepeatingHarvest = data['isRepeatingHarvest'] ?? false;
    final Timestamp? startDate = data['startDate'];

    // CRITICAL: If one-time harvest has passed, hide card completely immediately
    if (startDate != null && harvestInterval > 0 && !isRepeatingHarvest) {
      final start = startDate.toDate();
      final startDay = DateTime(start.year, start.month, start.day);
      final targetDay = DateTime(cardDate.year, cardDate.month, cardDate.day);
      if (targetDay.difference(startDay).inDays > harvestInterval) {
        return const SizedBox.shrink();
      }
    }

    final bool waterDue = _isTaskDue(startDate, waterInterval, cardDate);
    final bool fertilizerDue = _isTaskDue(
      startDate,
      fertilizerInterval,
      cardDate,
    );

    bool harvestDue = false;
    String? harvestStatusText;
    bool harvestCardNeeded = false;

    if (startDate != null && harvestInterval > 0) {
      final start = startDate.toDate();
      final startDay = DateTime(start.year, start.month, start.day);
      final targetDay = DateTime(cardDate.year, cardDate.month, cardDate.day);
      final diff = targetDay.difference(startDay).inDays;

      if (diff >= 0) {
        if (isRepeatingHarvest) {
          harvestCardNeeded = true;
          final cycle = harvestInterval + 1;
          final remainder = diff % cycle;

          if (diff > 0 && remainder == 0) {
            harvestDue = true;
            harvestStatusText = 'Ready for harvest today!';
          } else {
            final daysRemaining = cycle - remainder;
            harvestStatusText =
                'Next harvest in $daysRemaining ${daysRemaining == 1 ? 'day' : 'days'}';
          }
        } else {
          final daysRemaining = harvestInterval - diff;

          if (daysRemaining > 0) {
            harvestCardNeeded = true;
            harvestStatusText =
                'Next harvest in $daysRemaining ${daysRemaining == 1 ? 'day' : 'days'}';
          } else if (daysRemaining == 0) {
            harvestCardNeeded = true;
            harvestDue = true;
            harvestStatusText = 'Ready for harvest today!';
          }
        }
      }
    }

    if (!waterDue && !fertilizerDue && !harvestCardNeeded) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorderGreen),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: kHeaderGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.water_drop,
                color: kHeaderGreen,
                size: 24,
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
                  const SizedBox(height: 8),
                  if (waterDue)
                    Text(
                      'Water: ${waterAmount}mL (Every $waterInterval days)',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  if (fertilizerDue)
                    Text(
                      'Fertilizer: $fertilizerName (${fertilizerAmount}g, Every $fertilizerInterval days)',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  if (harvestStatusText != null)
                    Text(
                      harvestStatusText!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: harvestDue ? kHeaderGreen : kTextGreen,
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


