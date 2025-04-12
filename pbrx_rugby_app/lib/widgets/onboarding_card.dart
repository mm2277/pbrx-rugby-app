import 'package:flutter/material.dart';

// A reusable widget for displaying an onboarding step with an image, title, description, and a button to continue or take action.
class OnboardingCard extends StatelessWidget {
  final String image; // path to the image 
  final String title; // title text
  final String description; // description text
  final String buttonText; // txt to display on the button
  final Function onPressed; // callback function 

  const OnboardingCard({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Display images
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Image.asset(
              image,
            ),
          ),

          // titles and descriptions UI
          Column(
            children: [
              // Title text
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Description text
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),

          // button to trigger callback function
          ElevatedButton(
            onPressed: () => onPressed(), 
            child: Text(
              buttonText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
