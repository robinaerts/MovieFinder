import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences extends StatefulWidget {
  const Preferences({Key? key}) : super(key: key);

  @override
  State<Preferences> createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
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
    setState(() {
      currentStreaming = value;
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentRegion();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 30, 0, 20),
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
              const Text("Available on streaming sites"),
              Switch(
                value: currentStreaming,
                onChanged: (value) {
                  setStreaming(value);
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
