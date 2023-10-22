import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moviefinder/pages/main_app.dart';
import 'package:share_plus/share_plus.dart';
import 'preferences.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String createdGroupCode = "";

  final groupCodeController = TextEditingController();

  bool _loading = false;

  Future<void> createGroup() async {
    if (FirebaseAuth.instance.currentUser == null) return;

    setState(() {
      _loading = true;
    });

    String id =
        DateTime.now().toUtc().millisecondsSinceEpoch.toString().substring(4);

    FirebaseFirestore.instance.collection("groups").doc(id).set({
      "code": id,
      "members": [FirebaseAuth.instance.currentUser!.uid]
    }).then((_) => {Navigator.of(context).pushReplacementNamed("/app")});
  }

  Future<void> joinGroup() async {
    setState(() {
      _loading = true;
    });

    try {
      FirebaseFirestore.instance
          .collection("groups")
          .doc(groupCodeController.text)
          .update({
        "members": FieldValue.arrayUnion(
            [FirebaseAuth.instance.currentUser!.uid.toString()])
      });
    } catch (e) {
      return setState(() {
        _loading = false;
      });
    }

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const MainApp(),
    ));
  }

  Future logout(BuildContext ctx) async {
    FirebaseAuth.instance
        .signOut()
        .then((_) => {Navigator.of(ctx).pushReplacementNamed("/")});
  }

  Future leaveTeam(BuildContext ctx) async {
    FirebaseFirestore.instance
        .collection("groups")
        .where('members', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) => {
              value.docs[0].reference.update({
                "members": FieldValue.arrayRemove(
                    [FirebaseAuth.instance.currentUser!.uid.toString()])
              })
            })
        .then((_) => {Navigator.of(ctx).pushReplacementNamed("/app")});
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

    if (teamDoc.docs.length == 0) {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      return {
        "team": null,
        "members": [userData.data()]
      };
    }
    ;

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
            var userData = snapshot.data['members']
                .where((item) => item['id'] == _user.uid)
                .toList()[0];
            return SingleChildScrollView(
              child: Container(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                            child: Text("Hi, ${userData['firstname']}!",
                                style: const TextStyle(
                                  fontSize: 25,
                                ))),
                        const Text("Your Info:",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Name ",
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Email ",
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Username ",
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ]),
                            const SizedBox(width: 50),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(userData['firstname'] +
                                      " " +
                                      userData['lastname']),
                                  const SizedBox(height: 10),
                                  Text(userData['email']),
                                  const SizedBox(height: 10),
                                  Text(userData['username']),
                                ])
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 100,
                          child: OutlinedButton(
                            onPressed: () => logout(context),
                            child: const Row(
                                children: [Icon(Icons.logout), Text("Logout")]),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text("Preferences:",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const Preferences(),
                        snapshot.data['team'] != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Your Team:",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            "Code ",
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 50,
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                  "${snapshot.data['team']['code']}"),
                                              const SizedBox(width: 10),
                                              IconButton(
                                                  onPressed: () {
                                                    Share.share(
                                                        'Join my team on MovieFinder! Code: ${snapshot.data['team']['code']}. Check it out! https://moviefinder.robinaerts.be',
                                                        subject:
                                                            "Join my team on MovieFinder!");
                                                  },
                                                  icon: const Icon(Icons.share))
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  ListView.builder(
                                      shrinkWrap: true,
                                      itemCount:
                                          snapshot.data['members'].length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return ListTile(
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  0, 10, 0, 0),
                                          title: Text(snapshot.data['members']
                                                  [index]['firstname'] +
                                              " " +
                                              snapshot.data['members'][index]
                                                  ['lastname']),
                                          subtitle: Text(snapshot
                                              .data['members'][index]['email']),
                                        );
                                      }),
                                  // Leave team button
                                  Container(
                                    width: 135,
                                    padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                                    child: FilledButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.red)),
                                      onPressed: () => leaveTeam(context),
                                      child: const Row(children: [
                                        Icon(Icons.logout),
                                        Text("Leave Team")
                                      ]),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Join or create a team:",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 20),
                                  Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 20, 0, 20),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("Don't have a group?",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          _loading
                                              ? const CircularProgressIndicator()
                                              : ElevatedButton(
                                                  onPressed: createGroup,
                                                  child:
                                                      const Text("Create One")),
                                        ]),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 20, 0, 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("I received a code",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          TextField(
                                            controller: groupCodeController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText:
                                                  'Enter your 9-digit code',
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          _loading
                                              ? const CircularProgressIndicator()
                                              : OutlinedButton(
                                                  onPressed: joinGroup,
                                                  child:
                                                      const Text("Join Group"))
                                        ],
                                      ))
                                ],
                              )
                      ])),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
