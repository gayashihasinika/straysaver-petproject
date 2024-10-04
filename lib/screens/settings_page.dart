import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'),
      centerTitle: true,
      ),
      body:Stack(
        children: [
      // Background colour
      Container(
      decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.orange.shade400, Colors.orange.shade600, Colors.orange.shade800],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
    ),
    ),
    ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Theme'),
            value: themeNotifier.isDarkMode,
            onChanged: (value) {
              themeNotifier.toggleTheme();
            },
          ),
        ],
      ),
    ],
      ),
    );
  }
}
