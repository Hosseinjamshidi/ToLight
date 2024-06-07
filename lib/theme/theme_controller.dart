import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThemeController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  ThemeMode get theme {
    String? themeSetting =
        Get.parameters['theme']; // This needs to be set appropriately
    return themeSetting == 'system'
        ? ThemeMode.system
        : themeSetting == 'dark'
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  void saveOledTheme(bool isOled) async {
    await firestore.collection('settings').doc('settings').update({
      'amoledTheme': isOled,
    });
    Get.parameters['amoledTheme'] =
        isOled.toString(); // Update locally for immediate effect
  }

  void saveMaterialTheme(bool isMaterial) async {
    await firestore.collection('settings').doc('settings').update({
      'materialColor': isMaterial,
    });
    Get.parameters['materialColor'] =
        isMaterial.toString(); // Update locally for immediate effect
  }

  void saveTheme(String themeMode) async {
    await firestore.collection('settings').doc('settings').update({
      'theme': themeMode,
    });
    Get.parameters['theme'] = themeMode; // Update locally for immediate effect
  }

  void changeTheme(ThemeData theme) => Get.changeTheme(theme);

  void changeThemeMode(ThemeMode themeMode) => Get.changeThemeMode(themeMode);
}
