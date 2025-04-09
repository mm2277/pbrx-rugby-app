import 'package:flutter/material.dart';
import 'package:pbrx_rugby_app/models/profile.dart';
import 'package:pbrx_rugby_app/models/store_data_locally.dart';
import 'package:pbrx_rugby_app/widgets/create_profile_card.dart';
import 'package:pbrx_rugby_app/widgets/profile_card.dart';

class MainAppPage extends StatefulWidget {
  final Profile profile;

  const MainAppPage({super.key, required this.profile});

  @override
  State<MainAppPage> createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage> {
  var selectedIndex = 0;
  bool editing = false;

  void toggleEditMode() {
    setState(() {
      editing = !editing;
    });

  }

  
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
         page = editing
            ? CreateProfileCard(storage: StoreDataLocally(), existingProfile: widget.profile,) // or pass your storage instance
            : ProfileCard(profile: widget.profile, onEdit: toggleEditMode);
      case 1:
        page = Placeholder();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.account_circle_outlined),
                  label: Text('Profile'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.sports_rugby),
                  label: Text('Training Plans'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}
