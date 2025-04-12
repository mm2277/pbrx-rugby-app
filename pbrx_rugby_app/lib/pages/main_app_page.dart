import 'package:flutter/material.dart';
import 'package:pbrx_rugby_app/models/profile.dart';
import 'package:pbrx_rugby_app/models/store_data_locally.dart';
import 'package:pbrx_rugby_app/models/training_plan.dart';
import 'package:pbrx_rugby_app/widgets/create_profile_card.dart';
import 'package:pbrx_rugby_app/widgets/profile_card.dart';
import 'package:pbrx_rugby_app/widgets/training_plan_card.dart';

//Main app page displayed after onboarding unless profile.txt exists 
//allows navigation between profile and training plan sections
class MainAppPage extends StatefulWidget {
  final Profile profile; //users profile passed from onboarding or main_page

  const MainAppPage({super.key, required this.profile});

  @override
  State<MainAppPage> createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage> {
  var selectedIndex = 0; // Track drawer items selected
  bool editing = false; //track if the profile is being edited

  ///toggle between viewing and editing the profile
  void toggleEditMode() {
    setState(() {
      editing = !editing;
    });
  }

  late Future<List<TrainingPlan>> _trainingPlansFuture;

  ///initialises the future for training plan loading
  @override
  void initState() {
    super.initState();
    _trainingPlansFuture = StoreDataLocally().getAllTrainingPlans();
  }

  @override
  Widget build(BuildContext context) {
    Widget page;

    // choose which page based on selectedIndex
    switch (selectedIndex) {
      case 0:
        //profile page 
        page = editing
            ? CreateProfileCard(
                storage: StoreDataLocally(),
                existingProfile: widget.profile,
                title: "Edit Profile",
              )
            : ProfileCard(
                profile: widget.profile,
                onEdit: toggleEditMode,
              );

      case 1:
        // Training plans page
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
        throw UnimplementedError('No widget for $selectedIndex');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('PBRX Rugby'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),

      //Navigation Drawer
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Menu')),
            //navigate to profile page
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text('Profile'),
              onTap: () {
                setState(() => selectedIndex = 0);
                Navigator.pop(context); // Close drawer
              },
            ),
            //navigate to training Plans page
            ListTile(
              leading: const Icon(Icons.sports_rugby),
              title: const Text('Training Plans'),
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                  _trainingPlansFuture =
                      StoreDataLocally().getAllTrainingPlans(); // relaod
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      // Display selected page content
      body: page,
    );
  }
}
