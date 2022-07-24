import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  final Function nextStep;
  const CreateAccount({Key? key, required this.nextStep}) : super(key: key);

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  bool _loading = false;

  Future<void> createAccount(CreateAccount widget) async {
    setState(() {
      _loading = true;
    });

    if (passwordController.text != passwordConfirmController.text) {
      return setState(() {
        errorMessage = "Passwords don't match";
      });
    }
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        errorMessage = "You forgot one or more fields";
      });
    }

    UserCredential res = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);

    CollectionReference users = FirebaseFirestore.instance.collection("users");
    await users
        .doc(res.user!.uid)
        .set({'email': res.user!.email, 'id': res.user!.uid});

    await FirebaseAuth.instance.currentUser!.sendEmailVerification();

    setState(() {
      _loading = false;
    });

    widget.nextStep();
  }

  String errorMessage = "";
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(30),
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                border: UnderlineInputBorder(), labelText: "Enter your email"),
            controller: emailController,
          ),
          const SizedBox(height: 20),
          TextField(
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Enter your password"),
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              controller: passwordController),
          const SizedBox(height: 20),
          TextField(
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Repeat your password"),
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              controller: passwordConfirmController),
          const SizedBox(
            height: 50,
          ),
          (errorMessage.isNotEmpty
              ? Text(
                  errorMessage,
                  style: TextStyle(color: Theme.of(context).errorColor),
                )
              : const Text("")),
          _loading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () => createAccount(widget),
                  child: const Text("Signup"))
        ],
      ),
    );
  }
}
