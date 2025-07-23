import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moviefinder/pages/main_app.dart';
import 'package:share_plus/share_plus.dart';
import 'preferences.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final groupCodeController = TextEditingController();
  bool _loading = false;
  final User _user = FirebaseAuth.instance.currentUser!;
  late Future<Map<String, dynamic>> _teamAndMembersFuture = getTeamAndMembers();

  @override
  void initState() {
    super.initState();
  }

  void _refreshTeamAndMembers() {
    setState(() {
      _teamAndMembersFuture = getTeamAndMembers();
    });
  }

  Future<void> createGroup() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    setState(() {
      _loading = true;
    });
    String id = DateTime.now()
        .toUtc()
        .millisecondsSinceEpoch
        .toString()
        .substring(4);
    try {
      await FirebaseFirestore.instance.collection("groups").doc(id).set({
        "code": id,
        "members": [FirebaseAuth.instance.currentUser!.uid],
      });
      if (mounted) {
        setState(() {
          _loading = false;
        });
        _refreshTeamAndMembers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Team created successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        print("Error creating group: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to create team. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> joinGroup() async {
    if (groupCodeController.text.isEmpty) return;
    setState(() {
      _loading = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection("groups")
          .doc(groupCodeController.text)
          .update({
            "members": FieldValue.arrayUnion([_user.uid]),
          });
      if (mounted) {
        setState(() {
          _loading = false;
        });
        groupCodeController.clear(); // Clear the input field
        _refreshTeamAndMembers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully joined the team!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        print("Error joining group: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Failed to join group. Code might be invalid or network error.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.of(context).pushReplacementNamed("/");
  }

  Future<void> leaveTeam() async {
    setState(() {
      _loading = true;
    });
    try {
      QuerySnapshot groupQuery = await FirebaseFirestore.instance
          .collection("groups")
          .where('members', arrayContains: _user.uid)
          .get();
      if (groupQuery.docs.isNotEmpty) {
        await groupQuery.docs[0].reference.update({
          "members": FieldValue.arrayRemove([_user.uid]),
        });
      }
      if (mounted) {
        setState(() {
          _loading = false;
        });
        _refreshTeamAndMembers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully left the team!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        print("Error leaving team: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to leave team. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>> getTeamAndMembers() async {
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .get();
    Map<String, dynamic>? currentUserData = userDoc.data();

    QuerySnapshot teamQuery = await FirebaseFirestore.instance
        .collection('groups')
        .where('members', arrayContains: _user.uid)
        .get();

    if (teamQuery.docs.isEmpty) {
      return {
        "team": null,
        "membersData": currentUserData != null
            ? [currentUserData]
            : <Map<String, dynamic>>[],
        "currentUser": currentUserData,
      };
    }

    var teamData = teamQuery.docs[0].data() as Map<String, dynamic>;
    List<Map<String, dynamic>> memberDataList = [];

    if (teamData['members'] is List) {
      for (final memberId in teamData['members']) {
        try {
          final memberDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(memberId)
              .get();
          if (memberDoc.exists) {
            final memberData = memberDoc.data();
            if (memberData != null) {
              memberDataList.add(memberData);
            }
          }
        } catch (e) {
          print('Error fetching member data for $memberId: $e');
        }
      }
    }
    return {
      "team": teamData,
      "membersData": memberDataList,
      "currentUser": currentUserData,
    };
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    EdgeInsets? padding,
  }) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15.0),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          const SizedBox(width: 10.0),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _teamAndMembersFuture,
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("Error loading profile: ${snapshot.error}"),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("No profile data found."));
        }

        final data = snapshot.data!;
        final Map<String, dynamic>? currentUser = data['currentUser'];
        final Map<String, dynamic>? team = data['team'];
        final List<Map<String, dynamic>> membersData =
            data['membersData'] ?? [];

        if (currentUser == null) {
          // This case should ideally not happen if user is logged in
          return const Center(child: Text("Could not load user information."));
        }

        return Scaffold(
          // appBar: AppBar(title: Text("Profile")), // Optional: if you want an AppBar
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Hi, ${currentUser['firstname'] ?? 'User'}!",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20.0),
                _buildSectionCard(
                  title: "Your Info",
                  children: [
                    _buildInfoRow(
                      "Name",
                      "${currentUser['firstname'] ?? ''} ${currentUser['lastname'] ?? ''}",
                    ),
                    _buildInfoRow("Email", currentUser['email'] ?? 'N/A'),
                    _buildInfoRow("Username", currentUser['username'] ?? 'N/A'),
                    const SizedBox(height: 20.0),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text("Logout"),
                        onPressed: logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                _buildSectionCard(
                  title: "Preferences",
                  children: [const Preferences()],
                ),
                if (team != null) ...[
                  _buildSectionCard(
                    title: "Your Team",
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              "Code: ${team['code']}",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.share,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () {
                              Share.share(
                                'Join my team on MovieFinder! Code: ${team['code']}. Check it out! https://moviefinder.robinaerts.be',
                                subject: "Join my team on MovieFinder!",
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        "Members:",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 5.0),
                      if (membersData.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: membersData.length,
                          itemBuilder: (context, index) {
                            final member = membersData[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  (member['firstname'] ?? 'N')[0].toUpperCase(),
                                ),
                              ),
                              title: Text(
                                "${member['firstname'] ?? ''} ${member['lastname'] ?? ''}",
                              ),
                              subtitle: Text(member['email'] ?? 'No email'),
                              dense: true,
                            );
                          },
                        )
                      else
                        const Text("No member details found."),
                      const SizedBox(height: 20.0),
                      Center(
                        child: _loading
                            ? const CircularProgressIndicator()
                            : ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.exit_to_app,
                                  color: Colors.white,
                                ),
                                label: const Text("Leave Team"),
                                onPressed: leaveTeam,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orangeAccent,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                      ),
                    ],
                  ),
                ] else ...[
                  _buildSectionCard(
                    title: "Join or Create a Team",
                    padding: const EdgeInsets.all(
                      20.0,
                    ), // More padding for action sections
                    children: [
                      Text(
                        "Don't have a team yet?",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10.0),
                      _loading &&
                              groupCodeController
                                  .text
                                  .isEmpty // Show loader for create if not joining
                          ? const Center(child: CircularProgressIndicator())
                          : Center(
                              child: FilledButton.icon(
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text("Create a New Team"),
                                onPressed: createGroup,
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 40),
                                ),
                              ),
                            ),
                      const SizedBox(height: 30.0),
                      Text(
                        "Already have a code?",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10.0),
                      TextField(
                        controller: groupCodeController,
                        keyboardType: TextInputType
                            .text, // Changed to text for flexibility, can be numbers too
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(9),
                        ], // Max 9 chars for group code
                        decoration: InputDecoration(
                          hintText: 'Enter 9-digit team code',
                          border: const OutlineInputBorder(),
                          suffixIcon:
                              _loading && groupCodeController.text.isNotEmpty
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                                )
                              : null,
                        ),
                        onChanged: (value) =>
                            setState(() {}), // To update suffixIcon visibility
                      ),
                      const SizedBox(height: 15.0),
                      _loading && groupCodeController.text.isNotEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : Center(
                              child: FilledButton.icon(
                                icon: const Icon(Icons.group_add_outlined),
                                label: const Text("Join Team"),
                                onPressed: groupCodeController.text.isNotEmpty
                                    ? joinGroup
                                    : null, // Disable if no code
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 40),
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
                const SizedBox(height: 20), // Bottom padding
              ],
            ),
          ),
        );
      },
    );
  }
}
