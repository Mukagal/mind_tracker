import 'package:flutter/material.dart';
import 'package:mob_edu/widgets/gradient_background.dart';

class AddPage extends StatelessWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        top: -100,
        bottom: -100,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 40),
                      ProfileInfoField(label: 'Name', value: 'Turan'),
                      SizedBox(height: 20),
                      ProfileInfoField(label: 'Surname', value: 'Salmanqeyev'),
                      SizedBox(height: 20),
                      ProfileInfoField(
                        label: 'Email',
                        value: '230103373@sdu.edu.kz',
                      ),
                    ],
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
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
