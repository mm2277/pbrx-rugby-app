import 'package:flutter/material.dart';
import 'package:pbrx_rugby_app/models/profile.dart';
import 'package:pbrx_rugby_app/models/store_data_locally.dart';
import 'package:pbrx_rugby_app/widgets/create_profile_card.dart';
import 'package:pbrx_rugby_app/widgets/onboarding_card.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget{
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState()=> _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  
  static final PageController _pageController = PageController(initialPage: 0);
  
  // static final Profile tmp = Profile(
  //   name: "Name", 
  //   position: Position.forward,
  //   skills: [Skills.boxKick,]
  // );

  // static final TextEditingController _nameController = TextEditingController();

  List<Widget> _onboardingPages = [
    OnboardingCard(
      image: "assets/images/Welcome_Onboarding_Sign.png",
      title: "Welcome to the Rugby App",
      description: "This is the new description for the page",
      buttonText: "Next",
      onPressed: () {
        _pageController.animateToPage(1, duration: Durations.long1, curve: Curves.linear);
      },
      ),

      OnboardingCard(
      image: "assets/images/Onboarding_2.png",
      title: "What happens now?",
      description: "We will take some data from you and based on that data",
      buttonText: "Next",
       onPressed: () {
        _pageController.animateToPage(2, duration: Durations.long1, curve: Curves.linear);
      },
      ),

      CreateProfileCard(storage: StoreDataLocally()),
   
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
                children: _onboardingPages,)),
            SmoothPageIndicator(
              effect: ExpandingDotsEffect(
                activeDotColor: Theme.of(context).colorScheme.primary,
                dotColor: Theme.of(context).colorScheme.secondary,
              ),
              controller: _pageController, 
              count: _onboardingPages.length,
              onDotClicked: (index) {
                _pageController.animateToPage(index, duration: Durations.long1, curve: Curves.linear);
              },
            )],
        ),
      ),
    );
  }

}