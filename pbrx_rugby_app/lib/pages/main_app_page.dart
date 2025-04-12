import 'package:flutter/material.dart';
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
                title: "Edit Profile",
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
      appBar: AppBar(
        title: Text('PBRX Rugby'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text('Menu')),
            ListTile(
              leading: Icon(Icons.account_circle_outlined),
              title: Text('Profile'),
              onTap: () {
                setState(() => selectedIndex = 0);
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.sports_rugby),
              title: Text('Training Plans'),
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                  _trainingPlansFuture =
                      StoreDataLocally().getAllTrainingPlans();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: page,
    );
  }
}
