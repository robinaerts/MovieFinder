import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  Future logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          width: 100,
          child: OutlinedButton(
            onPressed: logout,
            child: Row(children: const [Icon(Icons.logout), Text("Logout")]),
          ),
        )
      ]),
    );
  }
}
