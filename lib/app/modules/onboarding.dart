import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todark/app/modules/home.dart';
import 'package:todark/app/widgets/button.dart';
import 'package:todark/main.dart'; // Import to access global settings variable
import 'package:todark/app/modules/auth_screen.dart'; // Import the AuthScreen
import 'package:todark/app/data/models.dart' as app_models;

class OnBording extends StatefulWidget {
  const OnBording({super.key});

  @override
  State<OnBording> createState() => _OnBordingState();
}

class _OnBordingState extends State<OnBording> {
  late PageController pageController;
  int pageIndex = 0;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  User? get currentUser => auth.currentUser;

  @override
  void initState() {
    pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> onBoardHome() async {
    if (currentUser == null) {
      // Navigate to login page if user is not authenticated
      Get.off(() => const AuthScreen(), transition: Transition.downToUp);
      return;
    }

    final docRef = firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('settings')
        .doc('settings');

    try {
      // Check if the document exists
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        // Create the document if it does not exist
        settings = app_models.Settings(
          id: DateTime.now().millisecondsSinceEpoch,
          onboard: true, // Setting onboard to true after onboarding is complete
          theme: 'system',
          amoledTheme: false,
          materialColor: false,
          isImage: true,
          timeformat: '24',
          firstDay: 'monday',
          language: 'en_US',
          userId: currentUser!.uid,
        );
        await docRef.set(settings!.toFirestore());
      } else {
        // Update the onboard field to true
        await docRef.update({'onboard': true});
      }

      // Initialize the settings again to ensure they are loaded
      await initSettings();

      Get.off(() => const HomePage(), transition: Transition.downToUp);
    } catch (e) {
      print("Error completing onboarding: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: data.length,
                onPageChanged: (index) {
                  setState(() {
                    pageIndex = index;
                  });
                },
                itemBuilder: (context, index) => OnboardContent(
                  image: data[index].image,
                  title: data[index].title,
                  description: data[index].description,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                    data.length,
                    (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: DotIndicator(isActive: index == pageIndex),
                        )),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: MyTextButton(
                buttonName:
                    pageIndex == data.length - 1 ? 'getStart'.tr : 'next'.tr,
                onPressed: () {
                  pageIndex == data.length - 1
                      ? onBoardHome()
                      : pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    this.isActive = false,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: isActive
            ? context.theme.colorScheme.secondary
            : context.theme.colorScheme.secondaryContainer,
        shape: BoxShape.circle,
      ),
    );
  }
}

class Onboard {
  final String image, title, description;

  Onboard({
    required this.image,
    required this.title,
    required this.description,
  });
}

final List<Onboard> data = [
  Onboard(
      image: 'assets/images/Task.png',
      title: 'title1'.tr,
      description: 'subtitle1'.tr),
  Onboard(
      image: 'assets/images/Design.png',
      title: 'title2'.tr,
      description: 'subtitle2'.tr),
  Onboard(
      image: 'assets/images/Feedback.png',
      title: 'title3'.tr,
      description: 'subtitle3'.tr),
];

class OnboardContent extends StatelessWidget {
  const OnboardContent({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });
  final String image, title, description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                image,
                scale: 5,
              ),
              Text(
                title,
                style: context.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 300,
                child: Text(
                  description,
                  style: context.textTheme.labelLarge?.copyWith(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
