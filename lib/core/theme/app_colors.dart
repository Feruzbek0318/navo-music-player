import 'package:flutter/material.dart';

/// Static colour constants that don't depend on the theme. Everything that
/// changes with light/dark/AMOLED or the accent lives in [NavoTheme]
/// (`context.navo`).
abstract final class AppColors {
  /// Brand orange, the default accent.
  static const brand = Color(0xFFFF9F1C);

  static const accentPresets = <Color>[
    Color(0xFFFF9F1C), // Navo orange
    Color(0xFFFF5A5F), // coral
    Color(0xFFE84393), // pink
    Color(0xFFA55EEA), // violet
    Color(0xFF6C5CE7), // indigo
    Color(0xFF3D8BFD), // blue
    Color(0xFF00B4D8), // cyan
    Color(0xFF00B894), // teal
    Color(0xFF2ECC71), // green
    Color(0xFFA3CB38), // lime
    Color(0xFFF7C948), // amber
    Color(0xFFE17055), // terracotta
    Color(0xFF95A5A6), // slate
  ];

  /// Gradients used for generated artwork placeholders.
  static const artworkGradients = <List<Color>>[
    [Color(0xFFFF9F1C), Color(0xFFE2412F)],
    [Color(0xFF6A5AE0), Color(0xFF2CC5D2)],
    [Color(0xFFF15BB5), Color(0xFF7B2FF7)],
    [Color(0xFF00B894), Color(0xFF0984E3)],
    [Color(0xFFFFC75F), Color(0xFFFF6F91)],
    [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
  ];
}
