import 'package:flutter/material.dart';
import 'package:moviefinder/components/signup_create.dart';
import 'package:moviefinder/components/signup_details.dart';
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
        type: StepperType.vertical,
        currentStep: step,
        steps: [
          Step(
              isActive: step >= 0,
              title: const Text("Create Account"),
              content: CreateAccount(nextStep: () => setState(() => step = 1))),
          Step(
              isActive: step >= 1,
              title: const Text("More Details"),
              content:
                  AddAcountDetails(nextStep: () => setState(() => step = 2))),
          Step(
              isActive: step >= 2,
              title: const Text("Join a Group"),
              content: const CreateJoinGroup()),
        ],
        controlsBuilder: (context, details) {
          return const SizedBox();
        },
      ),
    );
  }
}
