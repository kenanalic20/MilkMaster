import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:milkmaster_desktop/main.dart';

Widget leadingIcon(dynamic icon, {double width = 25, double height = 25}) {
  if (icon is IconData) {
    return Icon(icon, color: const Color.fromRGBO(27, 27, 27, 1));
  } else if (icon is String) {
    return Image.asset(icon, width: width, height: height, fit: BoxFit.contain);
  } else {
    return const SizedBox();
  }
}

String? toIso(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value.toIso8601String();
  return value.toString();
}


String formatDouble(double value) {
  double rounded = double.parse(value.toStringAsFixed(2));

  if (rounded == rounded.floor()) {
    return rounded.floor().toString();
  } else {
    return rounded.toStringAsFixed(2); 
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
    builder:
        (BuildContext dialogContext) => AlertDialog(
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
  const NoDataWidget({super.key});

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
  final String? imageUrl; // 👈 optional initial image from backend

  const FilePickerWithPreview({Key? key, this.onFileSelected, this.imageUrl})
    : super(key: key);

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

      widget.onFileSelected?.call(_selectedFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasLocalFile = _selectedFile != null;
    final bool hasNetworkImage =
        widget.imageUrl != null && widget.imageUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasLocalFile || hasNetworkImage)
          Center(
            child: Container(
              width: 300,
              height: 300,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Theme.of(context).colorScheme.secondary,
              ),
              child:
                  hasLocalFile
                      ? Image.file(_selectedFile!, fit: BoxFit.cover)
                      : Image.network(
                        widget.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                      ),
            ),
          ),
        SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),
        Center(
          child: ElevatedButton(
            onPressed: _pickFile,
            child: Text(hasLocalFile ? 'Change Image' : 'Select Image'),
          ),
        ),
        SizedBox(height: Theme.of(context).extension<AppSpacing>()!.medium),
      ],
    );
  }
}

Color hexToColor(String hex) {
  hex = hex.replaceAll("#", "");
  if (hex.length == 6) {
    hex = "FF$hex";
  }
  return Color(int.parse(hex, radix: 16));
}

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int pageSize;
  final ValueChanged<int> onPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.pageSize,
    required this.onPageChanged,
  });

  int get totalPages => (totalItems / pageSize).ceil();

  List<int> get pageNumbers {
    return List<int>.generate(totalPages, (index) => index + 1);
  }

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox();

    return Padding(
      padding: EdgeInsets.only(
        top: Theme.of(context).extension<AppSpacing>()!.medium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 5,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.tertiary,
                width: 1,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.chevron_left, size: 18),
              onPressed:
                  currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            ),
          ),
          ...pageNumbers.map((page) {
            final bool isSelected = page == currentPage;
            return Container(
              width: 30,
              height: 30,
              child: Material(
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                shape: CircleBorder(
                  side: BorderSide(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.tertiary,
                    width: 1,
                  ),
                ),
                child: InkWell(
                  customBorder: CircleBorder(),
                  onTap: () => onPageChanged(page),
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Center(
                      child: Text(
                        page.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.tertiary,
                width: 1,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.chevron_right, size: 18),
              onPressed:
                  currentPage < totalPages
                      ? () => onPageChanged(currentPage + 1)
                      : null,
            ),
          ),
        ],
      ),
    );
  }
}
