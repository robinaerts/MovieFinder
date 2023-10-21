import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  Profile({Key? key}) : super(key: key);

  Future logout(BuildContext ctx) async {
    FirebaseAuth.instance
        .signOut()
        .then((_) => {Navigator.of(ctx).pushReplacementNamed("/")});
  }

  Future getTeamMembers(Map<String, dynamic> team) async {
    final members = team['members'];
    final memberDataList = <Map<String, dynamic>>[];

    for (final member in members) {
      try {
        final memberData = await FirebaseFirestore.instance
            .collection('users')
            .doc(member)
            .get();

        if (memberData.exists) {
          memberDataList.add(memberData.data() as Map<String, dynamic>);
        }
      } catch (e) {
        // Handle the error, e.g., log it or display an error message
        print('Error fetching member data: $e');
      }
    }
    return memberDataList;
  }

  Future getTeamAndMembers() async {
    var teamDoc = await FirebaseFirestore.instance
        .collection('groups')
        .where('members', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .get();

    var team = teamDoc.docs[0].data();
    var teamMembers = await getTeamMembers(team);

    return {
      "team": teamDoc.docs[0].data(),
      "members": teamMembers,
    };
  }

  final User _user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getTeamAndMembers(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
                padding: const EdgeInsets.all(30),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Welcome, ${_user.displayName}!"),
                      Text("Your teamcode is: "),
                      TextField(
                        controller: TextEditingController(
                            text: snapshot.data['team']['code']),
                        readOnly: true,
                      ),
                      Text("Your team members are: "),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data['members'].length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text(snapshot.data['members'][index]
                                      ['firstname'] +
                                  " " +
                                  snapshot.data['members'][index]['lastname']),
                              subtitle: Text(
                                  snapshot.data['members'][index]['email']),
                            );
                          }),
                      Text(_user.email.toString()),
                      SizedBox(
                        width: 100,
                        child: OutlinedButton(
                          onPressed: () => logout(context),
                          child: Row(children: const [
                            Icon(Icons.logout),
                            Text("Logout")
                          ]),
                        ),
                      )
                    ]));
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
