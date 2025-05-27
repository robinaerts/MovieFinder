import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _loading = false;

  Future signinUser() async {
    setState(() {
      _loading = true;
    });
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .then((_) {
      Navigator.of(context).pushReplacementNamed("/app");
    }).catchError((err) {
      setState(() {
        _loading = false;
      });
    });
  }

  // Future signinWithGoogle() async {
  //   await FirebaseAuth.instance.signInWithAuthProvider(GoogleAuthProvider());
  //   Navigator.pushReplacement(
  //       context, MaterialPageRoute(builder: (context) => const MainApp()));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          height: double.infinity,
          margin: const EdgeInsets.all(30),
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Sign in to your account",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: "Enter your email"),
                    controller: emailController,
                  ),
                  const SizedBox(height: 50),
                  TextField(
                    decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: "Enter your password"),
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    controller: passwordController,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30, bottom: 5),
                    child: _loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Theme.of(context).primaryColor)),
                            onPressed: () {
                              signinUser();
                            },
                            child: const Text("Login"),
                          ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed("/signup");
                    },
                    child: Text(
                      "Don't have an account? Signup",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  // MaterialButton(
                  //   color: Colors.white,
                  //   elevation: 10,
                  //   onPressed: signinWithGoogle,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     children: [
                  //       Padding(
                  //         padding: const EdgeInsets.all(10.0),
                  //         child: Container(
                  //           height: 30.0,
                  //           width: 30.0,
                  //           decoration: const BoxDecoration(
                  //             image: DecorationImage(
                  //                 image: AssetImage('assets/images/googleimage.png'),
                  //                 fit: BoxFit.cover),
                  //             shape: BoxShape.circle,
                  //           ),
                  //         ),
                  //       ),
                  //       const SizedBox(
                  //         width: 20,
                  //       ),
                  //       const Text("Sign In with Google")
                  //     ],
                  //   ),
                  // ),
                ]),
          ),
        ),
      ),
    );
  }
}
