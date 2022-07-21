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

  Future createAccount(CreateAccount widget) async {
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

    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);

    widget.nextStep();
  }

  String errorMessage = "";
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(30),
      child: Column(
        children: [
          const Text("Email"),
          TextField(
            controller: emailController,
          ),
          const SizedBox(
            height: 50,
          ),
          const Text("Password"),
          TextField(
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              controller: passwordController),
          const SizedBox(
            height: 50,
          ),
          const Text("Confirm Password"),
          TextField(
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
          ElevatedButton(
              onPressed: () => createAccount(widget),
              child: const Text("Signup"))
        ],
      ),
    );
  }
}
