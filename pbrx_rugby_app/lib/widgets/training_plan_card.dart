import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbrx_rugby_app/models/profile.dart';
import 'package:pbrx_rugby_app/models/training_plan.dart';
import 'package:pbrx_rugby_app/models/store_data_locally.dart';
import 'package:pbrx_rugby_app/models/training_plan_generator.dart';

class TrainingPlanCard extends StatefulWidget {
  final List<TrainingPlan> trainingPlans;
  final StoreDataLocally storage;
  final Profile profile;

  const TrainingPlanCard({
    super.key,
    required this.trainingPlans,
    required this.storage,
    required this.profile,
  });

  @override
  State<TrainingPlanCard> createState() => _TrainingPlanCardState();
}

class _TrainingPlanCardState extends State<TrainingPlanCard> {
  late List<TrainingPlan> sortedPlans;
  final Map<int, bool> _expanded = {};
  final Map<int, bool> _checked = {};

  @override
  void initState() {
    super.initState();
    sortedPlans = List.from(widget.trainingPlans)
      ..sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
    for (int i = 0; i < sortedPlans.length; i++) {
      _expanded[i] = i == 0; // Current plan expanded by default
      _checked[i] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generating training plan...')),
              );

              final generator =
                  TrainingPlanGenerator(openAiKey: 'YOUR_API_KEY_HERE');
              final newPlan = await generator.generatePlanFromProfile(
                  widget.profile); // <-- use passed-in profile

              if (newPlan != null) {
                await widget.storage.writeTrainingPlan(newPlan);

                setState(() {
                  // Refresh the plans list
                  sortedPlans.insert(0, newPlan); // Add new plan at top
                  _expanded[0] = true;
                  _checked[0] = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Training plan created!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to generate plan')),
                );
              }
            },
            child: const Text('New Plan'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: sortedPlans.length,
              itemBuilder: (context, index) {
                final plan = sortedPlans[index];
                final isCurrent = index == 0;
                final title =
                    isCurrent ? 'Current Workout' : 'Past Workout ${index}';
                final formattedDate =
                    DateFormat('yyyy-MM-dd').format(plan.dateCreated);

                return Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(title,
                                style: Theme.of(context).textTheme.titleMedium),
                            const Spacer(),
                            Checkbox(
                              value: _checked[index],
                              onChanged: (val) => setState(
                                  () => _checked[index] = val ?? false),
                            ),
                            IconButton(
                                icon: Icon(_expanded[index] == true
                                    ? Icons.expand_less
                                    : Icons.expand_more),
                                onPressed: () => setState(() =>
                                    _expanded[index] = !_expanded[index]!)),
                          ],
                        ),
                        if (_expanded[index] == true) ...[
                          const Divider(),
                          for (int weekIndex = 0;
                              weekIndex < plan.weeklyPlans.length;
                              weekIndex++)
                            for (int day = 0; day < 7; day++)
                              for (int session = 0;
                                  session <
                                      plan.weeklyPlans[weekIndex].days[day]
                                          .length;
                                  session++)
                                Text(
                                  'Day ${day + 1}, Session ${session + 1}: do plan',
                                  style: const TextStyle(fontSize: 14),
                                ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text('Regenerate'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  // remove and update UI
                                  setState(() {
                                    sortedPlans.removeAt(index);
                                    _expanded.remove(index);
                                    _checked.remove(index);
                                  });
                                  // delete from file if needed
                                  await widget.storage.deleteTrainingPlanFile();
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                          Text('Date Created: $formattedDate',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
