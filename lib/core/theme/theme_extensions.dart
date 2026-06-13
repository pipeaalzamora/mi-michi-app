import 'package:flutter/material.dart';

extension ThemeColors on BuildContext {
  ThemeData get theme => Theme.of(this);

  bool get isDarkMode => theme.brightness == Brightness.dark;

  Color get cardFill => theme.cardTheme.color ?? theme.colorScheme.surface;

  Color get subtleFill =>
      isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);

  Color get chipFill =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFF3F4F6);

  Color get appBorder =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

  Color get mutedText =>
      isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);

  Color get softText =>
      isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

  Color get placeholderFill =>
      isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

  Color get softShadow => isDarkMode
      ? Colors.black.withValues(alpha: 0.24)
      : Colors.black.withValues(alpha: 0.05);

  Color softTint(Color color) =>
      isDarkMode ? color.withValues(alpha: 0.18) : color;
}
