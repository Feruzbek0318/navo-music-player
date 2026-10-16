// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Navo';

  @override
  String get appTagline => 'Ваша музыка — без интернета';

  @override
  String get onboardingTitle1 =>
      'Удобный плеер для всей музыки на вашем устройстве';

  @override
  String get onboardingTitle2 =>
      'Чистый и насыщенный звук при каждом прослушивании';

  @override
  String get onboardingTitle3 => 'Слушайте любимую музыку вместе с Navo';

  @override
  String get next => 'Далее';

  @override
  String get getStarted => 'Начать';

  @override
  String get skip => 'Пропустить';

  @override
  String get tabSuggested => 'Рекомендации';

  @override
  String get tabSongs => 'Песни';

  @override
  String get tabArtists => 'Исполнители';

  @override
  String get tabAlbums => 'Альбомы';

  @override
  String get tabFolders => 'Папки';

  @override
  String get navHome => 'Главная';

  @override
  String get navFavorites => 'Избранное';

  @override
  String get navPlaylists => 'Плейлисты';

  @override
  String get navSettings => 'Настройки';

  @override
  String get recentlyPlayed => 'Недавно прослушанные';

  @override
  String get mostPlayed => 'Часто слушаемые';

  @override
  String get seeAll => 'Все';

  @override
  String get songs => 'Песни';

  @override
  String get search => 'Поиск';

  @override
  String songsCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString песни',
      many: '$countString песен',
      few: '$countString песни',
      one: '$countString песня',
      zero: 'Нет песен',
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
      other: '$countString альбома',
      many: '$countString альбомов',
      few: '$countString альбома',
      one: '$countString альбом',
      zero: 'Нет альбомов',
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
      other: '$countString исполнителя',
      many: '$countString исполнителей',
      few: '$countString исполнителя',
      one: '$countString исполнитель',
      zero: 'Нет исполнителей',
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
      other: '$countString папки',
      many: '$countString папок',
      few: '$countString папки',
      one: '$countString папка',
      zero: 'Нет папок',
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
      other: '$countString плейлиста',
      many: '$countString плейлистов',
      few: '$countString плейлиста',
      one: '$countString плейлист',
      zero: 'Нет плейлистов',
    );
    return '$_temp0';
  }

  @override
  String durationMins(String time) {
    return '$time мин';
  }

  @override
  String minutesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count минуты',
      many: '$count минут',
      few: '$count минуты',
      one: '$count минута',
    );
    return '$_temp0';
  }

  @override
  String get sortBy => 'Сортировка';

  @override
  String get sortAscending => 'По возрастанию';

  @override
  String get sortDescending => 'По убыванию';

  @override
  String get sortArtist => 'Исполнитель';

  @override
  String get sortAlbum => 'Альбом';

  @override
  String get sortYear => 'Год';

  @override
  String get sortDateAdded => 'Дата добавления';

  @override
  String get sortDateModified => 'Дата изменения';

  @override
  String get sortComposer => 'Композитор';

  @override
  String get sortSongCount => 'Количество песен';

  @override
  String get sortAlbumCount => 'Количество альбомов';

  @override
  String get play => 'Слушать';

  @override
  String get shuffle => 'Перемешать';

  @override
  String get playNext => 'Воспроизвести следующей';

  @override
  String get addToQueue => 'Добавить в очередь воспроизведения';

  @override
  String get addToPlaylist => 'Добавить в плейлист';

  @override
  String get goToAlbum => 'Перейти к альбому';

  @override
  String get goToArtist => 'Перейти к исполнителю';

  @override
  String get details => 'Сведения';

  @override
  String get setAsRingtone => 'Установить как рингтон';

  @override
  String get addToBlocklist => 'Добавить в чёрный список';

  @override
  String get share => 'Поделиться';

  @override
  String get deleteFromDevice => 'Удалить с устройства';

  @override
  String get addToFavorites => 'Добавить в избранное';

  @override
  String get removeFromFavorites => 'Удалить из избранного';

  @override
  String get removeFromPlaylist => 'Удалить из плейлиста';

  @override
  String get removeFromQueue => 'Удалить из очереди';

  @override
  String get more => 'Ещё';

  @override
  String get songDetails => 'Сведения о песне';

  @override
  String get detailTitle => 'Название';

  @override
  String get detailArtist => 'Исполнитель';

  @override
  String get detailAlbum => 'Альбом';

  @override
  String get detailComposer => 'Композитор';

  @override
  String get detailGenre => 'Жанр';

  @override
  String get detailYear => 'Год';

  @override
  String get detailDuration => 'Длительность';

  @override
  String get detailFormat => 'Формат';

  @override
  String get detailSize => 'Размер';

  @override
  String get detailPath => 'Расположение';

  @override
  String get detailDateAdded => 'Дата добавления';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get unknownArtist => 'Неизвестный исполнитель';

  @override
  String get unknownAlbum => 'Неизвестный альбом';

  @override
  String get demoTrack => 'Демо';

  @override
  String get close => 'Закрыть';

  @override
  String get lyrics => 'Текст песни';

  @override
  String get noLyrics => 'Текст не найден';

  @override
  String get noLyricsHint =>
      'Положите рядом с песней файл .lrc с таким же именем или добавьте текст в теги файла.';

  @override
  String get playingQueue => 'Очередь воспроизведения';

  @override
  String get queueEmpty => 'Очередь пуста';

  @override
  String get nowPlaying => 'Сейчас играет';

  @override
  String get playbackSpeed => 'Скорость воспроизведения';

  @override
  String get sleepTimer => 'Таймер сна';

  @override
  String get sleepTimerEndOfTrack => 'В конце текущей песни';

  @override
  String get sleepTimerOff => 'Выключить таймер';

  @override
  String sleepTimerRemaining(String time) {
    return 'Остановка через $time';
  }

  @override
  String sleepTimerSet(String minutes) {
    return 'Воспроизведение остановится через $minutes';
  }

  @override
  String get sleepTimerEndSet => 'Воспроизведение остановится после этой песни';

  @override
  String get audioOutput => 'Аудиовыход';

  @override
  String get audioOutputUnavailable =>
      'Не удалось открыть выбор устройства вывода';

  @override
  String get volume => 'Громкость';

  @override
  String get repeatOff => 'Повтор выключен';

  @override
  String get repeatAll => 'Повторять все';

  @override
  String get repeatOne => 'Повторять одну';

  @override
  String get shuffleOn => 'Перемешивание включено';

  @override
  String get shuffleOff => 'Перемешивание выключено';

  @override
  String get previous => 'Предыдущая';

  @override
  String get pause => 'Пауза';

  @override
  String get rewind10 => 'Назад на 10 секунд';

  @override
  String get forward10 => 'Вперёд на 10 секунд';

  @override
  String get back => 'Назад';

  @override
  String get favorites => 'Избранное';

  @override
  String get noFavorites => 'В избранном пока пусто';

  @override
  String get noFavoritesHint =>
      'Нажмите на сердечко у любой песни, чтобы сохранить её здесь.';

  @override
  String get addedToFavorites => 'Добавлено в избранное';

  @override
  String get removedFromFavorites => 'Удалено из избранного';

  @override
  String get playlists => 'Плейлисты';

  @override
  String get newPlaylist => 'Новый плейлист';

  @override
  String get playlistName => 'Название плейлиста';

  @override
  String get create => 'Создать';

  @override
  String get rename => 'Переименовать';

  @override
  String get renamePlaylist => 'Переименовать плейлист';

  @override
  String get delete => 'Удалить';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get deletePlaylistTitle => 'Удалить плейлист?';

  @override
  String deletePlaylistMessage(String name) {
    return 'Плейлист «$name» будет удалён. Песни останутся на устройстве.';
  }

  @override
  String get noPlaylists => 'Плейлистов пока нет';

  @override
  String get noPlaylistsHint =>
      'Создайте плейлист, чтобы собрать любимые песни вместе.';

  @override
  String get emptyPlaylist => 'Плейлист пуст';

  @override
  String get emptyPlaylistHint =>
      'Добавляйте песни через меню песни: ⋮ → Добавить в плейлист.';

  @override
  String addedToPlaylist(String name) {
    return 'Добавлено в «$name»';
  }

  @override
  String alreadyInPlaylist(String name) {
    return 'Уже есть в «$name»';
  }

  @override
  String get playlistNameEmpty => 'Введите название';

  @override
  String get searchHint => 'Поиск песен, исполнителей, альбомов';

  @override
  String get recentSearches => 'Недавние запросы';

  @override
  String get clearAll => 'Очистить всё';

  @override
  String noResults(String query) {
    return 'По запросу «$query» ничего не найдено';
  }

  @override
  String get searchEmptyHint =>
      'Найдите любую песню, исполнителя или альбом на устройстве.';

  @override
  String get nothingPlayedYet => 'Вы ещё ничего не слушали';

  @override
  String get nothingPlayedHint => 'Здесь появятся песни, которые вы слушаете.';

  @override
  String get noArtists => 'Исполнители не найдены';

  @override
  String get noAlbums => 'Альбомы не найдены';

  @override
  String get noFolders => 'Папки не найдены';

  @override
  String get permissionTitle => 'Разрешите доступ к музыке';

  @override
  String get permissionMessage =>
      'Navo нужно разрешение, чтобы найти аудиофайлы на устройстве. Демо-треки работают и без него.';

  @override
  String get permissionDeniedMessage =>
      'Доступ запрещён. Его можно включить в системных настройках.';

  @override
  String get allowAccess => 'Разрешить доступ';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get noSongsTitle => 'Песни не найдены';

  @override
  String get noSongsMessage =>
      'Скопируйте музыку на устройство или послушайте демо-треки.';

  @override
  String get errorTitle => 'Что-то пошло не так';

  @override
  String get retry => 'Повторить';

  @override
  String get addedToQueue => 'Добавлено в очередь воспроизведения';

  @override
  String get willPlayNext => 'Будет воспроизведена следующей';

  @override
  String get addedToBlocklist => 'Скрыто из медиатеки';

  @override
  String get undo => 'Отменить';

  @override
  String get ringtoneSet => 'Рингтон установлен';

  @override
  String get ringtoneNeedsPermission =>
      'Разрешите Navo изменять системные настройки и попробуйте снова.';

  @override
  String get actionFailed => 'Не удалось выполнить действие';

  @override
  String get songDeleted => 'Песня удалена';

  @override
  String get deleteSongTitle => 'Удалить с устройства?';

  @override
  String deleteSongMessage(String title) {
    return 'Песня «$title» будет навсегда удалена с устройства.';
  }

  @override
  String get notAvailableForDemo => 'Недоступно для демо-треков';

  @override
  String get settings => 'Настройки';

  @override
  String get sectionGeneral => 'Общие';

  @override
  String get sectionPlayback => 'Воспроизведение';

  @override
  String get sectionLibrary => 'Медиатека';

  @override
  String get sectionAbout => 'О приложении';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Как в системе';

  @override
  String get artworkStyle => 'Обложка в плеере';

  @override
  String get artworkVinyl => 'Пластинка (вращается)';

  @override
  String get artworkSquare => 'Квадрат';

  @override
  String get showDemoTracks => 'Показывать демо-треки';

  @override
  String get blockedSongs => 'Скрытые песни';

  @override
  String get blockedSongsEmpty => 'Скрытых песен нет';

  @override
  String get unblock => 'Вернуть';

  @override
  String get rescanLibrary => 'Обновить медиатеку';

  @override
  String get libraryRescanned => 'Медиатека обновлена';

  @override
  String get showOnboarding => 'Показать знакомство снова';

  @override
  String get about => 'О приложении';

  @override
  String versionLabel(String version) {
    return 'Версия $version';
  }

  @override
  String get designedBy => 'Дизайн и разработка: Feruzbek Namozboyev';

  @override
  String get aboutBio => 'Flutter-разработчик';

  @override
  String get contactTelegram => 'Telegram';

  @override
  String get madeWithFlutter => 'Сделано на Flutter';

  @override
  String copyright(int year) {
    return '© $year Feruzbek Namozboyev';
  }

  @override
  String get linkOpenFailed => 'Не удалось открыть ссылку';

  @override
  String get openSourceLicenses => 'Лицензии открытого ПО';

  @override
  String cannotPlayFile(String title) {
    return 'Не удалось воспроизвести «$title». Переходим к следующей песне.';
  }

  @override
  String get cannotPlayUnknown => 'Этот файл невозможно воспроизвести.';

  @override
  String get notificationChannelName => 'Воспроизведение';

  @override
  String get notificationsDeniedMessage =>
      'Разрешите уведомления, чтобы управлять музыкой из шторки и на экране блокировки.';

  @override
  String get backgroundPlayback => 'Фоновое воспроизведение';

  @override
  String get backgroundPlaybackHint =>
      'Если музыка останавливается при выключенном экране, снимите для Navo ограничения расхода батареи.';

  @override
  String get batterySettings => 'Настройки батареи';

  @override
  String get later => 'Позже';

  @override
  String get contactYouTube => 'YouTube';

  @override
  String get youtubeChannel => 'Канал Feruzbek Namozboyev';

  @override
  String get settingsSearchHint => 'Поиск настроек';

  @override
  String get resetAll => 'Сбросить все настройки';

  @override
  String get resetAllTitle => 'Сбросить все настройки?';

  @override
  String get resetAllMessage =>
      'Все настройки вернутся к значениям по умолчанию. Музыка, плейлисты и избранное сохранятся.';

  @override
  String get resetGroup => 'Сбросить по умолчанию';

  @override
  String resetGroupTitle(String group) {
    return 'Сбросить «$group»?';
  }

  @override
  String get resetGroupMessage =>
      'Настройки этого раздела вернутся к значениям по умолчанию.';

  @override
  String get reset => 'Сбросить';

  @override
  String get settingsRestored => 'Настройки сброшены';

  @override
  String noSettingsFound(String query) {
    return 'Нет настроек по запросу «$query»';
  }

  @override
  String get groupAppearance => 'Внешний вид';

  @override
  String get groupPlayer => 'Плеер';

  @override
  String get groupPlayback => 'Воспроизведение';

  @override
  String get groupAudio => 'Звук и эквалайзер';

  @override
  String get groupLibrary => 'Медиатека';

  @override
  String get groupLyrics => 'Текст песен';

  @override
  String get groupNotifications => 'Уведомления';

  @override
  String get groupGestures => 'Жесты';

  @override
  String get groupStorage => 'Хранилище и резервная копия';

  @override
  String get groupAccessibility => 'Специальные возможности';

  @override
  String get groupPrivacy => 'Конфиденциальность';

  @override
  String get appearanceSubtitle => 'Тема, цвета, шрифты, макет';

  @override
  String get librarySubtitle => 'Демо-треки, скрытые песни, сканирование';

  @override
  String get languageSubtitle => 'Oʻzbekcha, Русский, English';

  @override
  String get accessibilitySubtitle => 'Контраст, размер текста, анимация';

  @override
  String get privacySubtitle => 'Офлайн, без слежки';

  @override
  String get playbackSubtitle => 'Кроссфейд, скорость, поведение, таймер сна';

  @override
  String get aboutSubtitle => 'Версия, автор, лицензии';

  @override
  String get sectionTheme => 'Тема';

  @override
  String get themeMode => 'Тема';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeAmoled => 'AMOLED чёрная';

  @override
  String get themeSchedule => 'Тёмная тема по расписанию';

  @override
  String get themeScheduleHint => 'Днём светлая, ночью тёмная';

  @override
  String get darkFrom => 'Тёмная с';

  @override
  String get darkUntil => 'Тёмная до';

  @override
  String get sectionColor => 'Акцентный цвет';

  @override
  String get accentSource => 'Источник цвета';

  @override
  String get accentPreset => 'Палитра';

  @override
  String get accentCustom => 'Свой цвет';

  @override
  String get accentMaterialYou => 'Material You (обои)';

  @override
  String get accentAdaptive => 'Из обложки альбома';

  @override
  String get materialYouUnavailable =>
      'Нужен Android 12 или новее; используется цвет из палитры.';

  @override
  String get hue => 'Оттенок';

  @override
  String get saturation => 'Насыщенность';

  @override
  String get lightness => 'Яркость';

  @override
  String get sectionText => 'Текст';

  @override
  String get font => 'Шрифт';

  @override
  String get textSize => 'Размер текста';

  @override
  String get boldText => 'Жирный текст';

  @override
  String get sectionLayout => 'Макет';

  @override
  String get corners => 'Углы';

  @override
  String get cornersSharp => 'Острые';

  @override
  String get cornersMedium => 'Средние';

  @override
  String get cornersRound => 'Круглые';

  @override
  String get density => 'Плотность списков';

  @override
  String get densityCompact => 'Компактно';

  @override
  String get densityComfortable => 'Комфортно';

  @override
  String get densitySpacious => 'Просторно';

  @override
  String get artShape => 'Форма обложки';

  @override
  String get shapeRounded => 'Скруглённая';

  @override
  String get shapeCircle => 'Круг';

  @override
  String get artSize => 'Размер обложки';

  @override
  String get sizeSmall => 'Маленький';

  @override
  String get sizeMedium => 'Средний';

  @override
  String get sizeLarge => 'Большой';

  @override
  String get showListArtwork => 'Обложки в списках';

  @override
  String get sectionPlayerLook => 'Экран плеера';

  @override
  String get playerStyle => 'Стиль плеера';

  @override
  String get styleClassic => 'Классический';

  @override
  String get styleMinimal => 'Минимализм';

  @override
  String get styleBlurred => 'Размытая обложка';

  @override
  String get blurStrength => 'Сила размытия';

  @override
  String get animatedBackground => 'Анимированный фон';

  @override
  String get sectionNavigation => 'Навигация';

  @override
  String get showNavLabels => 'Подписи вкладок';

  @override
  String get navTabs => 'Нижние вкладки';

  @override
  String get navTabsHint =>
      'Перетащите для порядка, снимите флажок, чтобы скрыть';

  @override
  String get startTab => 'Стартовая вкладка';

  @override
  String get homeTabs => 'Вкладки главной';

  @override
  String get startHomeTab => 'Вкладка главной по умолчанию';

  @override
  String get miniPlayerStyle => 'Мини-плеер';

  @override
  String get miniFloating => 'Плавающий';

  @override
  String get miniDocked => 'Закреплённый';

  @override
  String get sectionMotion => 'Анимация';

  @override
  String get animations => 'Анимации';

  @override
  String get animFull => 'Полные';

  @override
  String get animReduced => 'Уменьшенные';

  @override
  String get animOff => 'Выключены';

  @override
  String get systemReduceMotion =>
      'В системе включено «Отключить анимацию», поэтому анимация остаётся уменьшенной.';

  @override
  String get preview => 'Предпросмотр';

  @override
  String get highContrast => 'Высокий контраст';

  @override
  String get highContrastHint => 'Более чёткий текст и контуры';

  @override
  String get privacyStatement =>
      'Navo работает полностью офлайн. Никакой рекламы, аналитики и слежки. Ваша музыка, плейлисты и история прослушивания хранятся только на этом устройстве и никуда не отправляются.';

  @override
  String get saveSearchHistory => 'Запоминать недавние запросы';

  @override
  String percentValue(int value) {
    return '$value%';
  }

  @override
  String get aboutNavo => 'О Navo';

  @override
  String get playerSubtitle => 'Стиль, фон, полоса прокрутки';

  @override
  String get audioSubtitle => 'Эквалайзер, усиление басов, громкость';

  @override
  String get showRemainingTime => 'Показывать оставшееся время';

  @override
  String get sectionTransitions => 'Переходы';

  @override
  String get crossfade => 'Кроссфейд';

  @override
  String get crossfadeHint =>
      'Плавно затухает конец песни и нарастает следующая';

  @override
  String secondsShort(int n) {
    return '$n с';
  }

  @override
  String get off => 'Выкл.';

  @override
  String get fadeOnPlayPause => 'Плавный старт и пауза';

  @override
  String get skipSilence => 'Пропускать тишину';

  @override
  String get normalizeVolume => 'Нормализация громкости (ReplayGain)';

  @override
  String get normalizeHint =>
      'Использует теги ReplayGain, если они есть в файле';

  @override
  String get pitch => 'Тональность';

  @override
  String get resetValue => 'Сбросить';

  @override
  String get sectionBehavior => 'Поведение';

  @override
  String get resumeAfterCall => 'Продолжать после звонка';

  @override
  String get pauseOnDisconnect => 'Пауза при отключении наушников';

  @override
  String get resumeOnHeadset => 'Продолжать при подключении наушников';

  @override
  String get rememberQueue => 'Запоминать очередь и позицию';

  @override
  String get autoPlayOnStart => 'Автовоспроизведение при запуске';

  @override
  String get addMode => '«Добавить в очередь» по умолчанию';

  @override
  String get addToEnd => 'В конец очереди';

  @override
  String get shuffleStyle => 'Перемешивание';

  @override
  String get shuffleRandom => 'Полностью случайно';

  @override
  String get shuffleAvoidRecent => 'Без недавно прослушанных';

  @override
  String get sectionSleep => 'Таймер сна';

  @override
  String get sleepFadeOut => 'Плавно затухать перед остановкой';

  @override
  String get shakeToExtend => 'Встряхните, чтобы добавить 10 минут';

  @override
  String get sleepExtended => 'Таймер сна продлён на 10 минут';

  @override
  String get equalizer => 'Эквалайзер';

  @override
  String get eqEnabled => 'Включить эквалайзер';

  @override
  String get presets => 'Пресеты';

  @override
  String get eqNormal => 'Обычный';

  @override
  String get eqBass => 'Басы';

  @override
  String get eqTreble => 'Высокие';

  @override
  String get eqRock => 'Рок';

  @override
  String get eqPop => 'Поп';

  @override
  String get eqJazz => 'Джаз';

  @override
  String get eqClassical => 'Классика';

  @override
  String get eqVocal => 'Вокал';

  @override
  String get eqCustom => 'Свой';

  @override
  String get savePreset => 'Сохранить как пресет';

  @override
  String get presetName => 'Название пресета';

  @override
  String get deletePreset => 'Удалить пресет';

  @override
  String get bassBoost => 'Усиление басов';

  @override
  String get loudnessBoost => 'Усиление громкости';

  @override
  String get eqUnavailable => 'Эквалайзер недоступен на этом устройстве.';

  @override
  String get eqStartPlayback => 'Запустите песню, чтобы настроить полосы.';

  @override
  String hz(String value) {
    return '$value Гц';
  }

  @override
  String khz(String value) {
    return '$value кГц';
  }

  @override
  String db(String value) {
    return '$value дБ';
  }

  @override
  String get abRepeat => 'Повтор A–B';

  @override
  String get abSetA => 'Отметить точку A';

  @override
  String get abSetB => 'Отметить точку B';

  @override
  String get abClear => 'Выключить повтор A–B';

  @override
  String queueRemoved(String title) {
    return '«$title» удалена';
  }

  @override
  String get clearQueue => 'Очистить следующие';

  @override
  String get queueCleared => 'Следующие песни удалены';

  @override
  String get saveQueueAsPlaylist => 'Сохранить как плейлист';

  @override
  String get editTags => 'Изменить теги';

  @override
  String get changeArtwork => 'Сменить обложку';

  @override
  String get removeArtwork => 'Удалить обложку';

  @override
  String get tagsSaved => 'Теги сохранены';

  @override
  String get tagsNotSupported => 'Этот файл нельзя изменить';

  @override
  String get tagsFailed => 'Не удалось сохранить теги';

  @override
  String get yearInvalid => 'Введите корректный год';

  @override
  String get smartPlaylists => 'Умные плейлисты';

  @override
  String get myPlaylists => 'Мои плейлисты';

  @override
  String get recentlyAdded => 'Недавно добавленные';

  @override
  String get neverPlayed => 'Ни разу не слушали';

  @override
  String get importM3u => 'Импорт плейлиста M3U';

  @override
  String get exportM3u => 'Экспорт в M3U';

  @override
  String m3uImported(String name, String songs) {
    return 'Импортирован «$name»: $songs';
  }

  @override
  String get m3uNoMatches =>
      'Ни одна песня из плейлиста не найдена на устройстве';

  @override
  String get m3uExported => 'Плейлист экспортирован';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выбрано $count',
      many: 'Выбрано $count',
      few: 'Выбрано $count',
      one: 'Выбрана $count',
    );
    return '$_temp0';
  }

  @override
  String get selectAll => 'Выбрать все';

  @override
  String get cancelSelection => 'Отменить выбор';

  @override
  String deleteSongsTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалить $count песни с устройства?',
      many: 'Удалить $count песен с устройства?',
      few: 'Удалить $count песни с устройства?',
      one: 'Удалить $count песню с устройства?',
    );
    return '$_temp0';
  }

  @override
  String get deleteSongsMessage =>
      'Выбранные файлы будут навсегда удалены с устройства.';

  @override
  String songsDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалено $count песни',
      many: 'Удалено $count песен',
      few: 'Удалено $count песни',
      one: 'Удалена $count песня',
    );
    return '$_temp0';
  }

  @override
  String get addedToFavoritesMany => 'Добавлено в избранное';

  @override
  String get queueAction => 'В очередь';

  @override
  String get sectionFolders => 'Папки';

  @override
  String get libraryFolders => 'Папки медиатеки';

  @override
  String get libraryFoldersHint =>
      'Выберите, какие папки показывать в медиатеке';

  @override
  String get folderShown => 'Показывать';

  @override
  String get folderHidden => 'Скрыть';

  @override
  String get folderOnly => 'Только эти';

  @override
  String get folderOnlyActive =>
      'Показываются только папки с отметкой «Только эти»';

  @override
  String get resetFolders => 'Показывать все папки';

  @override
  String foldersSummary(int hidden) {
    return 'Скрыто: $hidden';
  }

  @override
  String get allFoldersShown => 'Показаны все папки';

  @override
  String get sectionFilters => 'Фильтры';

  @override
  String get minDuration => 'Минимальная длина песни';

  @override
  String get minSize => 'Минимальный размер файла';

  @override
  String kbValue(int n) {
    return '$n КБ';
  }

  @override
  String get hideShortSounds => 'Скрывать рингтоны и звуки уведомлений';

  @override
  String get sectionScanning => 'Сканирование';

  @override
  String get scanOnLaunch => 'Искать новую музыку при запуске';

  @override
  String get scanning => 'Сканирование музыки…';

  @override
  String scanFound(String songs) {
    return 'Медиатека обновлена: $songs';
  }

  @override
  String get sectionGrouping => 'Группировка';

  @override
  String get splitArtists => 'Разделять нескольких исполнителей';

  @override
  String get splitArtistsHint =>
      'Считать «A feat. B», «A & B» и «A; B» разными исполнителями';

  @override
  String get groupByAlbumArtist => 'Группировать по исполнителю альбома';

  @override
  String get lyricsSubtitle => 'Размер, выравнивание, синхронизация';

  @override
  String get notificationsSubtitle => 'Кнопки уведомления, кнопка гарнитуры';

  @override
  String get lyricsFontSize => 'Размер текста';

  @override
  String get lyricsAlign => 'Выравнивание';

  @override
  String get alignStart => 'По левому краю';

  @override
  String get alignCenter => 'По центру';

  @override
  String get lyricsOffset => 'Сдвиг синхронизации';

  @override
  String get lyricsOffsetHint => 'Если текст спешит или отстаёт';

  @override
  String offsetSeconds(String value) {
    return '$value с';
  }

  @override
  String get keepScreenOn => 'Не выключать экран при открытом тексте';

  @override
  String get autoScrollLyrics => 'Следовать за текущей строкой';

  @override
  String get lyricsSmaller => 'Мельче';

  @override
  String get lyricsLarger => 'Крупнее';

  @override
  String get lyricsEarlier => 'Показывать раньше';

  @override
  String get lyricsLater => 'Показывать позже';

  @override
  String get sectionNotification => 'Медиауведомление';

  @override
  String get notifArtwork => 'Показывать обложку';

  @override
  String get notifCloseButton => 'Кнопка закрытия';

  @override
  String get notifFavoriteButton => 'Кнопка «Избранное»';

  @override
  String get notifCompactSkip => 'Назад и вперёд в компактном виде';

  @override
  String get notificationPermission => 'Разрешение на уведомления';

  @override
  String get notificationPermissionHint =>
      'Нужно для управления из шторки на Android 13+';

  @override
  String get sectionHeadset => 'Кнопка гарнитуры';

  @override
  String get pressSingle => 'Одно нажатие';

  @override
  String get pressDouble => 'Двойное нажатие';

  @override
  String get pressTriple => 'Тройное нажатие';

  @override
  String get actionPlayPause => 'Воспроизведение / пауза';

  @override
  String get actionNext => 'Следующая песня';

  @override
  String get actionPrevious => 'Предыдущая песня';

  @override
  String get actionNone => 'Ничего';

  @override
  String get sectionWidget => 'Виджет на главном экране';

  @override
  String get widgetHint =>
      'Нажмите и удерживайте главный экран, выберите «Виджеты» и добавьте Navo.';

  @override
  String get widgetNothingPlaying => 'Ничего не играет';

  @override
  String get gesturesSubtitle => 'Свайп мини-плеера, вибрация';

  @override
  String get gestureMiniSwipe => 'Свайп по мини-плееру: следующая / предыдущая';

  @override
  String get gestureDoubleTap =>
      'Двойное касание обложки: пауза / воспроизведение';

  @override
  String get gestureSwipeArtwork => 'Свайп по обложке: сменить песню';

  @override
  String get gestureShake => 'Встряхнуть — следующая песня';

  @override
  String get gestureShakeSensitivity => 'Чувствительность встряхивания';

  @override
  String get gestureVolumeSeek => 'Кнопки громкости перематывают в плеере';

  @override
  String get gestureVolumeSeekHint =>
      'Пока открыт плеер: вверх = +10 с, вниз = −10 с';

  @override
  String get haptics => 'Тактильная отдача';

  @override
  String get stats => 'Статистика прослушивания';

  @override
  String get statsSubtitle => 'Хранится только на этом устройстве';

  @override
  String get statsTotal => 'Всего прослушано';

  @override
  String get statsThisWeek => 'На этой неделе';

  @override
  String get statsLast7Days => 'Последние 7 дней';

  @override
  String get statsTopSongs => 'Лучшие песни';

  @override
  String get statsTopArtists => 'Лучшие исполнители';

  @override
  String get statsTopAlbums => 'Лучшие альбомы';

  @override
  String get statsEmpty => 'Данных о прослушивании пока нет';

  @override
  String get statsEmptyHint =>
      'Послушайте музыку и возвращайтесь за статистикой.';

  @override
  String get statsDisabled =>
      'Статистика выключена в настройках конфиденциальности.';

  @override
  String get collectStats => 'Собирать статистику прослушивания';

  @override
  String get clearStats => 'Очистить статистику';

  @override
  String get clearStatsTitle => 'Очистить статистику?';

  @override
  String get clearStatsMessage =>
      'Время прослушивания, рейтинги и счётчики будут сброшены.';

  @override
  String get statsCleared => 'Статистика очищена';

  @override
  String hoursMinutes(int h, int m) {
    return '$h ч $m мин';
  }

  @override
  String minutesOnly(int m) {
    return '$m мин';
  }

  @override
  String dayMinutes(String day, String minutes) {
    return '$day: $minutes';
  }

  @override
  String get filterAll => 'Все';

  @override
  String get quickActions => 'Быстрые действия';

  @override
  String get advancedSettings => 'Дополнительно';

  @override
  String advancedSettingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ещё $count настроек',
      few: 'Ещё $count настройки',
      one: 'Ещё $count настройка',
    );
    return '$_temp0';
  }

  @override
  String get storageSubtitle =>
      'Резервная копия настроек, избранного и плейлистов';

  @override
  String get backupExport => 'Создать резервную копию';

  @override
  String get backupExportHint =>
      'Настройки, избранное, плейлисты и скрытые песни в файл';

  @override
  String get backupImport => 'Восстановить из копии';

  @override
  String get backupImportHint =>
      'Заменит текущие настройки, избранное и плейлисты';

  @override
  String get backupSaved => 'Резервная копия сохранена';

  @override
  String get backupRestored => 'Восстановлено из копии';

  @override
  String get backupInvalid => 'Этот файл не является копией Navo';

  @override
  String get restoreBackupTitle => 'Восстановить копию?';

  @override
  String get restoreBackupMessage =>
      'Текущие настройки, избранное и плейлисты будут заменены.';
}
