import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color kBackground = Color(0xFFDAD8CE);
const Color kHeaderGreen = Color(0xFF587F59);
const Color kDarkGreen = Color(0xFF304E40);
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
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _waterAmountController;
  late TextEditingController _waterIntervalController;
  late TextEditingController _fertilizerNameController;
  late TextEditingController _fertilizerAmountController;
  late TextEditingController _fertilizerIntervalController;
  late TextEditingController _harvestDaysController;

  late bool _canBeHarvested;
  late bool _harvestRepeatedly;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.plantData['name'] ?? '',
    );
    _typeController = TextEditingController(
      text: widget.plantData['type'] ?? '',
    );
    _waterAmountController = TextEditingController(
      text: (widget.plantData['waterAmountMl'] ?? '').toString(),
    );
    _waterIntervalController = TextEditingController(
      text: (widget.plantData['waterIntervalDays'] ?? '').toString(),
    );
    _fertilizerNameController = TextEditingController(
      text: widget.plantData['fertilizerName'] ?? '',
    );
    _fertilizerAmountController = TextEditingController(
      text: (widget.plantData['fertilizerAmountG'] ?? '').toString(),
    );
    _fertilizerIntervalController = TextEditingController(
      text: (widget.plantData['fertilizerIntervalDays'] ?? '').toString(),
    );
    _harvestDaysController = TextEditingController(
      text: (widget.plantData['harvestDays'] ?? '').toString(),
    );

    _canBeHarvested = widget.plantData['canBeHarvested'] ?? false;
    _harvestRepeatedly = widget.plantData['harvestRepeatedly'] ?? false;
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
    _harvestDaysController.dispose();
    super.dispose();
  }

  Future<void> _updatePlant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final updatedData = {
        'name': _nameController.text.trim(),
        'type': _typeController.text.trim(),
        'waterAmountMl': int.tryParse(_waterAmountController.text.trim()) ?? 0,
        'waterIntervalDays':
            int.tryParse(_waterIntervalController.text.trim()) ?? 0,
        'fertilizerName': _fertilizerNameController.text.trim(),
        'fertilizerAmountG':
            int.tryParse(_fertilizerAmountController.text.trim()) ?? 0,
        'fertilizerIntervalDays':
            int.tryParse(_fertilizerIntervalController.text.trim()) ?? 0,
        'canBeHarvested': _canBeHarvested,
        'harvestRepeatedly': _harvestRepeatedly,
        'harvestDays': int.tryParse(_harvestDaysController.text.trim()) ?? 0,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('plants')
          .doc(widget.plantDocId)
          .update(updatedData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plant updated successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update plant: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'EDIT PLANT',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: kDarkGreen,
                  letterSpacing: 1,
                ),
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Plant Name',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter plant name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _typeController,
                      decoration: const InputDecoration(
                        labelText: 'Plant Type (e.g. Vegetable, Herb)',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _waterAmountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Water (mL)',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _waterIntervalController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Every (Days)',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _fertilizerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Fertilizer Name (Optional)',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _fertilizerAmountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Fertilizer (g)',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _fertilizerIntervalController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Every (Days)',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('Can be harvested'),
                      value: _canBeHarvested,
                      onChanged: (val) {
                        setState(() {
                          _canBeHarvested = val ?? false;
                        });
                      },
                    ),
                    if (_canBeHarvested) ...[
                      CheckboxListTile(
                        title: const Text('Harvest repeatedly'),
                        value: _harvestRepeatedly,
                        onChanged: (val) {
                          setState(() {
                            _harvestRepeatedly = val ?? false;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _harvestDaysController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Days to Harvest',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kHeaderGreen,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _isSaving ? null : _updatePlant,
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'SAVE CHANGES',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
