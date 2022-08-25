import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late String currentRegion;
  late bool currentStreaming;

  void setCode(code) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString("region", code.code);
    setState(() {
      currentRegion = code.code;
    });
  }

  void getCurrentRegion() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      currentRegion = prefs.getString("region") ?? "US";
      currentStreaming = prefs.getBool("onlyStreaming") ?? false;
    });
  }

  void setStreaming(bool value) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool("onlyStreaming", value);
  }

  @override
  void initState() {
    getCurrentRegion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Container(
        margin: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text("Select your region: "),
                CountryListPick(
                    appBar: AppBar(
                      backgroundColor: Colors.blue,
                      title: const Text('Pick your country'),
                    ),

                    // To disable option set to false
                    theme: CountryTheme(
                      isShowFlag: true,
                      isShowTitle: true,
                      isShowCode: true,
                      isDownIcon: true,
                      showEnglishName: true,
                    ),
                    // Set default value
                    initialSelection: currentRegion,
                    onChanged: ((code) => setCode(code)),
                    useUiOverlay: true,
                    useSafeArea: false),
              ],
            ),
            Row(
              children: [
                const Text(
                    "Only show movies that are available on streaming sites"),
                Switch(
                  value: true,
                  onChanged: (value) {
                    setStreaming(value);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
