import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kHeaderGreen = Color(0xFF587F59);
const Color kDarkGreen = Color(0xFF304E40);
const Color kTextGreen = Color(0xFF315A47);
const Color kCardColor = Color(0xFFE9E7DC);
const Color kBorderGreen = Color(0xFFC4C9B4);

class PlantCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final DateTime cardDate;

  const PlantCard({super.key, required this.data, required this.cardDate});

  @override
  Widget build(BuildContext context) {
    String name = data['name'] ?? 'Unnamed Plant';
    String type = data['type'] ?? 'Plant';
    int waterAmount = data['waterAmountMl'] ?? 0;
    int interval = data['waterIntervalDays'] ?? 0;

    String fertilizerName = data['fertilizerName'] ?? '';
    int fertilizerAmount = data['fertilizerAmountG'] ?? 0;
    int fertilizerInterval = data['fertilizerIntervalDays'] ?? 0;

    bool canBeHarvested = data['canBeHarvested'] ?? false;
    bool harvestRepeatedly = data['harvestRepeatedly'] ?? false;
    int harvestDays = data['harvestDays'] ?? 0;

    String harvestStatus = '';

    if (canBeHarvested == true && harvestDays > 0) {
      Timestamp? startTimestamp = data['startDate'];
      if (startTimestamp != null) {
        DateTime startDate = startTimestamp.toDate();
        DateTime cleanStart = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );

        int daysPassedOnCard = cardDate.difference(cleanStart).inDays;

        if (harvestRepeatedly == true) {
          if (daysPassedOnCard > 0 && daysPassedOnCard % harvestDays == 0) {
            harvestStatus = 'Harvest Day!';
          } else {
            int remainder = daysPassedOnCard % harvestDays;
            int daysRemaining = harvestDays - remainder;
            DateTime exactHarvestDate = cardDate.add(
              Duration(days: daysRemaining),
            );
            String formattedDate =
                '${['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'][exactHarvestDate.month - 1]} ${exactHarvestDate.day}, ${exactHarvestDate.year}';
            harvestStatus =
                'Next harvest in $daysRemaining days ($formattedDate)';
          }
        } else {
          if (daysPassedOnCard == harvestDays) {
            harvestStatus = 'Harvest Day!';
          } else {
            int daysRemaining = harvestDays - daysPassedOnCard;
            DateTime exactHarvestDate = cleanStart.add(
              Duration(days: harvestDays),
            );
            String formattedDate =
                '${['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'][exactHarvestDate.month - 1]} ${exactHarvestDate.day}, ${exactHarvestDate.year}';

            if (daysRemaining > 0) {
              harvestStatus = 'Harvest in $daysRemaining days ($formattedDate)';
            }
          }
        }
      }
    }

    List<Widget> columnChildren = [
      Text(
        name,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: kDarkGreen,
        ),
      ),
      const SizedBox(height: 2),
      Text(type, style: const TextStyle(fontSize: 12, color: kTextGreen)),
      const SizedBox(height: 4),
      Text(
        'Water: ' +
            waterAmount.toString() +
            'mL (Every ' +
            interval.toString() +
            ' days)',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    ];

    if (fertilizerName != '') {
      columnChildren.add(const SizedBox(height: 2));
      columnChildren.add(
        Text(
          'Fertilizer: ' +
              fertilizerName +
              ' (' +
              fertilizerAmount.toString() +
              'g, Every ' +
              fertilizerInterval.toString() +
              ' days)',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      );
    }

    if (canBeHarvested == true && harvestStatus != '') {
      columnChildren.add(const SizedBox(height: 2));
      columnChildren.add(
        Text(
          harvestStatus,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: kHeaderGreen,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderGreen, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kHeaderGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.water_drop, color: kHeaderGreen, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columnChildren,
            ),
          ),
        ],
      ),
    );
  }
}
