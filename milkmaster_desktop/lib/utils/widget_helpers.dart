import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Widget leadingIcon(dynamic icon, {double width = 25, double height = 25}) {
  if (icon is IconData) {
    return Icon(icon, color: const Color.fromRGBO(27, 27, 27, 1));
  } else if (icon is String) {
    return Image.asset(icon, width: width, height: height, fit: BoxFit.contain);
  } else {
    return const SizedBox();
  }
}

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onConfirm,
  bool showCancel = true,
}) async {
  return showDialog(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onConfirm();
          },
          child: const Text("OK"),
        ),
        if (showCancel)
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text("Cancel"),
          ),
      ],
    ),
  );
}

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
            child: Text(
              'No data available',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
            ),
          );
  }
}

class FilePickerWithPreview extends StatefulWidget {
  final void Function(File? file)? onFileSelected;

  const FilePickerWithPreview({Key? key, this.onFileSelected}) : super(key: key);

  @override
  State<FilePickerWithPreview> createState() => _FilePickerWithPreviewState();
}

class _FilePickerWithPreviewState extends State<FilePickerWithPreview> {
  File? _selectedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = File(result.files.first.path!);
      });

      if (widget.onFileSelected != null) {
        widget.onFileSelected!(_selectedFile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: _pickFile,
          child: Text(_selectedFile == null ? 'Select Image' : 'Change Image'),
        ),
        const SizedBox(height: 10),
        if (_selectedFile != null)
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: Image.file(
              _selectedFile!,
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }
}