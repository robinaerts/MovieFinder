import 'package:flutter/material.dart';
import 'package:moviefinder/pages/signup.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

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
          const TextField(),
          const SizedBox(height: 50),
          const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
          const TextField(
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
          ),
          Container(
            margin: const EdgeInsets.only(top: 30, bottom: 5),
            child: ElevatedButton(
              onPressed: () {},
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
