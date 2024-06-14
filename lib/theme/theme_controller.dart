import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThemeController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  ThemeMode get theme {
    String? themeSetting = Get.parameters['theme'] ??
        'system'; // This needs to be set appropriately
    return themeSetting == 'system'
        ? ThemeMode.system
        : themeSetting == 'dark'
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  void saveOledTheme(bool isOled) async {
    if (user != null) {
      await firestore
          .collection('users')
          .doc(user!.uid)
          .collection('settings')
          .doc('settings')
          .update({
        'amoledTheme': isOled,
      });
      Get.parameters['amoledTheme'] =
          isOled.toString(); // Update locally for immediate effect
      update();
    }
  }

  void saveMaterialTheme(bool isMaterial) async {
    if (user != null) {
      await firestore
          .collection('users')
          .doc(user!.uid)
          .collection('settings')
          .doc('settings')
          .update({
        'materialColor': isMaterial,
      });
      Get.parameters['materialColor'] =
          isMaterial.toString(); // Update locally for immediate effect
      update();
    }
  }

  void saveTheme(String themeMode) async {
    if (user != null) {
      await firestore
          .collection('users')
          .doc(user!.uid)
          .collection('settings')
          .doc('settings')
          .update({
        'theme': themeMode,
      });
      Get.parameters['theme'] =
          themeMode; // Update locally for immediate effect
      update();
    }
  }

  void changeTheme(ThemeData theme) {
    Get.changeTheme(theme);
    update();
  }

  void changeThemeMode(ThemeMode themeMode) {
    Get.changeThemeMode(themeMode);
    update();
  }
}
