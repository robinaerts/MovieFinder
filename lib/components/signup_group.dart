import 'package:flutter/material.dart';

class CreateJoinGroup extends StatefulWidget {
  const CreateJoinGroup({Key? key}) : super(key: key);

  @override
  State<CreateJoinGroup> createState() => _CreateJoinGroupState();
}

class _CreateJoinGroupState extends State<CreateJoinGroup> {
  final groupCodeController = TextEditingController();

  Future<void> createGroup() async {}

  Future<void> joinGroup() async {}

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
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: createGroup, child: const Text("Create One"))
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
                SizedBox(
                  height: 10,
                ),
                const TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your 9-digit code',
                  ),
                ),
                SizedBox(
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
