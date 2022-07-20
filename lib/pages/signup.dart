import 'package:flutter/material.dart';
import 'package:moviefinder/components/signup_create.dart';
import 'package:moviefinder/components/signup_group.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  int step = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Create an account"),
        ),
        body: (step == 0)
            ? const CreateAccount()
            : (step == 1)
                ? const CreateJoinGroup()
                : const Text("Error"));
  }
}
