import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pbrx_rugby_app/models/profile.dart';
import 'package:pbrx_rugby_app/models/store_data_locally.dart';
import 'package:pbrx_rugby_app/models/training_plan.dart';
import 'package:pbrx_rugby_app/widgets/create_profile_card.dart';
import 'package:pbrx_rugby_app/widgets/profile_card.dart';
import 'package:pbrx_rugby_app/widgets/training_plan_card.dart';

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

  late Future<List<TrainingPlan>> _trainingPlansFuture;

  @override
  void initState() {
    super.initState();
    _trainingPlansFuture = StoreDataLocally().getAllTrainingPlans();
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = editing
            ? CreateProfileCard(
                storage: StoreDataLocally(),
                existingProfile: widget.profile,
              ) // or pass your storage instance
            : ProfileCard(profile: widget.profile, onEdit: toggleEditMode);
      case 1:
        page = FutureBuilder<List<TrainingPlan>>(
          future: _trainingPlansFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final allPlans = snapshot.data ?? [];
              return TrainingPlanCard(
                trainingPlans: allPlans,
                storage: StoreDataLocally(),
                profile: widget.profile,
              );
            }
          },
        );
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

                  if (value == 1) {
                    // Tab 1 = Training Plans → refresh!
                    _trainingPlansFuture =
                        StoreDataLocally().getAllTrainingPlans();
                  }
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
