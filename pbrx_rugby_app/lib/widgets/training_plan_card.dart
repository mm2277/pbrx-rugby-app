// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:pbrx_rugby_app/models/profile.dart';
import 'package:pbrx_rugby_app/models/training_plan.dart';
import 'package:pbrx_rugby_app/models/store_data_locally.dart';
import 'package:pbrx_rugby_app/models/training_plan_generator.dart';

///Widget that displays and manages training plans for a given profile.
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
  final Map<int, bool> _expanded = {}; // track all expanedd or not expanded states
  final Map<int, bool> _checked = {}; // track completion states
  final key = dotenv.env['GOOGLE_GEMINI_API_KEY']; // AI API key

  /// init and sort training plans on widget load
  @override
  void initState() {
    super.initState();
    sortedPlans = List.from(widget.trainingPlans)
      ..sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
    for (int i = 0; i < sortedPlans.length; i++) {
      _expanded[i] = i == 0; //expand the most recent plan
      _checked[i] = sortedPlans[i].isCompleted;
    }
  }

  ///shows dialog to collect new plan settings for duration and saeson
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
              // duration input
              TextField(
                decoration:
                    const InputDecoration(labelText: 'Duration (weeks)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => weeks = int.tryParse(val) ?? 4,
              ),
              // season selection
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, {'weeks': weeks, 'season': season}),
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );

    await _generatePlan(result);
  }

  //generates a new plan 
  Future<void> _generatePlan(Map<String, dynamic>? result) async {
    if (result == null || key == null) return;

    final weeks = result['weeks'] as int;
    final season = result['season'] as String;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating training plan...')),
    );

    final generator = TrainingPlanGenerator(googleApiKey: key!);
    final newPlan = await generator.generatePlanFromProfile(
      widget.profile,
      weeksDuration: weeks,
      season: season,
    );

    if (newPlan != null) {
      final updatedPlan = TrainingPlan(
        weeksDuration: newPlan.weeksDuration,
        season: newPlan.season,
        weeklyPlans: newPlan.weeklyPlans,
        dateCreated: DateTime.now(),
        completed: false,
      );

      await widget.storage.writeTrainingPlan(updatedPlan);

      setState(() {
        sortedPlans.insert(0, updatedPlan);
        _expanded.clear();
        _checked.clear();
        for (int i = 0; i < sortedPlans.length; i++) {
          _expanded[i] = i == 0;
          _checked[i] = sortedPlans[i].isCompleted;
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

  // Builds a list of exercises for warm-up OR main-workout
  Widget _buildExerciseList(List exercises) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: exercises.map<Widget>((exercise) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                  '• ${exercise.name}: ${exercise.sets} sets of ${exercise.reps} reps'),
            ),
            if (exercise.description?.isNotEmpty == true)
              Tooltip(
                message: exercise.description!,
                child: const Icon(Icons.info_outline, size: 16),
              ),
          ],
        );
      }).toList(),
    );
  }

  // Builds the full view for each weekly plan including exercises
  Widget _buildPlanDetails(TrainingPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(plan.weeklyPlans.length, (weekIndex) {
        final week = plan.weeklyPlans[weekIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Week ${weekIndex + 1}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            // daily sessions
            for (int day = 0; day < 7; day++)
              for (int session = 0;
                  session < week.days[day].length;
                  session++) ...[
                const SizedBox(height: 12),
                Text(
                  'Day ${day + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Text(
                  'Session ${session + 1}: ${week.days[day][session].type.name} '
                  '[${week.days[day][session].durationMins} mins]',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                const Text('Warm-Up:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: _buildExerciseList(week.days[day][session].warmup),
                ),
                const SizedBox(height: 6),
                const Text('Workout:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child:
                      _buildExerciseList(week.days[day][session].mainWorkout),
                ),
              ],
          ],
        );
      }),
    );
  }

  // Builds the complete widget
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // generate new plan button
          ElevatedButton(
            onPressed: _handleNewPlanGeneration,
            child: const Text('New Plan'),
          ),
          const SizedBox(height: 16),

          // training Plan cards list
          Expanded(
            child: ListView.builder(
              itemCount: sortedPlans.length,
              itemBuilder: (context, index) {
                final plan = sortedPlans[index];
                final isCurrent = index == 0;
                final formattedDate =
                    DateFormat('yyyy-MM-dd').format(plan.dateCreated);

                return Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // title + checkbox + expand
                        Row(
                          children: [
                            Text(
                              isCurrent
                                  ? 'Current Workout'
                                  : 'Past Workout $index',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            Checkbox(
                              value: _checked[index] ?? false,
                              onChanged: (val) async {
                                final checked = val ?? false;
                                setState(() {
                                  _checked[index] = checked;
                                  sortedPlans[index].setCompleted(checked);
                                });
                                await widget.storage
                                    .writeTrainingPlan(sortedPlans[index]);
                              },
                            ),
                            IconButton(
                              icon: Icon(_expanded[index] == true
                                  ? Icons.expand_less
                                  : Icons.expand_more),
                              onPressed: () => setState(() => _expanded[index] =
                                  !(_expanded[index] ?? false)),
                            ),
                          ],
                        ),

                        // expand details
                        if (_expanded[index] == true) ...[
                          const Divider(),
                          _buildPlanDetails(plan),
                          const SizedBox(height: 8),
                          //butons for regenerate and delete
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => _generatePlan({
                                  'weeks': plan.weeksDuration,
                                  'season': plan.season.name,
                                }),
                                child: const Text('Regenerate'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    sortedPlans.removeAt(index);
                                    _expanded.remove(index);
                                    _checked.remove(index);
                                  });
                                  await widget.storage.deleteTrainingPlanFile();
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                          // date created
                          Text('Date Created: $formattedDate',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
