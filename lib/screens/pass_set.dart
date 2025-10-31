import 'package:flutter/material.dart';
import 'package:mob_edu/services/register_service.dart';
import 'homepage.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              label: "Password",
              hintText: "Set Password",
              controller: _passwordController,
              icon: Icons.password,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: "Confirm Password",
              hintText: "Confirm Password",
              controller: _newpasswordController,
              icon: Icons.password,
            ),
            const SizedBox(height: 20),

            SizedBox(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(242, 201, 76, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                onPressed: () async {
                  final password = _passwordController.text.trim();
                  final confirm = _newpasswordController.text.trim();

                  if (password.isEmpty || confirm.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  if (password != confirm) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Passwords do not match')),
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
                      MaterialPageRoute(builder: (context) => const MainPage()),
                    );
                  }
                },
                child: Text(widget.isReset ? "Reset" : "Register"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
