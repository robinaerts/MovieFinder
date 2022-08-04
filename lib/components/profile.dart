import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  Profile({Key? key}) : super(key: key);

  Future logout(BuildContext ctx) async {
    FirebaseAuth.instance
        .signOut()
        .then((_) => {Navigator.of(ctx).pushReplacementNamed("/")});
  }

  final User _user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        // Image.network(_user!.photoURL.toString()),
        Text(_user.email.toString()),
        SizedBox(
          width: 100,
          child: OutlinedButton(
            onPressed: () => logout(context),
            child: Row(children: const [Icon(Icons.logout), Text("Logout")]),
          ),
        )
      ]),
    );
  }
}
