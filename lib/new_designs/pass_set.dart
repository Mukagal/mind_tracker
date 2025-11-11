import 'package:flutter/material.dart';
import 'package:mob_edu/services/register_service.dart';
import 'package:mob_edu/widgets/gradient_background.dart';
import 'for_nav.dart';
import 'package:mob_edu/widgets/text_field.dart';
import 'package:mob_edu/services/reset_service.dart';

class PassSet extends StatefulWidget {
  final String email;
  final String Name;
  final String Surname;
  final bool isReset;

  const PassSet({
    super.key,
    required this.email,
    required this.Name,
    required this.Surname,
    required this.isReset,
  });

  @override
  State<PassSet> createState() => _PassSetState();
}

class _PassSetState extends State<PassSet> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newpasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        top: -200,
        bottom: 500,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6BB8AC).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF6BB8AC),
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      widget.isReset
                          ? "Reset Your Password"
                          : "Set Your Password",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Please enter your new password below",
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    CustomTextField(
                      label: "Password",
                      hintText: "Enter password",
                      controller: _passwordController,
                      icon: Icons.lock,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: "Confirm Password",
                      hintText: "Re-enter password",
                      controller: _newpasswordController,
                      icon: Icons.lock,
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6BB8AC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          final password = _passwordController.text.trim();
                          final confirm = _newpasswordController.text.trim();

                          if (password.isEmpty || confirm.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all fields'),
                              ),
                            );
                            return;
                          }

                          if (password != confirm) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Passwords do not match'),
                              ),
                            );
                            return;
                          }

                          bool success = false;

                          if (widget.isReset) {
                            success = await ResetService.updatePassword(
                              email: widget.email,
                              newPassword: password,
                              context: context,
                            );
                          } else {
                            success = await RegisterService.registerUser(
                              name: widget.Name,
                              surname: widget.Surname,
                              email: widget.email,
                              password: password,
                              context: context,
                            );
                          }

                          if (success) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    initpage(email: widget.email),
                              ),
                            );
                          }
                        },
                        child: Text(
                          widget.isReset ? "Reset Password" : "Register",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
