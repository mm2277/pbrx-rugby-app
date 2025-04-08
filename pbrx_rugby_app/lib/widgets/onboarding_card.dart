import 'package:flutter/material.dart';

class OnboardingCard extends StatelessWidget {
  final String image,title, description, buttonText;
  final Function onPressed;

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
      height: MediaQuery.sizeOf(context).height*0.8,
      width: MediaQuery.sizeOf(context).width, 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Image.asset(image,),
          ),
          Column(
            children: [Text(
              title, 
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
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
          ElevatedButton(
            onPressed: () => onPressed(),
            child: Text(
              buttonText, 
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
            ),),
          ),
        ],
      ),
    );
  }
}