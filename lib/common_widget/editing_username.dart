import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moneytracker/view/sqflite/db_helper.dart'; // Import your DatabaseHelper for saving the username

class EditUsernameDialog extends StatefulWidget {
  final String currentUsername;
  final String currentEmail;

  const EditUsernameDialog(
      {super.key, required this.currentUsername, required this.currentEmail});

  @override
  _EditUsernameDialogState createState() => _EditUsernameDialogState();
}

class _EditUsernameDialogState extends State<EditUsernameDialog> {
  final TextEditingController _usernameController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _usernameController.text =
        widget.currentUsername; // Pre-fill current username
  }

  Future<void> _saveUsername() async {
    String newUsername = _usernameController.text.trim();
    if (newUsername.isNotEmpty) {
      // Call your method to update the username in the database
      await _databaseHelper.updateUsername(newUsername, widget.currentEmail);

      // Show a toast on success
      Fluttertoast.showToast(
        msg: "Username updated successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      Navigator.of(context).pop(true); // Close dialog and return success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Adjust dialog size based on content
          children: [
            const Text(
              'Edit Username',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Close without saving
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _saveUsername, // Save new username
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
