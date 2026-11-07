import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plantita/screens/plant monitoring/plant_monitoring.dart';
import 'package:plantita/screens/plants/add_plant_screen.dart';
import 'package:plantita/screens/almanac/almanac_list.dart';
import 'package:plantita/screens/auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const bg = Color(0xFFDAD8CE);
  static const green = Color(0xFF587F59);
  static const lightGreen = Color(0xFFA6B58D);
  static const darkGreen = Color(0xFF304E40);
  static const textGreen = Color(0xFF315A47);

  String userName = '';
  bool isLoadingName = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          setState(() {
            userName = doc.data()!['fullName'] ?? '';
            isLoadingName = false;
          });
          return;
        }
      }
    } catch (e) {}
    setState(() {
      isLoadingName = false;
    });
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date =
        '${['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'][now.month - 1]} ${now.day}, ${now.year}';
    final day = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ][now.weekday - 1];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 58,
              decoration: const BoxDecoration(
                color: green,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
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
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () => _signOut(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            isLoadingName
                ? const SizedBox(
                    height: 40,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: darkGreen,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : Text(
                    userName.isNotEmpty ? 'Welcome $userName' : 'Welcome',
                    style: GoogleFonts.greatVibes(
                      fontSize: 42,
                      color: darkGreen,
                    ),
                  ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 340,
                height: 145,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E7DC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFC4C9B4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'TODAY',
                      style: TextStyle(
                        color: Color(0xFF718367),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    FittedBox(
                      child: Text(
                        date,
                        style: const TextStyle(
                          color: textGreen,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        day,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton(
                      context,
                      'PLANT MONITORING',
                      Icons.search,
                      lightGreen,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PlantMonitoringScreen(),
                          ),
                        );
                      },
                    ),
                    _buildButton(
                      context,
                      'MY ALMANAC',
                      Icons.menu_book_outlined,
                      green,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AlmanacScreen(),
                          ),
                        );
                      },
                    ),
                    _buildButton(
                      context,
                      'ADD A PLANT',
                      Icons.yard_outlined,
                      darkGreen,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddPlantScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: 340,
      height: 100,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 18,
                child: Icon(icon, color: Colors.white, size: 52),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 65),
                child: FittedBox(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
