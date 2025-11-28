import 'package:flutter/material.dart';
import 'reset.dart';
import 'package:mob_edu/widgets/profile.dart';
import 'package:mob_edu/widgets/button.dart';
import 'payments_screen.dart';
import 'Game.dart';

class ProfilePage extends StatelessWidget {
  final int? id;
  final String? name;
  final String? surname;
  final String? email;
  final bool? ispremium;

  const ProfilePage({
    Key? key,
    required this.name,
    required this.surname,
    required this.email,
    required this.id,
    required this.ispremium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(73, 173, 213, 1),
              Color.fromRGBO(152, 203, 147, 1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        ProfileAvatar(userID: id),

                        const SizedBox(height: 40),

                        ProfileInfoField(label: 'Name', value: name ?? ''),
                        const SizedBox(height: 20),
                        ProfileInfoField(
                          label: 'Surname',
                          value: surname ?? '',
                        ),
                        const SizedBox(height: 20),
                        ProfileInfoField(label: 'Email', value: email ?? ''),
                        const SizedBox(height: 40),
                        ProfileInfoField(
                          label: 'Premium',
                          value: ispremium.toString(),
                        ),
                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6BB8AC),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            icon: const Icon(
                              Icons.lock_reset,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Reset Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Reset(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                        CustomButton(
                          label: "Change to premium",
                          nextPage: PremiumUpgradeScreen(userId: id),
                        ),
                        const SizedBox(height: 40),
                        if (ispremium == true)
                          CustomButton(
                            label: "Game",
                            nextPage: BubblePopScreen(),
                          ),
                        const SizedBox(height: 40),
                      ],
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

class ProfileInfoField extends StatelessWidget {
  final String label;
  final String value;

  const ProfileInfoField({Key? key, required this.label, required this.value})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
