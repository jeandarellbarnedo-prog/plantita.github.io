import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';

const Color kBackground = Color(0xFFDAD8CE);
const Color kHeaderGreen = Color(0xFF587F59);
const Color kGreener = Color(0xFF304E40);
const Color kGreenest = Color(0xFF315A47);

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _wateringController = TextEditingController();
  final TextEditingController _waterAmountController = TextEditingController();
  final TextEditingController _fertilizerNameController =
      TextEditingController();
  final TextEditingController _fertilizerAmountController =
      TextEditingController();
  final TextEditingController _fertilizerDaysController =
      TextEditingController();
  final TextEditingController _harvestDaysController = TextEditingController();

  String _plantType = 'Vegetable';
  bool _canBeHarvested = false;
  String _harvestFrequency = 'once';
  bool _isLoading = false;
  Uint8List? _imageBytes;

  @override
  void dispose() {
    _nameController.dispose();
    _wateringController.dispose();
    _waterAmountController.dispose();
    _fertilizerNameController.dispose();
    _fertilizerAmountController.dispose();
    _fertilizerDaysController.dispose();
    _harvestDaysController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: kGreener),
      floatingLabelStyle: const TextStyle(color: kGreenest),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kGreener, width: 1.5),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: kGreenest, width: 2),
      ),
      border: const OutlineInputBorder(),
    );
  }

  WidgetStateColor get _radioFill =>
      WidgetStateColor.resolveWith((states) => kGreener);

  Future<void> _savePlant() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to add a plant.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final DateTime startDate = DateTime(now.year, now.month, now.day);
      final String imageBase64 = _imageBytes != null
          ? base64Encode(_imageBytes!)
          : '';

      final Map<String, dynamic> plantData = {
        'name': _nameController.text.trim(),
        'type': _plantType,
        'startDate': Timestamp.fromDate(startDate),
        'lastWateredDate': Timestamp.fromDate(startDate),
        'waterIntervalDays': int.tryParse(_wateringController.text) ?? 0,
        'waterAmountMl': int.tryParse(_waterAmountController.text) ?? 0,
        'fertilizerName': _fertilizerNameController.text.trim(),
        'fertilizerAmountG':
            int.tryParse(_fertilizerAmountController.text) ?? 0,
        'fertilizerIntervalDays':
            int.tryParse(_fertilizerDaysController.text) ?? 0,
        'canBeHarvested': _canBeHarvested,
        'harvestRepeatedly': _harvestFrequency == 'repeatedly',
        'harvestDays': int.tryParse(_harvestDaysController.text) ?? 0,
        'plantImage': imageBase64,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('plants')
          .add(plantData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plant saved successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save plant: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('ADD NEW PLANT'),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          fontStyle: FontStyle.italic,
          color: Colors.white,
        ),
        backgroundColor: kHeaderGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9E7DC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kGreener, width: 1.5),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 48,
                              color: kGreener,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to upload plant photo',
                              style: TextStyle(
                                color: kGreener,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Plant Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a plant name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Plant Type:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Non-Flowering'),
                      value: 'Non-Flowering',
                      fillColor: _radioFill,
                      groupValue: _plantType,
                      onChanged: (value) => setState(() => _plantType = value!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Fruit'),
                      value: 'Fruit',
                      fillColor: _radioFill,
                      groupValue: _plantType,
                      onChanged: (value) => setState(() => _plantType = value!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Vegetable'),
                      value: 'Vegetable',
                      fillColor: _radioFill,
                      groupValue: _plantType,
                      onChanged: (value) => setState(() => _plantType = value!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Flower'),
                      value: 'Flower',
                      fillColor: _radioFill,
                      groupValue: _plantType,
                      onChanged: (value) => setState(() => _plantType = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _wateringController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  'Watering Interval (Every X days)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter watering days';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _waterAmountController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Water Amount (mL)'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Please enter water amount'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _fertilizerNameController,
                decoration: _inputDecoration('Fertilizer Name'),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _fertilizerAmountController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Fertilizer Amount (g)'),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _fertilizerDaysController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Fertilize Every X Days'),
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text('Can be harvested?'),
                value: _canBeHarvested,
                fillColor: _radioFill,
                onChanged: (bool? value) {
                  setState(() => _canBeHarvested = value ?? false);
                },
              ),
              if (_canBeHarvested) ...[
                const SizedBox(height: 10),
                const Text(
                  'Harvest Frequency:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                RadioListTile<String>(
                  title: const Text('Can only be harvested once'),
                  value: 'once',
                  fillColor: _radioFill,
                  groupValue: _harvestFrequency,
                  onChanged: (value) =>
                      setState(() => _harvestFrequency = value!),
                ),
                RadioListTile<String>(
                  title: const Text('Can be harvested repeatedly'),
                  value: 'repeatedly',
                  fillColor: _radioFill,
                  groupValue: _harvestFrequency,
                  onChanged: (value) =>
                      setState(() => _harvestFrequency = value!),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _harvestDaysController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    'Days before it can be harvested',
                  ),
                  validator: (value) {
                    if (_canBeHarvested && (value == null || value.isEmpty)) {
                      return 'Please enter the number of days for harvest';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kHeaderGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _isLoading ? null : _savePlant,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Plant', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
