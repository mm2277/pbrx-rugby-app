import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:pbrx_rugby_app/models/profile.dart';
import 'package:pbrx_rugby_app/models/store_data_locally.dart';
import 'package:pbrx_rugby_app/pages/main_app_page.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class CreateProfileCard extends StatefulWidget {
  final StoreDataLocally storage;
  final Profile? existingProfile;
  final String title;

  const CreateProfileCard({
    super.key,
    required this.storage,
    this.existingProfile,
    required this.title,
  });

  @override
  State<CreateProfileCard> createState() => _CreateProfileCardState();
}

class _CreateProfileCardState extends State<CreateProfileCard> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  List<Skills> _selectedSkills = [];
  late List<DropdownItem<Skills>> _dropdownItems;
  late Profile _profile;

  final EdgeInsets _fieldPadding = const EdgeInsets.all(15.0);
  final TextStyle _labelStyle =
      const TextStyle(fontSize: 15, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();

    _profile = widget.existingProfile ??
        Profile(name: "", position: Position.back, skills: []);
    _nameController.text = _profile.safeName;

    _dropdownItems = Skills.values
        .map((s) => DropdownItem<Skills>(value: s, label: s.name))
        .toList();

    _selectedSkills = _profile.safeSkillsList;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Name Input
          Padding(
            padding: _fieldPadding,
            child: TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                label: Text('Enter your name', style: _labelStyle),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
          ),

          // Ability Dropdown
          Padding(
            padding: _fieldPadding,
            child: DropdownButtonFormField<Ability>(
              value: _profile.ability,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                label: Text('Select your ability', style: _labelStyle),
              ),
              items: Ability.values.map((ability) {
                return DropdownMenuItem(
                  value: ability,
                  child: Text(
                    ability.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                _profile.setAbility(value!);
              },
              validator: (value) =>
                  value == null ? 'Please select an ability' : null,
            ),
          ),

          // Position Dropdown
          Padding(
            padding: _fieldPadding,
            child: DropdownButtonFormField<Position>(
              value: widget.existingProfile != null ? _profile.position : null,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                label: Text('Select your position', style: _labelStyle),
              ),
              items: Position.values.map((position) {
                return DropdownMenuItem(
                  value: position,
                  child: Text(
                    position.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                _profile.setPosition(value!);
              },
              validator: (value) =>
                  value == null ? 'Please select a position' : null,
            ),
          ),

          // Skills MultiDropdown
          Padding(
              padding: _fieldPadding,
              child: MultiSelectDialogField<Skills>(
                items: _dropdownItems
                    .map((item) =>
                        MultiSelectItem<Skills>(item.value, item.label))
                    .toList(),
                initialValue: _selectedSkills,
                title: const Text("Skills"),
                selectedColor: Theme.of(context).colorScheme.primary,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                buttonIcon: const Icon(Icons.arrow_drop_down),
                buttonText: Text(
                  "Select your skills",
                  style: _labelStyle.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                onConfirm: (selected) {
                  _selectedSkills = selected;
                },
                chipDisplay: MultiSelectChipDisplay(
                  textStyle: const TextStyle(fontSize: 14),
                  chipColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              )),

          // Submit Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: _handleSubmit,
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _profile.setName(_nameController.text);
        _profile.setSkills(_selectedSkills);
      });

      widget.storage.writeProfile(_profile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saving Profile')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainAppPage(profile: _profile),
        ),
      );
    }
  }
}
