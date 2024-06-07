import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'platform_utils.dart' if (dart.library.html) 'platform_utils_web.dart';
import 'theme/theme_controller.dart';
import 'translation/translation.dart';
import 'app/modules/home.dart';
import 'app/modules/onboarding.dart';
import 'theme/theme.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

late Settings settings;

bool amoledTheme = false;
bool materialColor = false;
bool isImage = true;
String timeformat = '24';
String firstDay = 'monday';
Locale locale = const Locale('en', 'US');

final List appLanguages = [
  {'name': 'العربية', 'locale': const Locale('ar', 'AR')},
  {'name': 'Deutsch', 'locale': const Locale('de', 'DE')},
  {'name': 'English', 'locale': const Locale('en', 'US')},
  {'name': 'Español', 'locale': const Locale('es', 'ES')},
  {'name': 'Français', 'locale': const Locale('fr', 'FR')},
  {'name': 'Italiano', 'locale': const Locale('it', 'IT')},
  {'name': '한국어', 'locale': const Locale('ko', 'KR')},
  {'name': 'فارسی', 'locale': const Locale('fa', 'IR')},
  {'name': 'Русский', 'locale': const Locale('ru', 'RU')},
  {'name': 'Tiếng việt', 'locale': const Locale('vi', 'VN')},
  {'name': 'Türkçe', 'locale': const Locale('tr', 'TR')},
  {'name': '中文(简体)', 'locale': const Locale('zh', 'CN')},
  {'name': '中文(繁體)', 'locale': const Locale('zh', 'TW')},
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initSettings(); // Ensure settings are initialized before running the app

  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(systemNavigationBarColor: Colors.black));

  final String timeZoneName = await getLocalTimezone();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(timeZoneName));

  const DarwinInitializationSettings initializationSettingsIos =
      DarwinInitializationSettings();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'ToDark');
  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      linux: initializationSettingsLinux,
      iOS: initializationSettingsIos);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      setOptimalDisplayMode();
    }
  });
}

Future<void> initSettings() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentSnapshot settingsSnapshot =
      await firestore.collection('settings').doc('settings').get();

  if (settingsSnapshot.exists) {
    settings = Settings.fromFirestore(settingsSnapshot);
  } else {
    settings = Settings(
      onboard: false,
      theme: 'system',
      amoledTheme: false,
      materialColor: false,
      isImage: true,
      timeformat: '24',
      firstDay: 'monday',
      language: 'en_US',
    );
    await firestore
        .collection('settings')
        .doc('settings')
        .set(settings.toFirestore());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static Future<void> updateAppState(
    BuildContext context, {
    bool? newAmoledTheme,
    bool? newMaterialColor,
    bool? newIsImage,
    String? newTimeformat,
    String? newFirstDay,
    Locale? newLocale,
  }) async {
    final state = context.findAncestorStateOfType<_MyAppState>()!;

    if (newAmoledTheme != null) {
      state.changeAmoledTheme(newAmoledTheme);
    }
    if (newMaterialColor != null) {
      state.changeMarerialTheme(newMaterialColor);
    }
    if (newTimeformat != null) {
      state.changeTimeFormat(newTimeformat);
    }
    if (newFirstDay != null) {
      state.changeFirstDay(newFirstDay);
    }
    if (newLocale != null) {
      state.changeLocale(newLocale);
    }
    if (newIsImage != null) {
      state.changeIsImage(newIsImage);
    }
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final themeController = Get.put(ThemeController());

  void changeAmoledTheme(bool newAmoledTheme) {
    setState(() {
      amoledTheme = newAmoledTheme;
    });
  }

  void changeMarerialTheme(bool newMaterialColor) {
    setState(() {
      materialColor = newMaterialColor;
    });
  }

  void changeIsImage(bool newIsImage) {
    setState(() {
      isImage = newIsImage;
    });
  }

  void changeTimeFormat(String newTimeformat) {
    setState(() {
      timeformat = newTimeformat;
    });
  }

  void changeFirstDay(String newFirstDay) {
    setState(() {
      firstDay = newFirstDay;
    });
  }

  void changeLocale(Locale newLocale) {
    setState(() {
      locale = newLocale;
    });
  }

  @override
  void initState() {
    super.initState();
    amoledTheme = settings.amoledTheme;
    materialColor = settings.materialColor;
    timeformat = settings.timeformat;
    firstDay = settings.firstDay;
    isImage = settings.isImage!;
    locale = Locale(
        settings.language!.substring(0, 2), settings.language!.substring(3));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: DynamicColorBuilder(
        builder: (lightColorScheme, darkColorScheme) {
          final lightMaterialTheme =
              lightTheme(lightColorScheme?.surface, lightColorScheme);
          final darkMaterialTheme =
              darkTheme(darkColorScheme?.surface, darkColorScheme);
          final darkMaterialThemeOled = darkTheme(oledColor, darkColorScheme);

          return GetMaterialApp(
            theme: materialColor
                ? lightColorScheme != null
                    ? lightMaterialTheme
                    : lightTheme(lightColor, colorSchemeLight)
                : lightTheme(lightColor, colorSchemeLight),
            darkTheme: amoledTheme
                ? materialColor
                    ? darkColorScheme != null
                        ? darkMaterialThemeOled
                        : darkTheme(oledColor, colorSchemeDark)
                    : darkTheme(oledColor, colorSchemeDark)
                : materialColor
                    ? darkColorScheme != null
                        ? darkMaterialTheme
                        : darkTheme(darkColor, colorSchemeDark)
                    : darkTheme(darkColor, colorSchemeDark),
            themeMode: themeController.theme,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            translations: Translation(),
            locale: locale,
            fallbackLocale: const Locale('en', 'US'),
            supportedLocales:
                appLanguages.map((e) => e['locale'] as Locale).toList(),
            debugShowCheckedModeBanner: false,
            home: settings.onboard ? const HomePage() : const OnBording(),
            builder: EasyLoading.init(),
            title: 'ToDark',
          );
        },
      ),
    );
  }
}

class Settings {
  bool onboard;
  String? theme;
  bool amoledTheme;
  bool materialColor;
  bool? isImage;
  String timeformat;
  String firstDay;
  String? language;

  Settings({
    required this.onboard,
    this.theme,
    required this.amoledTheme,
    required this.materialColor,
    this.isImage,
    required this.timeformat,
    required this.firstDay,
    this.language,
  });

  factory Settings.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Settings(
      onboard: data['onboard'] ?? false,
      theme: data['theme'],
      amoledTheme: data['amoledTheme'] ?? false,
      materialColor: data['materialColor'] ?? false,
      isImage: data['isImage'] ?? true,
      timeformat: data['timeformat'] ?? '24',
      firstDay: data['firstDay'] ?? 'monday',
      language: data['language'] ?? 'en_US',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'onboard': onboard,
      'theme': theme,
      'amoledTheme': amoledTheme,
      'materialColor': materialColor,
      'isImage': isImage,
      'timeformat': timeformat,
      'firstDay': firstDay,
      'language': language,
    };
  }
}
