import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlantModel {
  final String id;
  final String plantName;
  final String plantType;
  final int wateringIntervalDays;
  final String fertilizerName;
  final int fertilizerIntervalDays;
  final bool canBeHarvested;
  final String harvestFrequency;
  final int daysBeforeHarvest;
  final DateTime createdAt;

  PlantModel({
    required this.id,
    required this.plantName,
    required this.plantType,
    required this.wateringIntervalDays,
    required this.fertilizerName,
    required this.fertilizerIntervalDays,
    required this.canBeHarvested,
    required this.harvestFrequency,
    required this.daysBeforeHarvest,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'plantName': plantName,
      'plantType': plantType,
      'wateringIntervalDays': wateringIntervalDays,
      'fertilizerName': fertilizerName,
      'fertilizerIntervalDays': fertilizerIntervalDays,
      'canBeHarvested': canBeHarvested,
      'harvestFrequency': harvestFrequency,
      'daysBeforeHarvest': daysBeforeHarvest,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PlantModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PlantModel(
      id: doc.id,
      plantName: data['plantName'] ?? '',
      plantType: data['plantType'] ?? '',
      wateringIntervalDays: data['wateringIntervalDays'] ?? 0,
      fertilizerName: data['fertilizerName'] ?? '',
      fertilizerIntervalDays: data['fertilizerIntervalDays'] ?? 0,
      canBeHarvested: data['canBeHarvested'] ?? false,
      harvestFrequency: data['harvestFrequency'] ?? 'once',
      daysBeforeHarvest: data['daysBeforeHarvest'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
