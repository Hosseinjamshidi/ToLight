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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todark/app/controller/todo_controller.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'platform_utils.dart' if (dart.library.html) 'platform_utils_web.dart';
import 'theme/theme_controller.dart';
import 'translation/translation.dart';
import 'app/modules/home.dart';
import 'app/modules/onboarding.dart';
import 'app/modules/auth_screen.dart';
import 'theme/theme.dart';
import 'app/data/models.dart' as app_models;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

app_models.Settings? settings; // Make settings nullable

String theme = "system";
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

  // Initialize the ThemeController before running the app
  Get.put(ThemeController());

  runApp(const MyApp());

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      setOptimalDisplayMode();
    }
  });
}

Future<void> initSettings() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return; // Handle the case where user is not logged in
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentSnapshot settingsSnapshot = await firestore
      .collection('users')
      .doc(user.uid)
      .collection('settings')
      .doc('settings')
      .get();

  if (settingsSnapshot.exists) {
    settings = app_models.Settings.fromFirestore(
        settingsSnapshot.data() as Map<String, dynamic>);
    // Apply settings immediately
    theme = settings!.theme!;
    amoledTheme = settings!.amoledTheme;
    materialColor = settings!.materialColor;
    timeformat = settings!.timeformat;
    firstDay = settings!.firstDay;
    isImage = settings!.isImage!;
    locale = Locale(
        settings!.language!.substring(0, 2), settings!.language!.substring(3));
    Get.find<ThemeController>().changeThemeMode(
      theme == 'system'
          ? ThemeMode.system
          : theme == 'dark'
              ? ThemeMode.dark
              : ThemeMode.light,
    );
    // Apply other settings
    MyAppLoaded.updateAppState(
      Get.context!,
      newAmoledTheme: amoledTheme,
      newMaterialColor: materialColor,
      newIsImage: isImage,
      newTimeformat: timeformat,
      newFirstDay: firstDay,
      newLocale: locale,
    );
  } else {
    settings = app_models.Settings(
      id: DateTime.now().millisecondsSinceEpoch,
      onboard: false,
      theme: 'system',
      amoledTheme: false,
      materialColor: false,
      isImage: true,
      timeformat: '24',
      firstDay: 'monday',
      language: 'en_US',
      userId: user.uid,
    );
    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('settings')
        .set(settings!.toFirestore());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _settingsInitialized = false;

  @override
  void initState() {
    super.initState();
    initSettings().then((_) {
      setState(() {
        _settingsInitialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _settingsInitialized
        ? const MyAppLoaded()
        : const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Loading...'),
              ),
            ),
          );
  }
}

class MyAppLoaded extends StatefulWidget {
  const MyAppLoaded({super.key});

  static Future<void> updateAppState(
    BuildContext context, {
    String? newTheme,
    bool? newAmoledTheme,
    bool? newMaterialColor,
    bool? newIsImage,
    String? newTimeformat,
    String? newFirstDay,
    Locale? newLocale,
  }) async {
    final state = context.findAncestorStateOfType<_MyAppLoadedState>()!;

    if (newTheme != null) {
      state.changeTheme(newTheme);
    }
    if (newAmoledTheme != null) {
      state.changeAmoledTheme(newAmoledTheme);
    }
    if (newMaterialColor != null) {
      state.changeMaterialTheme(newMaterialColor);
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
  _MyAppLoadedState createState() => _MyAppLoadedState();
}

class _MyAppLoadedState extends State<MyAppLoaded> {
  late ThemeController themeController;

  @override
  void initState() {
    super.initState();
    themeController = Get.find<ThemeController>();
    if (settings != null) {
      theme = settings!.theme!;
      amoledTheme = settings!.amoledTheme;
      materialColor = settings!.materialColor;
      timeformat = settings!.timeformat;
      firstDay = settings!.firstDay;
      isImage = settings!.isImage!;
      locale = Locale(settings!.language!.substring(0, 2),
          settings!.language!.substring(3));
      themeController.changeThemeMode(
        theme == 'system'
            ? ThemeMode.system
            : theme == 'dark'
                ? ThemeMode.dark
                : ThemeMode.light,
      );
      MyAppLoaded.updateAppState(
        context,
        newTheme: theme,
        newAmoledTheme: amoledTheme,
        newMaterialColor: materialColor,
        newIsImage: isImage,
        newTimeformat: timeformat,
        newFirstDay: firstDay,
        newLocale: locale,
      );
      Get.find<TodoController>().updateLocalSettings();
    }
  }

  void changeTheme(String newTheme) {
    setState(() {
      theme = newTheme;
      themeController.changeThemeMode(
        newTheme == 'system'
            ? ThemeMode.system
            : newTheme == 'dark'
                ? ThemeMode.dark
                : ThemeMode.light,
      );
    });
  }

  void changeAmoledTheme(bool newAmoledTheme) {
    setState(() {
      amoledTheme = newAmoledTheme;
    });
  }

  void changeMaterialTheme(bool newMaterialColor) {
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
    Get.updateLocale(newLocale);
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
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: Text('Loading...'),
                    ),
                  );
                } else if (snapshot.hasData && settings == null) {
                  return FutureBuilder<void>(
                    future: initSettings(),
                    builder: (context, settingsSnapshot) {
                      if (settingsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Scaffold(
                          body: Center(
                            child: Text('Loading...'),
                          ),
                        );
                      } else if (settingsSnapshot.hasError) {
                        return Scaffold(
                          body: Center(
                            child: Text(
                                'Error initializing settings: ${settingsSnapshot.error}'),
                          ),
                        );
                      } else {
                        return const OnBording();
                      }
                    },
                  );
                } else if (snapshot.hasData && settings != null) {
                  return settings!.onboard
                      ? const HomePage()
                      : const AuthScreen();
                } else {
                  return const OnBording(); // Show onboarding if no user is logged in
                }
              },
            ),
            builder: EasyLoading.init(),
            title: 'ToDark',
          );
        },
      ),
    );
  }
}
