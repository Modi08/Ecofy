import 'dart:convert';

import 'package:ecofy/pages/login_screen.dart';
import 'package:ecofy/services/general/image_upload.dart';
import 'package:ecofy/services/general/localstorage.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SettingsScreen extends StatefulWidget {
  final DatabaseService database;
  final Function refreshData;
  final String userId;
  final WebSocketChannel socket;
  final double width;
  final double height;
  const SettingsScreen(
      {super.key,
      required this.database,
      required this.refreshData,
      required this.userId,
      required this.socket,
      required this.width,
      required this.height});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: 'Search for a setting...',
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSettingsCategory(
                  context,
                  icon: Icons.image,
                  title: "Change Profile Picture",
                  onTap: () {
                    selectImage(widget.userId, widget.database, widget.socket);
                  },
                ),
                _buildSettingsCategory(
                  context,
                  icon: Icons.person,
                  title: "Edit Username",
                  onTap: () {
                    _showEditDialog(context, "Edit Username",
                        "Enter your new username", "username");
                  },
                ),
                _buildSettingsCategory(
                  context,
                  icon: Icons.info_outline,
                  title: "Edit Bio",
                  onTap: () {
                    _showEditDialog(
                        context, "Edit Bio", "Enter your new bio", "bio");
                  },
                ),
                _buildSettingsCategory(
                  context,
                  icon: Icons.email_outlined,
                  title: "Edit Email",
                  onTap: () {
                    _showEditDialog(
                        context, "Edit Email", "Enter your new email", "email");
                  },
                ),
                _buildSettingsCategory(
                  context,
                  icon: Icons.lock_outline,
                  title: "Change Password",
                  onTap: () {
                    _showEditDialog(context, "Change Password",
                        "Enter your new password", "pwd");
                  },
                ),
                _buildSettingsCategory(
                  context,
                  icon: Icons.notifications_active,
                  title: "Notifications",
                  onTap: () {
                    _showEditDialog(context, "Notifications",
                        "Change notification preferences", "");
                  },
                ),
                _buildSettingsCategory(
                  context,
                  icon: Icons.brightness_6,
                  title: "Appearance",
                  onTap: () {
                    _toggleDarkModeDialog(context);
                  },
                ),
                _buildSettingsCategory(
                  context,
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HelpSupportScreen()),
                    );
                  },
                ),
                _buildSettingsCategory(
                  context,
                  icon: Icons.info,
                  title: "About",
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
                _buildSettingsCategory(
                  context,
                  icon: Icons.delete_forever,
                  title: "Delete Account",
                  onTap: () {
                    widget.socket.sink.add(jsonEncode({
                      "action": "deleteUser",
                      "userId": widget.userId,
                    }));
                    
                    widget.database.clearAll().then((data) {
                      widget.refreshData();
                    });

                    widget.socket.sink.close();
                    
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(
                            database: widget.database,
                            height: widget.height,
                            width: widget.width),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCategory(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: widget.width * 0.08, color: Colors.green),
            SizedBox(width: widget.width * 0.04),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, String title, String hint, String key) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hint),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (key != "") {
                  widget.socket.sink.add(jsonEncode({
                    "action": "updateUserData",
                    "userId": widget.userId,
                    "key": key,
                    "value": controller.text
                  }));
                  widget.database
                      .updateValue(key, controller.text, widget.userId)
                      .then((data) {
                    widget.refreshData();
                  });
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("About"),
          content:
              const Text("This is a demo settings page created using Flutter."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _toggleDarkModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Appearance"),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Dark Mode"),
              Switch(
                value: isDarkMode,
                onChanged: (value) {
                  setState(() {
                    isDarkMode = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text('Help & Support Page'),
      ),
    );
  }
}
