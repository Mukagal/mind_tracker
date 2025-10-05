import 'package:flutter/material.dart';
import 'main.dart';

class Loginscene extends StatefulWidget{
  const Loginscene({super.key});
  @override
  State<Loginscene> createState() =>  Loginscenestate();
}
final TextEditingController _emailController = TextEditingController();

class Loginscenestate extends State<Loginscene>{
  @override
  Widget build (BuildContext context){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(246, 251, 250, 1),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Login",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(2, 8, 7, 1),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Hello, Welcome back to My Courses",
              style: TextStyle(
                fontSize: 14,
                color: Color.fromRGBO(105, 123, 122, 1),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Email",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(2, 8, 7, 1),
              ),
            ),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email',
                prefixIcon: Icon(Icons.email, color: Color.fromRGBO(206, 212, 211, 1)),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(242, 201, 76, 1))
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Password",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(2, 8, 7, 1),
              ),
            ),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Password',
                prefixIcon: Icon(Icons.lock, color: Color.fromRGBO(206, 212, 211, 1)),
                suffixIcon: Icon(Icons.keyboard_hide, color: Color.fromRGBO(206, 212, 211, 1)),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(242, 201, 76, 1))
                ),
              ),
            ),
            const SizedBox(width: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Reset()
                      )
                  );
                },
                child: Text(
                  "Forgot password?",
                  style: TextStyle(
                     color: Color.fromRGBO(105, 123, 122, 1),
                     fontSize: 14,
                  ),
                )
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(242, 201, 76, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    )
                ),
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WelcomePage(),
                    ),
                  );
                },
                child: Text(
                  "Login",
                  style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1)
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(
                    color: Color.fromRGBO(105, 123, 122, 1),
                    fontSize: 14,
                  ),
                ),
                TextButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUp()
                        ),
                      );
                    },
                    child: Text(
                      "Register",
                      style: TextStyle(
                        color: Color.fromRGBO(242, 201, 76, 1),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
class Reset extends StatefulWidget{
  const Reset({super.key});
  State<Reset> createState() => _resetscene();
}
class _resetscene extends State<Reset>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(246, 251, 250, 1),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Loginscene()
                      )
                  );
                }, 
                  icon: const Icon(Icons.arrow_left, color: Colors.green),
                ),
                Text(
                  "Reset Password",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(2, 8, 7, 1),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            Text("Email"),
            const SizedBox(height: 14),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email',
                prefixIcon: Icon(Icons.email, color: Color.fromRGBO(206, 212, 211, 1)),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(242, 201, 76, 1))
                ),
              ),

            ),
            const SizedBox(height: 24),
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
                    )
                ),
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Reset_2(),
                    ),
                  );
                },
                child: Text(
                  "Send Me a New Password",
                  style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1)
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
class Reset_2 extends StatefulWidget{
  const Reset_2({super.key});
  State<Reset_2> createState() => _reset_2_scene();
}

class _reset_2_scene extends State<Reset_2>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(246, 251, 250, 1),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Reset()
                      )
                  );
                },
                  icon: const Icon(Icons.arrow_left, color: Colors.green),
                ),
                Text(
                  "Reset Password",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(2, 8, 7, 1),
                  ),
                )
              ],
            ),
            Text(
              "Please fill in the field below to reset your current password.",
              style: TextStyle(
                fontSize: 14,
                color: Color.fromRGBO(105, 123, 122, 1),
              ),
            ),
            const SizedBox(height: 24),
            Text("New Password"),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'New Password',
                prefixIcon: Icon(Icons.lock, color: Color.fromRGBO(206, 212, 211, 1)),
                suffixIcon: Icon(Icons.keyboard_hide, color: Color.fromRGBO(206, 212, 211, 1)),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromRGBO(242, 201, 76, 1))
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text("Confirm Password"),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  hintText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock, color: Color.fromRGBO(206, 212, 211, 1)),
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.keyboard_hide, color: Color.fromRGBO(206, 212, 211, 1)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromRGBO(242, 201, 76, 1))
                  ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(242, 201, 76, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    )
                ),
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WelcomePage(),
                    ),
                  );
                },
                child: Text(
                  "Confirm New Password",
                  style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1)
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