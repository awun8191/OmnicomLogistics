import 'package:flutter/material.dart';

Widget buildModalTextField({
  required BuildContext context,
  required TextEditingController controller,
  required String label,
  String? hintText,
  String? Function(String?)? validator,
  bool isNumeric = false,
  bool isMultiline = false,
  bool enabled = true,
  IconData? icon,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      prefixIcon:
          icon != null ? Icon(icon, color: colorScheme.onSurfaceVariant) : null,
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    style: TextStyle(color: colorScheme.onSurface),
    keyboardType:
        isNumeric
            ? TextInputType.number
            : (isMultiline ? TextInputType.multiline : TextInputType.text),
    maxLines: isMultiline ? 3 : 1,
    enabled: enabled,
    validator: validator,
  );
}
