// edit_esp32_url_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/esp32_url_provider.dart';

Future<void> showEditESP32URLDialog(BuildContext context, VoidCallback onUrlSaved) async {
  final TextEditingController controller = TextEditingController();
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Edit ESP32 URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Enter ESP32 URL'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final String newUrl = controller.text;
              final ESP32UrlProvider provider = Provider.of<ESP32UrlProvider>(context, listen: false);
              provider.esp32Url = newUrl;
              Navigator.pop(context);

              // Execute the callback after saving the URL
              onUrlSaved();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
