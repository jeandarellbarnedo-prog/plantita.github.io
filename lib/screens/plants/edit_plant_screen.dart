import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color kBackground = Color(0xFFDAD8CE);
const Color kHeaderGreen = Color(0xFF587F59);
const Color kDarkGreen = Color(0xFF304E40);
const Color kTextGreen = Color(0xFF315A47);
const Color kCardColor = Color(0xFFE9E7DC);
const Color kBorderGreen = Color(0xFFC4C9B4);

class EditPlantScreen extends StatefulWidget {
  final String plantDocId;
  final Map<String, dynamic> plantData;

  const EditPlantScreen({
    super.key,
    required this.plantDocId,
    required this.plantData,
  });

  @override
  State<EditPlantScreen> createState() => _EditPlantScreenState();
}

class _EditPlantScreenState extends State<EditPlantScreen> {
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _waterAmountController;
  late TextEditingController _waterIntervalController;
  late TextEditingController _fertilizerNameController;
  late TextEditingController _fertilizerAmountController;
  late TextEditingController _fertilizerIntervalController;
  late TextEditingController _harvestIntervalController;

  bool _isHarvestable = false;
  bool _isRepeatingHarvest = false; // false = once, true = repeatedly
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final data = widget.plantData;

    _nameController = TextEditingController(text: data['name'] ?? '');
    _typeController = TextEditingController(text: data['type'] ?? '');
    _waterAmountController = TextEditingController(
      text: (data['waterAmountMl'] ?? '').toString(),
    );
    _waterIntervalController = TextEditingController(
      text: (data['waterIntervalDays'] ?? '').toString(),
    );
    _fertilizerNameController = TextEditingController(
      text: data['fertilizerName'] ?? '',
    );
    _fertilizerAmountController = TextEditingController(
      text: (data['fertilizerAmountG'] ?? '').toString(),
    );
    _fertilizerIntervalController = TextEditingController(
      text: (data['fertilizerIntervalDays'] ?? '').toString(),
    );

    final harvestDays = data['harvestIntervalDays'] ?? data['harvestDays'] ?? 0;
    _harvestIntervalController = TextEditingController(
      text: harvestDays > 0 ? harvestDays.toString() : '',
    );

    _isHarvestable = data['isHarvestable'] ?? (harvestDays > 0);
    _isRepeatingHarvest = data['isRepeatingHarvest'] ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _waterAmountController.dispose();
    _waterIntervalController.dispose();
    _fertilizerNameController.dispose();
    _fertilizerAmountController.dispose();
    _fertilizerIntervalController.dispose();
    _harvestIntervalController.dispose();
    super.dispose();
  }

  Future<void> _updatePlant() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final int harvestDays = _isHarvestable
          ? (int.tryParse(_harvestIntervalController.text.trim()) ?? 0)
          : 0;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('plants')
          .doc(widget.plantDocId)
          .update({
            'name': _nameController.text.trim(),
            'type': _typeController.text.trim(),
            'waterAmountMl':
                int.tryParse(_waterAmountController.text.trim()) ?? 0,
            'waterIntervalDays':
                int.tryParse(_waterIntervalController.text.trim()) ?? 0,
            'fertilizerName': _fertilizerNameController.text.trim(),
            'fertilizerAmountG':
                int.tryParse(_fertilizerAmountController.text.trim()) ?? 0,
            'fertilizerIntervalDays':
                int.tryParse(_fertilizerIntervalController.text.trim()) ?? 0,
            'isHarvestable': _isHarvestable,
            'harvestIntervalDays': harvestDays,
            'harvestDays': harvestDays,
            'isRepeatingHarvest': _isRepeatingHarvest,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plant updated successfully! 🌿')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating plant: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kHeaderGreen,
        title: const Text(
          'EDIT PLANT',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Plant Name',
                filled: true,
                fillColor: kCardColor,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Plant Type (e.g., Vegetable, Fruit)',
                filled: true,
                fillColor: kCardColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _waterAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Water Amount (mL)',
                      filled: true,
                      fillColor: kCardColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _waterIntervalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Water Interval (Days)',
                      filled: true,
                      fillColor: kCardColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fertilizerNameController,
              decoration: const InputDecoration(
                labelText: 'Fertilizer Name',
                filled: true,
                fillColor: kCardColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fertilizerAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Fertilizer Amount (g)',
                      filled: true,
                      fillColor: kCardColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _fertilizerIntervalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Fertilizer Interval (Days)',
                      filled: true,
                      fillColor: kCardColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Exact Harvest UI Match ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Can be harvested?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kDarkGreen,
                  ),
                ),
                Checkbox(
                  value: _isHarvestable,
                  activeColor: kDarkGreen,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (val) =>
                      setState(() => _isHarvestable = val ?? false),
                ),
              ],
            ),

            if (_isHarvestable) ...[
              const SizedBox(height: 16),
              const Text(
                'Harvest Frequency:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kDarkGreen,
                ),
              ),
              const SizedBox(height: 8),
              RadioListTile<bool>(
                title: const Text(
                  'Can only be harvested once',
                  style: TextStyle(fontSize: 14, color: kDarkGreen),
                ),
                value: false,
                groupValue: _isRepeatingHarvest,
                activeColor: kDarkGreen,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) =>
                    setState(() => _isRepeatingHarvest = val ?? false),
              ),
              RadioListTile<bool>(
                title: const Text(
                  'Can be harvested repeatedly',
                  style: TextStyle(fontSize: 14, color: kDarkGreen),
                ),
                value: true,
                groupValue: _isRepeatingHarvest,
                activeColor: kDarkGreen,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) =>
                    setState(() => _isRepeatingHarvest = val ?? true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _harvestIntervalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Days before it can be harvested',
                  labelStyle: const TextStyle(color: kTextGreen),
                  filled: true,
                  fillColor: kCardColor,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: kBorderGreen),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: kDarkGreen, width: 1.5),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kHeaderGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isLoading ? null : _updatePlant,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'SAVE CHANGES',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


