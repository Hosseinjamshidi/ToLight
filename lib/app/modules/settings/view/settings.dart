import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:todark/app/controller/todo_controller.dart';
import 'package:todark/app/modules/auth_screen.dart';
import 'package:todark/main.dart';
import 'package:todark/theme/theme_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:todark/app/modules/settings/widgets/settings_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final todoController = Get.put(TodoController());
  final themeController = Get.put(ThemeController());
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? appVersion;

  Future<void> infoVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  Future<void> updateLanguage(Locale locale) async {
    await todoController.updateSetting('language', locale.toString());
    Get.updateLocale(locale);
    Get.back();
  }

  String firstDayOfWeek(String newValue) {
    Map<String, String> translations = {
      'monday': 'monday',
      'tuesday': 'tuesday',
      'wednesday': 'wednesday',
      'thursday': 'thursday',
      'friday': 'friday',
      'saturday': 'saturday',
      'sunday': 'sunday',
      'monday'.tr: 'monday',
      'tuesday'.tr: 'tuesday',
      'wednesday'.tr: 'wednesday',
      'thursday'.tr: 'thursday',
      'friday'.tr: 'friday',
      'saturday'.tr: 'saturday',
      'sunday'.tr: 'sunday',
    };

    return translations[newValue] ?? 'monday';
  }

  @override
  void initState() {
    infoVersion();
    super.initState();
  }

  @override
  void dispose() {
    // Perform any cleanup tasks here
    super.dispose();
  }

  void updateSetting(String key, dynamic value) async {
    await todoController.updateSetting(key, value);
    todoController.updateLocalSettings(); // Update local settings
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(
        () => const AuthScreen()); // Navigate to auth screen after logout
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'settings'.tr,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SettingCard(
              icon: const Icon(Iconsax.brush_1),
              text: 'appearance'.tr,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, setState) {
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                child: Text(
                                  'appearance'.tr,
                                  style: context.textTheme.titleLarge?.copyWith(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SettingCard(
                                elevation: 4,
                                icon: const Icon(Iconsax.moon),
                                text: 'theme'.tr,
                                dropdown: true,
                                dropdownName: settings?.theme ?? 'system',
                                dropdownList: const <String>[
                                  'system',
                                  'dark',
                                  'light'
                                ],
                                dropdownChange: (String? newValue) {
                                  ThemeMode themeMode = newValue == 'system'
                                      ? ThemeMode.system
                                      : newValue == 'dark'
                                          ? ThemeMode.dark
                                          : ThemeMode.light;
                                  String theme = newValue == 'system'
                                      ? 'system'
                                      : newValue == 'dark'
                                          ? 'dark'
                                          : 'light';
                                  themeController.saveTheme(theme);
                                  themeController.changeThemeMode(themeMode);
                                  updateSetting('theme', theme);
                                },
                              ),
                              SettingCard(
                                elevation: 4,
                                icon: const Icon(Iconsax.mobile),
                                text: 'amoledTheme'.tr,
                                switcher: true,
                                value: settings?.amoledTheme ?? false,
                                onChange: (value) {
                                  themeController.saveOledTheme(value);
                                  updateSetting('amoledTheme', value);
                                  MyAppLoaded.updateAppState(context,
                                      newAmoledTheme: value);
                                },
                              ),
                              SettingCard(
                                elevation: 4,
                                icon: const Icon(Iconsax.colorfilter),
                                text: 'materialColor'.tr,
                                switcher: true,
                                value: settings?.materialColor ?? false,
                                onChange: (value) {
                                  themeController.saveMaterialTheme(value);
                                  updateSetting('materialColor', value);
                                  MyAppLoaded.updateAppState(context,
                                      newMaterialColor: value);
                                },
                              ),
                              SettingCard(
                                elevation: 4,
                                icon: const Icon(Iconsax.image),
                                text: 'isImages'.tr,
                                switcher: true,
                                value: settings?.isImage ?? true,
                                onChange: (value) {
                                  updateSetting('isImage', value);
                                  MyAppLoaded.updateAppState(context,
                                      newIsImage: value);
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            SettingCard(
              icon: const Icon(Iconsax.code),
              text: 'functions'.tr,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, setState) {
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                child: Text(
                                  'functions'.tr,
                                  style: context.textTheme.titleLarge?.copyWith(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SettingCard(
                                elevation: 4,
                                icon: const Icon(Iconsax.clock),
                                text: 'timeformat'.tr,
                                dropdown: true,
                                dropdownName: settings?.timeformat ?? '24',
                                dropdownList: const <String>['12', '24'],
                                dropdownChange: (String? newValue) {
                                  String timeformat =
                                      newValue == '12' ? '12' : '24';
                                  updateSetting('timeformat', timeformat);
                                  MyAppLoaded.updateAppState(context,
                                      newTimeformat: timeformat);
                                },
                              ),
                              SettingCard(
                                elevation: 4,
                                icon: const Icon(Iconsax.calendar_edit),
                                text: 'firstDayOfWeek'.tr,
                                dropdown: true,
                                dropdownName: settings?.firstDay ?? 'monday',
                                dropdownList: const <String>[
                                  'monday',
                                  'tuesday',
                                  'wednesday',
                                  'thursday',
                                  'friday',
                                  'saturday',
                                  'sunday',
                                ],
                                dropdownChange: (String? newValue) {
                                  if (newValue != null) {
                                    final firstDay = firstDayOfWeek(newValue);
                                    updateSetting('firstDay', firstDay);
                                    MyAppLoaded.updateAppState(context,
                                        newFirstDay: firstDay);
                                  }
                                },
                              ),
                              // Remove backup and restore since it's Isar-specific
                              // const SizedBox(height: 10),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            SettingCard(
              icon: const Icon(Iconsax.language_square),
              text: 'language'.tr,
              info: true,
              infoSettings: true,
              textInfo: appLanguages.firstWhere(
                  (element) => (element['locale'] == locale),
                  orElse: () => appLanguages.first)['name'],
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, setState) {
                        return ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Text(
                                'language'.tr,
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: appLanguages.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  child: ListTile(
                                    title: Text(
                                      appLanguages[index]['name'],
                                      style: context.textTheme.labelLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                    onTap: () {
                                      MyAppLoaded.updateAppState(context,
                                          newLocale: appLanguages[index]
                                              ['locale']);
                                      updateLanguage(
                                          appLanguages[index]['locale']);
                                    },
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
            SettingCard(
              icon: const Icon(Iconsax.dollar_square),
              text: 'support'.tr,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, setState) {
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                child: Text(
                                  'support'.tr,
                                  style: context.textTheme.titleLarge?.copyWith(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SettingCard(
                                elevation: 4,
                                icon: const Icon(Iconsax.card),
                                text: 'DonationAlerts',
                                onPressed: () async {
                                  final Uri url = Uri.parse(
                                      'https://www.donationalerts.com/r/darkmoonight');
                                  if (!await launchUrl(url,
                                      mode: LaunchMode.externalApplication)) {
                                    throw Exception('Could not launch $url');
                                  }
                                },
                              ),
                              SettingCard(
                                elevation: 4,
                                icon: const Icon(Iconsax.wallet),
                                text: 'ЮMoney',
                                onPressed: () async {
                                  final Uri url = Uri.parse(
                                      'https://yoomoney.ru/to/4100117672775961');
                                  if (!await launchUrl(url,
                                      mode: LaunchMode.externalApplication)) {
                                    throw Exception('Could not launch $url');
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            SettingCard(
              icon: const Icon(Iconsax.link_square),
              text: 'groups'.tr,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, setState) {
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                child: Text(
                                  'groups'.tr,
                                  style: context.textTheme.titleLarge?.copyWith(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SettingCard(
                                elevation: 4,
                                icon: const Icon(Iconsax.voice_square),
                                text: 'Discord',
                                onPressed: () async {
                                  final Uri url = Uri.parse(
                                      'https://discord.gg/JMMa9aHh8f');
                                  if (!await launchUrl(url,
                                      mode: LaunchMode.externalApplication)) {
                                    throw Exception('Could not launch $url');
                                  }
                                },
                              ),
                              SettingCard(
                                elevation: 4,
                                icon: const Icon(Iconsax.message_square),
                                text: 'Telegram',
                                onPressed: () async {
                                  final Uri url =
                                      Uri.parse('https://t.me/darkmoonightX');
                                  if (!await launchUrl(url,
                                      mode: LaunchMode.externalApplication)) {
                                    throw Exception('Could not launch $url');
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            SettingCard(
              icon: const Icon(Iconsax.document),
              text: 'license'.tr,
              onPressed: () => Get.to(
                LicensePage(
                  applicationIcon: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        image: DecorationImage(
                            image: AssetImage('assets/icons/icon.png'))),
                  ),
                  applicationName: 'ToDark',
                  applicationVersion: appVersion,
                ),
                transition: Transition.downToUp,
              ),
            ),
            SettingCard(
              icon: const Icon(Iconsax.hierarchy_square_2),
              text: 'version'.tr,
              info: true,
              textInfo: '$appVersion',
            ),
            SettingCard(
              icon: Image.asset(
                'assets/images/github.png',
                scale: 20,
              ),
              text: '${'project'.tr} GitHub',
              onPressed: () async {
                final Uri url =
                    Uri.parse('https://github.com/DarkMooNight/ToDark');
                if (!await launchUrl(url,
                    mode: LaunchMode.externalApplication)) {
                  throw Exception('Could not launch $url');
                }
              },
            ),
            SettingCard(
              icon: const Icon(Iconsax.logout), // Icon for logout
              text: 'logout'.tr,
              onPressed: () async {
                await logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
