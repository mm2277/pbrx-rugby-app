import 'package:flutter/material.dart';
import 'package:pbrx_rugby_app/models/store_data_locally.dart';
import 'package:pbrx_rugby_app/widgets/create_profile_card.dart';
import 'package:pbrx_rugby_app/widgets/onboarding_card.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static final PageController _pageController = PageController(initialPage: 0);

  List<Widget> _onboardingPages = [
    OnboardingCard(
      image: "assets/images/Welcome_Onboarding_Sign.png",
      title: "Welcome to the Rugby App",
      description:
          "Whether you're a seasoned athlete or just starting out, this application is here to support your rugby journey. Build your player profile and get training plans tailored to your position, ability and skills",
      buttonText: "Next",
      onPressed: () {
        _pageController.animateToPage(1,
            duration: Durations.long1, curve: Curves.linear);
      },
    ),
    OnboardingCard(
      image: "assets/images/Onboarding_2.png",
      title: "What happens now?",
      description:
          "Let’s get you set up. You’ll start by creating your profile — add your name, select your abilty, select your position, and highlight your skills. From there, the application will guide you with personalized training plans to help you grow and perform at your best.",
      buttonText: "Next",
      onPressed: () {
        _pageController.animateToPage(2,
            duration: Durations.long1, curve: Curves.linear);
      },
    ),
    CreateProfileCard(
      storage: StoreDataLocally(),
      title: "Create your Profile",
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: PageView(
              controller: _pageController,
              children: _onboardingPages,
            )),
            SmoothPageIndicator(
              effect: ExpandingDotsEffect(
                activeDotColor: Theme.of(context).colorScheme.primary,
                dotColor: Theme.of(context).colorScheme.secondary,
              ),
              controller: _pageController,
              count: _onboardingPages.length,
              onDotClicked: (index) {
                _pageController.animateToPage(index,
                    duration: Durations.long1, curve: Curves.linear);
              },
            )
          ],
        ),
      ),
    );
  }
}
