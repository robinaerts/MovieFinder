import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moviefinder/pages/main_app.dart';
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
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const MainApp()));
  }

  Future signinWithGoogle() async {
    await FirebaseAuth.instance.signInWithAuthProvider(GoogleAuthProvider());
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const MainApp()));
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
            child: const Text("Don't have an account? Signup"),
          ),
          MaterialButton(
            color: Colors.white,
            elevation: 10,

            // by onpressed we call the function signup function
            onPressed: signinWithGoogle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: 30.0,
                    width: 30.0,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/googleimage.png'),
                          fit: BoxFit.cover),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                const Text("Sign In with Google")
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
