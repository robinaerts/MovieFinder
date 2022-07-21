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
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: step,
        steps: [
          Step(
              isActive: step >= 0,
              title: Text("Basic Details"),
              content: CreateAccount(nextStep: () => setState(() => step = 1))),
          Step(
              isActive: step >= 1,
              title: Text("Join a Group"),
              content: CreateJoinGroup()),
        ],
        controlsBuilder: (context, details) {
          return SizedBox();
        },
      ),
    );
  }
}
