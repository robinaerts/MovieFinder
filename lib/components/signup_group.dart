import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moviefinder/pages/main_app.dart';

class CreateJoinGroup extends StatefulWidget {
  const CreateJoinGroup({Key? key}) : super(key: key);

  @override
  State<CreateJoinGroup> createState() => _CreateJoinGroupState();
}

class _CreateJoinGroupState extends State<CreateJoinGroup> {
  String createdGroupCode = "";
  final groupCodeController = TextEditingController();

  Future<void> createGroup() async {
    if (FirebaseAuth.instance.currentUser == null) return;

    String id =
        DateTime.now().toUtc().millisecondsSinceEpoch.toString().substring(4);

    await FirebaseFirestore.instance.collection("groups").doc(id).set({
      "code": id,
      "members": [FirebaseAuth.instance.currentUser!.uid]
    });

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const MainApp(),
    ));
  }

  Future<void> joinGroup() async {
    FirebaseFirestore.instance
        .collection("groups")
        .doc(createdGroupCode)
        .update({
      "members": FieldValue.arrayUnion(
          [FirebaseAuth.instance.currentUser!.uid.toString()])
    });

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const MainApp(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Don't have a group?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: createGroup, child: const Text("Create One")),
          ]),
        ),
        Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("I received a code",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(
                  height: 10,
                ),
                const TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your 9-digit code',
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                OutlinedButton(
                    onPressed: joinGroup, child: const Text("Join Group"))
              ],
            ))
      ],
    );
  }
}
