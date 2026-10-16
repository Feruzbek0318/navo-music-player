import '../../../l10n/generated/app_localizations.dart';
import '../data/app_settings.dart';

/// Native language names, readable whatever the current locale is.
const languageNames = {'uz': 'Oʻzbekcha', 'ru': 'Русский', 'en': 'English'};

String navTabLabel(AppLocalizations l, NavTab t) => switch (t) {
  NavTab.home => l.navHome,
  NavTab.favorites => l.navFavorites,
  NavTab.playlists => l.navPlaylists,
  NavTab.settings => l.navSettings,
};

String homeTabLabel(AppLocalizations l, HomeTab t) => switch (t) {
  HomeTab.suggested => l.tabSuggested,
  HomeTab.songs => l.tabSongs,
  HomeTab.artists => l.tabArtists,
  HomeTab.albums => l.tabAlbums,
  HomeTab.folders => l.tabFolders,
};

String themeModeLabel(AppLocalizations l, AppThemeMode m) => switch (m) {
  AppThemeMode.system => l.themeSystem,
  AppThemeMode.light => l.themeLight,
  AppThemeMode.dark => l.themeDark,
  AppThemeMode.amoled => l.themeAmoled,
};

String accentModeLabel(AppLocalizations l, AccentMode m) => switch (m) {
  AccentMode.preset => l.accentPreset,
  AccentMode.custom => l.accentCustom,
  AccentMode.materialYou => l.accentMaterialYou,
  AccentMode.adaptive => l.accentAdaptive,
};

String fontLabel(AppLocalizations l, AppFont f) => switch (f) {
  AppFont.urbanist => 'Urbanist',
  AppFont.manrope => 'Manrope',
  AppFont.nunito => 'Nunito',
  AppFont.montserrat => 'Montserrat',
};

String cornersLabel(AppLocalizations l, CornerStyle c) => switch (c) {
  CornerStyle.sharp => l.cornersSharp,
  CornerStyle.medium => l.cornersMedium,
  CornerStyle.round => l.cornersRound,
};

String densityLabel(AppLocalizations l, ListDensity d) => switch (d) {
  ListDensity.compact => l.densityCompact,
  ListDensity.comfortable => l.densityComfortable,
  ListDensity.spacious => l.densitySpacious,
};

String artShapeLabel(AppLocalizations l, ArtShape s) => switch (s) {
  ArtShape.square => l.artworkSquare,
  ArtShape.rounded => l.shapeRounded,
  ArtShape.circle => l.shapeCircle,
};

String artSizeLabel(AppLocalizations l, ArtSize s) => switch (s) {
  ArtSize.small => l.sizeSmall,
  ArtSize.medium => l.sizeMedium,
  ArtSize.large => l.sizeLarge,
};

String playerStyleLabel(AppLocalizations l, PlayerStyle s) => switch (s) {
  PlayerStyle.classic => l.styleClassic,
  PlayerStyle.vinyl => l.artworkVinyl,
  PlayerStyle.minimal => l.styleMinimal,
  PlayerStyle.blurred => l.styleBlurred,
};

String miniPlayerLabel(AppLocalizations l, MiniPlayerStyle s) => switch (s) {
  MiniPlayerStyle.floating => l.miniFloating,
  MiniPlayerStyle.docked => l.miniDocked,
};

String animationLabel(AppLocalizations l, AnimationLevel a) => switch (a) {
  AnimationLevel.full => l.animFull,
  AnimationLevel.reduced => l.animReduced,
  AnimationLevel.off => l.animOff,
};

String languageLabel(AppLocalizations l, String? code) => code == null ? l.languageSystem : languageNames[code]!;

String percent(AppLocalizations l, double v) => l.percentValue((v * 100).round());

String clockLabel(int minutes) =>
    '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

String headsetActionLabel(AppLocalizations l, HeadsetAction a) => switch (a) {
  HeadsetAction.playPause => l.actionPlayPause,
  HeadsetAction.next => l.actionNext,
  HeadsetAction.previous => l.actionPrevious,
  HeadsetAction.none => l.actionNone,
};
