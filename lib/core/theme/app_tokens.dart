import 'package:flutter/widgets.dart';

/// Spacing scale (logical pixels).
abstract final class Insets {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Horizontal page padding used by every screen.
  static const double page = 20;
  static const pagePadding = EdgeInsets.symmetric(horizontal: page);
}

abstract final class Radii {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 100;

  static const card = BorderRadius.all(Radius.circular(md));
  static const tile = BorderRadius.all(Radius.circular(sm));
  static const sheet = BorderRadius.vertical(top: Radius.circular(xl));
}

/// Animation durations, scaled by the user's animation level (and the
/// system "remove animations" setting). [factor] is updated by the app root.
abstract final class AppDurations {
  /// 1 = full, 0.5 = reduced, 0 = off.
  static double factor = 1;

  static Duration _d(int ms) => Duration(milliseconds: (ms * factor).round());

  static Duration get fast => _d(200);
  static Duration get medium => _d(300);
  static Duration get slow => _d(450);
  static Duration get stagger => _d(40);
}

abstract final class AppCurves {
  static const standard = Curves.easeOutCubic;
  static const emphasized = Curves.easeInOutCubicEmphasized;
  static const decelerate = Curves.decelerate;
}

abstract final class Sizes {
  static const double songArtwork = 52;
  static const double miniPlayerHeight = 64;
  static const double bottomNavHeight = 64;
  static const double carouselItem = 128;
  static const double artistAvatar = 112;
  static const double playButton = 64;
  static const double smallPlayButton = 26;
}
