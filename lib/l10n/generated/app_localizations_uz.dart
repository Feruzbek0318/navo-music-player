// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appName => 'Navo';

  @override
  String get appTagline => 'Musiqangiz — internetsiz';

  @override
  String get onboardingTitle1 =>
      'Qurilmangizdagi barcha musiqalar uchun qulay pleyer';

  @override
  String get onboardingTitle2 => 'Har safar tiniq va boy ovoz';

  @override
  String get onboardingTitle3 => 'Sevimli musiqalaringizni Navo bilan tinglang';

  @override
  String get next => 'Keyingi';

  @override
  String get getStarted => 'Boshlash';

  @override
  String get skip => 'Oʻtkazib yuborish';

  @override
  String get tabSuggested => 'Tavsiyalar';

  @override
  String get tabSongs => 'Qoʻshiqlar';

  @override
  String get tabArtists => 'Ijrochilar';

  @override
  String get tabAlbums => 'Albomlar';

  @override
  String get tabFolders => 'Jildlar';

  @override
  String get navHome => 'Asosiy';

  @override
  String get navFavorites => 'Sevimlilar';

  @override
  String get navPlaylists => 'Pleylistlar';

  @override
  String get navSettings => 'Sozlamalar';

  @override
  String get recentlyPlayed => 'Yaqinda tinglangan';

  @override
  String get mostPlayed => 'Koʻp tinglangan';

  @override
  String get seeAll => 'Barchasi';

  @override
  String get songs => 'Qoʻshiqlar';

  @override
  String get search => 'Qidiruv';

  @override
  String songsCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ta qoʻshiq',
      zero: 'Qoʻshiq yoʻq',
    );
    return '$_temp0';
  }

  @override
  String albumsCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ta albom',
      zero: 'Albom yoʻq',
    );
    return '$_temp0';
  }

  @override
  String artistsCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ta ijrochi',
      zero: 'Ijrochi yoʻq',
    );
    return '$_temp0';
  }

  @override
  String foldersCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ta jild',
      zero: 'Jild yoʻq',
    );
    return '$_temp0';
  }

  @override
  String playlistsCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString ta pleylist',
      zero: 'Pleylist yoʻq',
    );
    return '$_temp0';
  }

  @override
  String durationMins(String time) {
    return '$time daq';
  }

  @override
  String minutesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count daqiqa',
    );
    return '$_temp0';
  }

  @override
  String get sortBy => 'Saralash';

  @override
  String get sortAscending => 'Oʻsish boʻyicha';

  @override
  String get sortDescending => 'Kamayish boʻyicha';

  @override
  String get sortArtist => 'Ijrochi';

  @override
  String get sortAlbum => 'Albom';

  @override
  String get sortYear => 'Yil';

  @override
  String get sortDateAdded => 'Qoʻshilgan sana';

  @override
  String get sortDateModified => 'Oʻzgartirilgan sana';

  @override
  String get sortComposer => 'Bastakor';

  @override
  String get sortSongCount => 'Qoʻshiqlar soni';

  @override
  String get sortAlbumCount => 'Albomlar soni';

  @override
  String get play => 'Tinglash';

  @override
  String get shuffle => 'Aralash';

  @override
  String get playNext => 'Keyingi boʻlib qoʻyish';

  @override
  String get addToQueue => 'Navbatga qoʻshish';

  @override
  String get addToPlaylist => 'Pleylistga qoʻshish';

  @override
  String get goToAlbum => 'Albomga oʻtish';

  @override
  String get goToArtist => 'Ijrochiga oʻtish';

  @override
  String get details => 'Maʼlumotlar';

  @override
  String get setAsRingtone => 'Qoʻngʻiroq ohangi qilish';

  @override
  String get addToBlocklist => 'Qora roʻyxatga qoʻshish';

  @override
  String get share => 'Ulashish';

  @override
  String get deleteFromDevice => 'Qurilmadan oʻchirish';

  @override
  String get addToFavorites => 'Sevimlilarga qoʻshish';

  @override
  String get removeFromFavorites => 'Sevimlilardan olib tashlash';

  @override
  String get removeFromPlaylist => 'Pleylistdan olib tashlash';

  @override
  String get removeFromQueue => 'Navbatdan olib tashlash';

  @override
  String get more => 'Yana';

  @override
  String get songDetails => 'Qoʻshiq haqida';

  @override
  String get detailTitle => 'Nomi';

  @override
  String get detailArtist => 'Ijrochi';

  @override
  String get detailAlbum => 'Albom';

  @override
  String get detailComposer => 'Bastakor';

  @override
  String get detailGenre => 'Janr';

  @override
  String get detailYear => 'Yil';

  @override
  String get detailDuration => 'Davomiyligi';

  @override
  String get detailFormat => 'Format';

  @override
  String get detailSize => 'Hajmi';

  @override
  String get detailPath => 'Joylashuvi';

  @override
  String get detailDateAdded => 'Qoʻshilgan sana';

  @override
  String get unknown => 'Nomaʼlum';

  @override
  String get unknownArtist => 'Nomaʼlum ijrochi';

  @override
  String get unknownAlbum => 'Nomaʼlum albom';

  @override
  String get demoTrack => 'Demo';

  @override
  String get close => 'Yopish';

  @override
  String get lyrics => 'Qoʻshiq matni';

  @override
  String get noLyrics => 'Matn topilmadi';

  @override
  String get noLyricsHint =>
      'Qoʻshiq yoniga xuddi shu nomdagi .lrc faylni qoʻying yoki matnni fayl teglariga yozing.';

  @override
  String get playingQueue => 'Ijro navbati';

  @override
  String get queueEmpty => 'Navbat boʻsh';

  @override
  String get nowPlaying => 'Hozir ijro etilmoqda';

  @override
  String get playbackSpeed => 'Ijro tezligi';

  @override
  String get sleepTimer => 'Uyqu taymeri';

  @override
  String get sleepTimerEndOfTrack => 'Joriy qoʻshiq oxirida';

  @override
  String get sleepTimerOff => 'Taymerni oʻchirish';

  @override
  String sleepTimerRemaining(String time) {
    return '$time dan soʻng toʻxtaydi';
  }

  @override
  String sleepTimerSet(String minutes) {
    return 'Ijro ${minutes}dan soʻng toʻxtaydi';
  }

  @override
  String get sleepTimerEndSet => 'Ijro shu qoʻshiqdan soʻng toʻxtaydi';

  @override
  String get audioOutput => 'Audio chiqish';

  @override
  String get audioOutputUnavailable =>
      'Bu qurilmada chiqish tanlovini ochib boʻlmadi';

  @override
  String get volume => 'Ovoz balandligi';

  @override
  String get repeatOff => 'Takrorlash oʻchiq';

  @override
  String get repeatAll => 'Barchasini takrorlash';

  @override
  String get repeatOne => 'Bittasini takrorlash';

  @override
  String get shuffleOn => 'Aralash ijro yoqildi';

  @override
  String get shuffleOff => 'Aralash ijro oʻchirildi';

  @override
  String get previous => 'Oldingi';

  @override
  String get pause => 'Pauza';

  @override
  String get rewind10 => '10 soniya orqaga';

  @override
  String get forward10 => '10 soniya oldinga';

  @override
  String get back => 'Orqaga';

  @override
  String get favorites => 'Sevimlilar';

  @override
  String get noFavorites => 'Hozircha sevimlilar yoʻq';

  @override
  String get noFavoritesHint =>
      'Qoʻshiqni bu yerda saqlash uchun yurakcha belgisini bosing.';

  @override
  String get addedToFavorites => 'Sevimlilarga qoʻshildi';

  @override
  String get removedFromFavorites => 'Sevimlilardan olib tashlandi';

  @override
  String get playlists => 'Pleylistlar';

  @override
  String get newPlaylist => 'Yangi pleylist';

  @override
  String get playlistName => 'Pleylist nomi';

  @override
  String get create => 'Yaratish';

  @override
  String get rename => 'Nomini oʻzgartirish';

  @override
  String get renamePlaylist => 'Pleylist nomini oʻzgartirish';

  @override
  String get delete => 'Oʻchirish';

  @override
  String get cancel => 'Bekor qilish';

  @override
  String get save => 'Saqlash';

  @override
  String get deletePlaylistTitle => 'Pleylist oʻchirilsinmi?';

  @override
  String deletePlaylistMessage(String name) {
    return '“$name” pleylisti oʻchiriladi. Qoʻshiqlar qurilmada qoladi.';
  }

  @override
  String get noPlaylists => 'Hozircha pleylistlar yoʻq';

  @override
  String get noPlaylistsHint =>
      'Sevimli qoʻshiqlaringizni bir joyga yigʻish uchun pleylist yarating.';

  @override
  String get emptyPlaylist => 'Pleylist boʻsh';

  @override
  String get emptyPlaylistHint =>
      'Qoʻshiq menyusidan qoʻshing: ⋮ → Pleylistga qoʻshish.';

  @override
  String addedToPlaylist(String name) {
    return '“$name”ga qoʻshildi';
  }

  @override
  String alreadyInPlaylist(String name) {
    return '“$name”da allaqachon bor';
  }

  @override
  String get playlistNameEmpty => 'Nom kiriting';

  @override
  String get searchHint => 'Qoʻshiq, ijrochi yoki albomni qidiring';

  @override
  String get recentSearches => 'Soʻnggi qidiruvlar';

  @override
  String get clearAll => 'Hammasini tozalash';

  @override
  String noResults(String query) {
    return '“$query” boʻyicha hech narsa topilmadi';
  }

  @override
  String get searchEmptyHint =>
      'Qurilmangizdagi istalgan qoʻshiq, ijrochi yoki albomni toping.';

  @override
  String get nothingPlayedYet => 'Hali hech narsa tinglanmagan';

  @override
  String get nothingPlayedHint =>
      'Siz tinglagan qoʻshiqlar shu yerda koʻrinadi.';

  @override
  String get noArtists => 'Ijrochilar topilmadi';

  @override
  String get noAlbums => 'Albomlar topilmadi';

  @override
  String get noFolders => 'Jildlar topilmadi';

  @override
  String get permissionTitle => 'Musiqangizga ruxsat bering';

  @override
  String get permissionMessage =>
      'Navo qurilmangizdagi audio fayllarni topishi uchun ruxsat kerak. Demo treklar ruxsatsiz ham ishlaydi.';

  @override
  String get permissionDeniedMessage =>
      'Ruxsat berilmadi. Uni tizim sozlamalarida yoqishingiz mumkin.';

  @override
  String get allowAccess => 'Ruxsat berish';

  @override
  String get openSettings => 'Sozlamalarni ochish';

  @override
  String get noSongsTitle => 'Qoʻshiqlar topilmadi';

  @override
  String get noSongsMessage =>
      'Qurilmaga musiqa yuklang yoki demo treklarni tinglang.';

  @override
  String get errorTitle => 'Nimadir xato ketdi';

  @override
  String get retry => 'Qayta urinish';

  @override
  String get addedToQueue => 'Ijro navbatiga qoʻshildi';

  @override
  String get willPlayNext => 'Keyingi boʻlib ijro etiladi';

  @override
  String get addedToBlocklist => 'Kutubxonadan yashirildi';

  @override
  String get undo => 'Qaytarish';

  @override
  String get ringtoneSet => 'Qoʻngʻiroq ohangi oʻrnatildi';

  @override
  String get ringtoneNeedsPermission =>
      'Navo’ga tizim sozlamalarini oʻzgartirishga ruxsat bering va qayta urinib koʻring.';

  @override
  String get actionFailed => 'Amalni bajarib boʻlmadi';

  @override
  String get songDeleted => 'Qoʻshiq oʻchirildi';

  @override
  String get deleteSongTitle => 'Qurilmadan oʻchirilsinmi?';

  @override
  String deleteSongMessage(String title) {
    return '“$title” qurilmangizdan butunlay oʻchiriladi.';
  }

  @override
  String get notAvailableForDemo => 'Demo treklar uchun mavjud emas';

  @override
  String get settings => 'Sozlamalar';

  @override
  String get sectionGeneral => 'Umumiy';

  @override
  String get sectionPlayback => 'Ijro';

  @override
  String get sectionLibrary => 'Kutubxona';

  @override
  String get sectionAbout => 'Ilova haqida';

  @override
  String get language => 'Til';

  @override
  String get languageSystem => 'Tizim tili';

  @override
  String get artworkStyle => 'Pleyerdagi muqova';

  @override
  String get artworkVinyl => 'Plastinka (aylanadi)';

  @override
  String get artworkSquare => 'Kvadrat';

  @override
  String get showDemoTracks => 'Demo treklarni koʻrsatish';

  @override
  String get blockedSongs => 'Yashirilgan qoʻshiqlar';

  @override
  String get blockedSongsEmpty => 'Yashirilgan qoʻshiqlar yoʻq';

  @override
  String get unblock => 'Qaytarish';

  @override
  String get rescanLibrary => 'Kutubxonani yangilash';

  @override
  String get libraryRescanned => 'Kutubxona yangilandi';

  @override
  String get showOnboarding => 'Tanishuvni qayta koʻrsatish';

  @override
  String get about => 'Ilova haqida';

  @override
  String versionLabel(String version) {
    return 'Versiya $version';
  }

  @override
  String get designedBy => 'Dizayn va dasturlash: Feruzbek Namozboyev';

  @override
  String get aboutBio => 'Flutter dasturchi';

  @override
  String get contactTelegram => 'Telegram';

  @override
  String get madeWithFlutter => 'Flutter’da yaratilgan';

  @override
  String copyright(int year) {
    return '© $year Feruzbek Namozboyev';
  }

  @override
  String get linkOpenFailed => 'Havolani ochib boʻlmadi';

  @override
  String get openSourceLicenses => 'Ochiq kodli litsenziyalar';

  @override
  String cannotPlayFile(String title) {
    return '“$title” ijro etilmadi. Keyingi qoʻshiqqa oʻtilmoqda.';
  }

  @override
  String get cannotPlayUnknown => 'Bu faylni ijro etib boʻlmaydi.';

  @override
  String get notificationChannelName => 'Ijro';

  @override
  String get notificationsDeniedMessage =>
      'Musiqani bildirishnomalar paneli va qulf ekranidan boshqarish uchun bildirishnomalarga ruxsat bering.';

  @override
  String get backgroundPlayback => 'Fonda ijro';

  @override
  String get backgroundPlaybackHint =>
      'Ekran oʻchganda musiqa toʻxtab qolsa, Navo uchun batareya cheklovlarini olib tashlang.';

  @override
  String get batterySettings => 'Batareya sozlamalari';

  @override
  String get later => 'Keyinroq';

  @override
  String get contactYouTube => 'YouTube';

  @override
  String get youtubeChannel => 'Feruzbek Namozboyev kanali';

  @override
  String get settingsSearchHint => 'Sozlamalarni qidirish';

  @override
  String get resetAll => 'Barcha sozlamalarni tiklash';

  @override
  String get resetAllTitle => 'Barcha sozlamalar tiklansinmi?';

  @override
  String get resetAllMessage =>
      'Barcha sozlamalar standart holatga qaytadi. Musiqa, pleylistlar va sevimlilar saqlanib qoladi.';

  @override
  String get resetGroup => 'Standart holatga qaytarish';

  @override
  String resetGroupTitle(String group) {
    return '“$group” tiklansinmi?';
  }

  @override
  String get resetGroupMessage =>
      'Bu boʻlimdagi sozlamalar standart holatga qaytadi.';

  @override
  String get reset => 'Tiklash';

  @override
  String get settingsRestored => 'Sozlamalar tiklandi';

  @override
  String noSettingsFound(String query) {
    return '“$query” boʻyicha sozlama topilmadi';
  }

  @override
  String get groupAppearance => 'Koʻrinish';

  @override
  String get groupPlayer => 'Pleyer';

  @override
  String get groupPlayback => 'Ijro';

  @override
  String get groupAudio => 'Ovoz va ekvalayzer';

  @override
  String get groupLibrary => 'Kutubxona';

  @override
  String get groupLyrics => 'Qoʻshiq matni';

  @override
  String get groupNotifications => 'Bildirishnomalar';

  @override
  String get groupGestures => 'Imo-ishoralar';

  @override
  String get groupStorage => 'Xotira va zaxira';

  @override
  String get groupAccessibility => 'Maxsus imkoniyatlar';

  @override
  String get groupPrivacy => 'Maxfiylik';

  @override
  String get appearanceSubtitle => 'Mavzu, ranglar, shriftlar, joylashuv';

  @override
  String get librarySubtitle =>
      'Demo treklar, yashirilgan qoʻshiqlar, skanerlash';

  @override
  String get languageSubtitle => 'Oʻzbekcha, Русский, English';

  @override
  String get accessibilitySubtitle => 'Kontrast, matn oʻlchami, animatsiya';

  @override
  String get privacySubtitle => 'Oflayn, kuzatuvsiz';

  @override
  String get playbackSubtitle =>
      'Krossfeyd, tezlik, xatti-harakat, uyqu taymeri';

  @override
  String get aboutSubtitle => 'Versiya, muallif, litsenziyalar';

  @override
  String get sectionTheme => 'Mavzu';

  @override
  String get themeMode => 'Mavzu';

  @override
  String get themeSystem => 'Tizim boʻyicha';

  @override
  String get themeLight => 'Yorugʻ';

  @override
  String get themeDark => 'Qorongʻi';

  @override
  String get themeAmoled => 'AMOLED qora';

  @override
  String get themeSchedule => 'Jadval boʻyicha qorongʻi mavzu';

  @override
  String get themeScheduleHint => 'Kunduzi yorugʻ, kechasi qorongʻi';

  @override
  String get darkFrom => 'Qorongʻi boshlanishi';

  @override
  String get darkUntil => 'Qorongʻi tugashi';

  @override
  String get sectionColor => 'Asosiy rang';

  @override
  String get accentSource => 'Rang manbasi';

  @override
  String get accentPreset => 'Palitra';

  @override
  String get accentCustom => 'Oʻz rangim';

  @override
  String get accentMaterialYou => 'Material You (gulqogʻoz)';

  @override
  String get accentAdaptive => 'Albom muqovasidan';

  @override
  String get materialYouUnavailable =>
      'Android 12 yoki yangisi kerak; palitradagi rang ishlatilmoqda.';

  @override
  String get hue => 'Tus';

  @override
  String get saturation => 'Toʻyinganlik';

  @override
  String get lightness => 'Yorqinlik';

  @override
  String get sectionText => 'Matn';

  @override
  String get font => 'Shrift';

  @override
  String get textSize => 'Matn oʻlchami';

  @override
  String get boldText => 'Qalin matn';

  @override
  String get sectionLayout => 'Joylashuv';

  @override
  String get corners => 'Burchaklar';

  @override
  String get cornersSharp => 'Oʻtkir';

  @override
  String get cornersMedium => 'Oʻrtacha';

  @override
  String get cornersRound => 'Yumaloq';

  @override
  String get density => 'Roʻyxat zichligi';

  @override
  String get densityCompact => 'Ixcham';

  @override
  String get densityComfortable => 'Qulay';

  @override
  String get densitySpacious => 'Keng';

  @override
  String get artShape => 'Muqova shakli';

  @override
  String get shapeRounded => 'Yumaloqlangan';

  @override
  String get shapeCircle => 'Doira';

  @override
  String get artSize => 'Muqova oʻlchami';

  @override
  String get sizeSmall => 'Kichik';

  @override
  String get sizeMedium => 'Oʻrtacha';

  @override
  String get sizeLarge => 'Katta';

  @override
  String get showListArtwork => 'Roʻyxatlarda muqovani koʻrsatish';

  @override
  String get sectionPlayerLook => 'Pleyer ekrani';

  @override
  String get playerStyle => 'Pleyer uslubi';

  @override
  String get styleClassic => 'Klassik';

  @override
  String get styleMinimal => 'Minimal';

  @override
  String get styleBlurred => 'Xiralashgan muqova';

  @override
  String get blurStrength => 'Xiralik darajasi';

  @override
  String get animatedBackground => 'Animatsiyali fon';

  @override
  String get sectionNavigation => 'Navigatsiya';

  @override
  String get showNavLabels => 'Tab nomlarini koʻrsatish';

  @override
  String get navTabs => 'Pastki tablar';

  @override
  String get navTabsHint =>
      'Tartib uchun suring, yashirish uchun belgini oling';

  @override
  String get startTab => 'Boshlangʻich tab';

  @override
  String get homeTabs => 'Asosiy sahifa tablari';

  @override
  String get startHomeTab => 'Standart asosiy tab';

  @override
  String get miniPlayerStyle => 'Mini pleyer';

  @override
  String get miniFloating => 'Suzuvchi';

  @override
  String get miniDocked => 'Biriktirilgan';

  @override
  String get sectionMotion => 'Harakat';

  @override
  String get animations => 'Animatsiyalar';

  @override
  String get animFull => 'Toʻliq';

  @override
  String get animReduced => 'Kamaytirilgan';

  @override
  String get animOff => 'Oʻchiq';

  @override
  String get systemReduceMotion =>
      'Tizimda “Animatsiyani oʻchirish” yoqilgan, shuning uchun animatsiya kamaytirilgan holda qoladi.';

  @override
  String get preview => 'Oldindan koʻrish';

  @override
  String get highContrast => 'Yuqori kontrast';

  @override
  String get highContrastHint => 'Aniqroq matn va chegaralar';

  @override
  String get privacyStatement =>
      'Navo toʻliq oflayn ishlaydi. Reklama, analitika va kuzatuv yoʻq. Musiqangiz, pleylistlaringiz va tinglash tarixingiz faqat shu qurilmada saqlanadi va hech qayerga yuborilmaydi.';

  @override
  String get saveSearchHistory => 'Soʻnggi qidiruvlarni eslab qolish';

  @override
  String percentValue(int value) {
    return '$value%';
  }

  @override
  String get aboutNavo => 'Navo haqida';

  @override
  String get playerSubtitle => 'Uslub, fon, oʻtkazish chizigʻi';

  @override
  String get audioSubtitle => 'Ekvalayzer, bas kuchaytirish, balandlik';

  @override
  String get showRemainingTime => 'Qolgan vaqtni koʻrsatish';

  @override
  String get sectionTransitions => 'Oʻtishlar';

  @override
  String get crossfade => 'Krossfeyd';

  @override
  String get crossfadeHint => 'Qoʻshiq oxiri pasayib, keyingisi asta kuchayadi';

  @override
  String secondsShort(int n) {
    return '$n s';
  }

  @override
  String get off => 'Oʻchiq';

  @override
  String get fadeOnPlayPause => 'Ijro va pauzada silliq oʻtish';

  @override
  String get skipSilence => 'Jimlikni oʻtkazib yuborish';

  @override
  String get normalizeVolume => 'Ovoz normallashtirish (ReplayGain)';

  @override
  String get normalizeHint =>
      'Faylda ReplayGain teglari boʻlsa, ulardan foydalanadi';

  @override
  String get pitch => 'Ohang balandligi';

  @override
  String get resetValue => 'Tiklash';

  @override
  String get sectionBehavior => 'Xatti-harakat';

  @override
  String get resumeAfterCall => 'Qoʻngʻiroqdan keyin davom ettirish';

  @override
  String get pauseOnDisconnect => 'Quloqchin uzilganda pauza';

  @override
  String get resumeOnHeadset => 'Quloqchin ulanganda davom ettirish';

  @override
  String get rememberQueue => 'Navbat va joyni eslab qolish';

  @override
  String get autoPlayOnStart => 'Ochilganda avtomatik ijro';

  @override
  String get addMode => 'Standart “navbatga qoʻshish”';

  @override
  String get addToEnd => 'Navbat oxiriga';

  @override
  String get shuffleStyle => 'Aralash ijro';

  @override
  String get shuffleRandom => 'Toʻliq tasodifiy';

  @override
  String get shuffleAvoidRecent => 'Yaqinda tinglanganlarsiz';

  @override
  String get sectionSleep => 'Uyqu taymeri';

  @override
  String get sleepFadeOut => 'Toʻxtashdan oldin asta pasaytirish';

  @override
  String get shakeToExtend => '10 daqiqa qoʻshish uchun silkiting';

  @override
  String get sleepExtended => 'Uyqu taymeri 10 daqiqaga uzaytirildi';

  @override
  String get equalizer => 'Ekvalayzer';

  @override
  String get eqEnabled => 'Ekvalayzerni yoqish';

  @override
  String get presets => 'Presetlar';

  @override
  String get eqNormal => 'Oddiy';

  @override
  String get eqBass => 'Bas';

  @override
  String get eqTreble => 'Yuqori';

  @override
  String get eqRock => 'Rok';

  @override
  String get eqPop => 'Pop';

  @override
  String get eqJazz => 'Jaz';

  @override
  String get eqClassical => 'Klassik';

  @override
  String get eqVocal => 'Vokal';

  @override
  String get eqCustom => 'Oʻzim';

  @override
  String get savePreset => 'Preset sifatida saqlash';

  @override
  String get presetName => 'Preset nomi';

  @override
  String get deletePreset => 'Presetni oʻchirish';

  @override
  String get bassBoost => 'Bas kuchaytirish';

  @override
  String get loudnessBoost => 'Balandlikni kuchaytirish';

  @override
  String get eqUnavailable => 'Bu qurilmada ekvalayzer mavjud emas.';

  @override
  String get eqStartPlayback => 'Diapazonlarni sozlash uchun qoʻshiq qoʻying.';

  @override
  String hz(String value) {
    return '$value Gs';
  }

  @override
  String khz(String value) {
    return '$value kGs';
  }

  @override
  String db(String value) {
    return '$value dB';
  }

  @override
  String get abRepeat => 'A–B takrorlash';

  @override
  String get abSetA => 'A nuqtasini belgilash';

  @override
  String get abSetB => 'B nuqtasini belgilash';

  @override
  String get abClear => 'A–B takrorlashni oʻchirish';

  @override
  String queueRemoved(String title) {
    return '“$title” olib tashlandi';
  }

  @override
  String get clearQueue => 'Keyingilarni tozalash';

  @override
  String get queueCleared => 'Keyingi qoʻshiqlar tozalandi';

  @override
  String get saveQueueAsPlaylist => 'Pleylist sifatida saqlash';

  @override
  String get editTags => 'Teglarni tahrirlash';

  @override
  String get changeArtwork => 'Muqovani almashtirish';

  @override
  String get removeArtwork => 'Muqovani olib tashlash';

  @override
  String get tagsSaved => 'Teglar saqlandi';

  @override
  String get tagsNotSupported => 'Bu faylni tahrirlab boʻlmaydi';

  @override
  String get tagsFailed => 'Teglarni saqlab boʻlmadi';

  @override
  String get yearInvalid => 'Toʻgʻri yil kiriting';

  @override
  String get smartPlaylists => 'Aqlli pleylistlar';

  @override
  String get myPlaylists => 'Mening pleylistlarim';

  @override
  String get recentlyAdded => 'Yaqinda qoʻshilgan';

  @override
  String get neverPlayed => 'Hech tinglanmagan';

  @override
  String get importM3u => 'M3U pleylistni import qilish';

  @override
  String get exportM3u => 'M3U sifatida eksport';

  @override
  String m3uImported(String name, String songs) {
    return '“$name” import qilindi: $songs';
  }

  @override
  String get m3uNoMatches =>
      'Pleylistdagi qoʻshiqlarning hech biri qurilmada topilmadi';

  @override
  String get m3uExported => 'Pleylist eksport qilindi';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta tanlandi',
    );
    return '$_temp0';
  }

  @override
  String get selectAll => 'Hammasini tanlash';

  @override
  String get cancelSelection => 'Tanlovni bekor qilish';

  @override
  String deleteSongsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta qoʻshiq qurilmadan oʻchirilsinmi?',
    );
    return '$_temp0';
  }

  @override
  String get deleteSongsMessage =>
      'Tanlangan fayllar qurilmangizdan butunlay oʻchiriladi.';

  @override
  String songsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta qoʻshiq oʻchirildi',
    );
    return '$_temp0';
  }

  @override
  String get addedToFavoritesMany => 'Sevimlilarga qoʻshildi';

  @override
  String get queueAction => 'Navbatga';

  @override
  String get sectionFolders => 'Jildlar';

  @override
  String get libraryFolders => 'Kutubxona jildlari';

  @override
  String get libraryFoldersHint =>
      'Kutubxonada qaysi jildlar koʻrinishini tanlang';

  @override
  String get folderShown => 'Koʻrsatish';

  @override
  String get folderHidden => 'Yashirish';

  @override
  String get folderOnly => 'Faqat shular';

  @override
  String get folderOnlyActive =>
      'Faqat “Faqat shular” deb belgilangan jildlar koʻrsatiladi';

  @override
  String get resetFolders => 'Barcha jildlarni koʻrsatish';

  @override
  String foldersSummary(int hidden) {
    return '$hidden ta yashirilgan';
  }

  @override
  String get allFoldersShown => 'Barcha jildlar koʻrsatilmoqda';

  @override
  String get sectionFilters => 'Filtrlar';

  @override
  String get minDuration => 'Qoʻshiqning minimal uzunligi';

  @override
  String get minSize => 'Faylning minimal hajmi';

  @override
  String kbValue(int n) {
    return '$n KB';
  }

  @override
  String get hideShortSounds =>
      'Qoʻngʻiroq va bildirishnoma tovushlarini yashirish';

  @override
  String get sectionScanning => 'Skanerlash';

  @override
  String get scanOnLaunch => 'Ochilganda yangi musiqani qidirish';

  @override
  String get scanning => 'Musiqa skanerlanmoqda…';

  @override
  String scanFound(String songs) {
    return 'Kutubxona yangilandi: $songs';
  }

  @override
  String get sectionGrouping => 'Guruhlash';

  @override
  String get splitArtists => 'Bir nechta ijrochini ajratish';

  @override
  String get splitArtistsHint =>
      '“A feat. B”, “A & B” va “A; B”ni alohida ijrochilar deb hisoblash';

  @override
  String get groupByAlbumArtist => 'Albom ijrochisi boʻyicha guruhlash';

  @override
  String get lyricsSubtitle => 'Oʻlcham, tekislash, vaqt';

  @override
  String get notificationsSubtitle =>
      'Bildirishnoma tugmalari, quloqchin tugmasi';

  @override
  String get lyricsFontSize => 'Matn oʻlchami';

  @override
  String get lyricsAlign => 'Tekislash';

  @override
  String get alignStart => 'Chapga';

  @override
  String get alignCenter => 'Markazga';

  @override
  String get lyricsOffset => 'Vaqt siljishi';

  @override
  String get lyricsOffsetHint => 'Matn oldinda yoki orqada qolsa foydalaning';

  @override
  String offsetSeconds(String value) {
    return '$value s';
  }

  @override
  String get keepScreenOn => 'Matn ochiq paytda ekranni oʻchirmaslik';

  @override
  String get autoScrollLyrics => 'Joriy qatorga ergashish';

  @override
  String get lyricsSmaller => 'Kichikroq';

  @override
  String get lyricsLarger => 'Kattaroq';

  @override
  String get lyricsEarlier => 'Oldinroq koʻrsatish';

  @override
  String get lyricsLater => 'Kechroq koʻrsatish';

  @override
  String get sectionNotification => 'Media bildirishnoma';

  @override
  String get notifArtwork => 'Albom muqovasini koʻrsatish';

  @override
  String get notifCloseButton => 'Yopish tugmasi';

  @override
  String get notifFavoriteButton => 'Sevimlilar tugmasi';

  @override
  String get notifCompactSkip => 'Ixcham koʻrinishda oldingi va keyingi';

  @override
  String get notificationPermission => 'Bildirishnoma ruxsati';

  @override
  String get notificationPermissionHint =>
      'Android 13+ da paneldan boshqarish uchun kerak';

  @override
  String get sectionHeadset => 'Quloqchin tugmasi';

  @override
  String get pressSingle => 'Bir marta bosish';

  @override
  String get pressDouble => 'Ikki marta bosish';

  @override
  String get pressTriple => 'Uch marta bosish';

  @override
  String get actionPlayPause => 'Ijro / pauza';

  @override
  String get actionNext => 'Keyingi qoʻshiq';

  @override
  String get actionPrevious => 'Oldingi qoʻshiq';

  @override
  String get actionNone => 'Hech narsa';

  @override
  String get sectionWidget => 'Bosh ekran vidjeti';

  @override
  String get widgetHint =>
      'Bosh ekranni uzoq bosing, “Vidjetlar”ni tanlang va Navo’ni qoʻshing.';

  @override
  String get widgetNothingPlaying => 'Hech narsa ijro etilmayapti';

  @override
  String get gesturesSubtitle => 'Mini pleyerni surish, tebranish';

  @override
  String get gestureMiniSwipe => 'Mini pleyerni surib keyingi / oldingi';

  @override
  String get gestureDoubleTap => 'Muqovani ikki marta bosib ijro / pauza';

  @override
  String get gestureSwipeArtwork => 'Muqovani surib qoʻshiqni almashtirish';

  @override
  String get gestureShake => 'Silkitib keyingisiga oʻtish';

  @override
  String get gestureShakeSensitivity => 'Silkitish sezgirligi';

  @override
  String get gestureVolumeSeek => 'Pleyerda ovoz tugmalari bilan oʻtkazish';

  @override
  String get gestureVolumeSeekHint =>
      'Pleyer ochiq paytda: yuqori = +10 s, past = −10 s';

  @override
  String get haptics => 'Tebranish javobi';

  @override
  String get stats => 'Tinglash statistikasi';

  @override
  String get statsSubtitle => 'Faqat shu qurilmada saqlanadi';

  @override
  String get statsTotal => 'Jami tinglangan vaqt';

  @override
  String get statsThisWeek => 'Shu hafta';

  @override
  String get statsLast7Days => 'Soʻnggi 7 kun';

  @override
  String get statsTopSongs => 'Eng koʻp tinglangan qoʻshiqlar';

  @override
  String get statsTopArtists => 'Eng koʻp tinglangan ijrochilar';

  @override
  String get statsTopAlbums => 'Eng koʻp tinglangan albomlar';

  @override
  String get statsEmpty => 'Hali tinglash maʼlumotlari yoʻq';

  @override
  String get statsEmptyHint =>
      'Musiqa tinglang va statistikani koʻrish uchun qaytib keling.';

  @override
  String get statsDisabled => 'Statistika maxfiylik sozlamalarida oʻchirilgan.';

  @override
  String get collectStats => 'Tinglash statistikasini yigʻish';

  @override
  String get clearStats => 'Statistikani tozalash';

  @override
  String get clearStatsTitle => 'Statistika tozalansinmi?';

  @override
  String get clearStatsMessage =>
      'Tinglash vaqti, reytinglar va hisoblagichlar nolga tushadi.';

  @override
  String get statsCleared => 'Statistika tozalandi';

  @override
  String hoursMinutes(int h, int m) {
    return '$h soat $m daq';
  }

  @override
  String minutesOnly(int m) {
    return '$m daq';
  }

  @override
  String dayMinutes(String day, String minutes) {
    return '$day: $minutes';
  }

  @override
  String get filterAll => 'Hammasi';

  @override
  String get quickActions => 'Tezkor amallar';

  @override
  String get advancedSettings => 'Kengaytirilgan';

  @override
  String advancedSettingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yana $count ta sozlama',
    );
    return '$_temp0';
  }

  @override
  String get storageSubtitle =>
      'Sozlamalar, sevimlilar va pleylistlarni zaxiralash';

  @override
  String get backupExport => 'Zaxira nusxa yaratish';

  @override
  String get backupExportHint =>
      'Sozlamalar, sevimlilar, pleylistlar va yashirilgan qoʻshiqlar faylga saqlanadi';

  @override
  String get backupImport => 'Zaxiradan tiklash';

  @override
  String get backupImportHint =>
      'Joriy sozlamalar, sevimlilar va pleylistlar almashtiriladi';

  @override
  String get backupSaved => 'Zaxira nusxa saqlandi';

  @override
  String get backupRestored => 'Zaxiradan tiklandi';

  @override
  String get backupInvalid => 'Bu fayl Navo zaxira nusxasi emas';

  @override
  String get restoreBackupTitle => 'Zaxiradan tiklansinmi?';

  @override
  String get restoreBackupMessage =>
      'Joriy sozlamalar, sevimlilar va pleylistlar almashtiriladi.';
}
