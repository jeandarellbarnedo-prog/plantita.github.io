import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/plant_model.dart';

class PlantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addPlant(PlantModel plant) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('No user logged in');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('plants')
        .add(plant.toMap());
  }

  Stream<List<PlantModel>> getPlants() {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('plants')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PlantModel.fromFirestore(doc))
              .toList();
        });
  }
}
