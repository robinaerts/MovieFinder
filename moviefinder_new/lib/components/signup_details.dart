import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddAcountDetails extends StatefulWidget {
  final Function nextStep;
  const AddAcountDetails({Key? key, required this.nextStep}) : super(key: key);

  @override
  State<AddAcountDetails> createState() => AddAcountDetailsState();
}

class AddAcountDetailsState extends State<AddAcountDetails> {
  final fnameController = TextEditingController();
  final lnameController = TextEditingController();
  final usernameController = TextEditingController();
  bool _loading = false;

  Future addDetails(AddAcountDetails widget) async {
    if (fnameController.text.isEmpty ||
        lnameController.text.isEmpty ||
        usernameController.text.isEmpty) return;
    setState(() {
      _loading = true;
    });

    User currentuser = FirebaseAuth.instance.currentUser!;

    await FirebaseFirestore.instance.doc("users/${currentuser.uid}").update({
      "firstname": fnameController.text,
      "lastname": lnameController.text,
      "username": usernameController.text,
      "rated": []
    });
    setState(() {
      _loading = false;
    });
    widget.nextStep();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: fnameController,
          decoration: const InputDecoration(
              border: UnderlineInputBorder(), labelText: "First Name"),
        ),
        TextField(
          controller: lnameController,
          decoration: const InputDecoration(
              border: UnderlineInputBorder(), labelText: "Last Name"),
        ),
        TextField(
          controller: usernameController,
          decoration: const InputDecoration(
              border: UnderlineInputBorder(), labelText: "Username"),
        ),
        const SizedBox(
          height: 40,
        ),
        _loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () => addDetails(widget),
                child: const Text("Add Details"))
      ],
    );
  }
}
