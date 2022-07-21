import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moviefinder/pages/signup.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future signinUser() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Container(
        margin: const EdgeInsets.all(30),
        child: Column(children: [
          const Text(
            "Email",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: emailController,
          ),
          const SizedBox(height: 50),
          const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            controller: passwordController,
          ),
          Container(
            margin: const EdgeInsets.only(top: 30, bottom: 5),
            child: ElevatedButton(
              onPressed: () {
                signinUser();
              },
              child: const Text("Login"),
            ),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const Signup()));
              },
              child: const Text("Don't have an account? Signup"))
        ]),
      ),
    );
  }
}
