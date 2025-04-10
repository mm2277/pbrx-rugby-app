// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  final key = dotenv.env['GOOGLE_GEMINI_API_KEY'];

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

  Future<void> _handleNewPlanGeneration() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        int weeks = 4;
        String season = 'inSeason';

        return AlertDialog(
          title: const Text('New Training Plan Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration:
                    const InputDecoration(labelText: 'Duration (weeks)'),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  weeks = int.tryParse(val) ?? 4;
                },
              ),
              DropdownButtonFormField<String>(
                value: season,
                items: const [
                  DropdownMenuItem(value: 'inSeason', child: Text('In Season')),
                  DropdownMenuItem(
                      value: 'outSeason', child: Text('Out Season')),
                ],
                onChanged: (val) => season = val ?? 'inSeason',
                decoration: const InputDecoration(labelText: 'Season'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, {
                      'weeks': weeks,
                      'season': season,
                    }),
                child: const Text('Generate')),
          ],
        );
      },
    );

    await _generatePlan(result);
  }

  Future<void> _generatePlan(Map<String, dynamic>? result) async {
    if (result == null) return;

    final weeks = result['weeks'] as int;
    final season = result['season'] as String;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating training plan...')),
    );

    if (key == null) {
      throw Exception("Google Gemini API key not found in .env file");
    }

    final generator = TrainingPlanGenerator(googleApiKey: key!);
    final newPlan = await generator.generatePlanFromProfile(
      widget.profile,
      weeksDuration: weeks,
      season: season,
    );

    if (newPlan != null) {
      await widget.storage.writeTrainingPlan(newPlan);

      setState(() {
        sortedPlans.insert(0, newPlan);
        _expanded.clear();
        _checked.clear();
        for (int i = 0; i < sortedPlans.length; i++) {
          _expanded[i] = i == 0;
          _checked[i] = false;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Training plan created!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate plan')),
      );
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
            onPressed: _handleNewPlanGeneration,
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
                    isCurrent ? 'Current Workout' : 'Past Workout $index';
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
                              value:
                                  _checked[index] ?? false, // fallback to false
                              onChanged: (val) => setState(
                                  () => _checked[index] = val ?? false),
                            ),
                            IconButton(
                                icon: Icon(_expanded[index] == true
                                    ? Icons.expand_less
                                    : Icons.expand_more),
                                onPressed: () => setState(() =>
                                    _expanded[index] =
                                        !(_expanded[index] ?? false))),
                          ],
                        ),
                        if (_expanded[index] == true) ...[
                          const Divider(),
                          for (int weekIndex = 0;
                              weekIndex < plan.weeklyPlans.length;
                              weekIndex++) ...[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('Week ${weekIndex + 1}',
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                            ),
                            for (int day = 0; day < 7; day++)
                              for (int session = 0;
                                  session <
                                      plan.weeklyPlans[weekIndex].days[day]
                                          .length;
                                  session++) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Day ${day + 1}',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  'Session ${session + 1}: ${plan.weeklyPlans[weekIndex].days[day][session].type.name}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Warm-Up:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: plan.weeklyPlans[weekIndex]
                                        .days[day][session].warmup
                                        .map((exercise) {
                                      return Text(
                                          '• ${exercise.name} (${exercise.sets}x${exercise.reps})');
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Workout:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: plan.weeklyPlans[weekIndex]
                                        .days[day][session].mainWorkout
                                        .map((exercise) {
                                      return Text(
                                          '• ${exercise.name} (${exercise.sets}x${exercise.reps})');
                                    }).toList(),
                                  ),
                                ),
                              ],
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  final plan = sortedPlans[index];
                                  final weeks = plan.weeksDuration;
                                  final season = plan
                                      .season.name; // converts enum to string

                                  _generatePlan(
                                      {'weeks': weeks, 'season': season});
                                },
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
