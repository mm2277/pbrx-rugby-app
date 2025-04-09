import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:pbrx_rugby_app/models/profile.dart';
import 'package:pbrx_rugby_app/models/store_data_locally.dart';
import 'package:pbrx_rugby_app/pages/main_app_page.dart';

class CreateProfileCard extends StatefulWidget {
  final StoreDataLocally storage;
  final Profile? existingProfile;

  const CreateProfileCard({
    super.key,
    required this.storage,
    this.existingProfile,
  });

  @override
  State<CreateProfileCard> createState() => _CreateProfileCardState();
}

class _CreateProfileCardState extends State<CreateProfileCard> {
  final _formKey = GlobalKey<FormState>();

  //input controllers
  final _nameController = TextEditingController();
  final MultiSelectController<Skills> _skillController =
      MultiSelectController<Skills>();
  List<DropdownItem<Skills>> _dropdownItems = [];

  //final varibales to temporarily move data
  late Profile _profile;

  @override
  void initState() {
    super.initState();

    // Use existing profile if passed in
    _profile = widget.existingProfile ??
        Profile(name: "", position: Position.back, skills: []);

    _nameController.text = _profile.safeName;

    // Build dropdown items
    _dropdownItems = Skills.values
        .map((s) => DropdownItem<Skills>(value: s, label: s.name))
        .toList();

    // Set items on controller
    _skillController.setItems(_dropdownItems);

    // 💥 Select items AFTER setting them
    _skillController
        .selectWhere((item) => _profile.safeSkillsList.contains(item.value));
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _skillController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Create your profile below",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          //Textbox feild for name
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text('Enter your name',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      //color: Theme.of(context).colorScheme.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              controller: _nameController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
          ),

          //Dropdown menu for positions
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: DropdownButtonFormField(
              value: _profile.position,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text('Select your position',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      //color: Theme.of(context).colorScheme.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              items: Position.values.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text(p.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      )),
                );
              }).toList(),
              onChanged: (value) {
                _profile.setPosition(value!);
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a value';
                }
                return null;
              },
            ),
          ),

          //multiselect box for skills
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: MultiDropdown(
              controller: _skillController,
              fieldDecoration: FieldDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Select your skills",
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  )),
              chipDecoration: ChipDecoration(),
              dropdownItemDecoration: DropdownItemDecoration(
                textColor: Theme.of(context).colorScheme.secondary,
                //backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              items: Skills.values.map((p) {
                return DropdownItem(value: p, label: p.name);
              }).toList(),
            ),
          ),

          //Creating Profile Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar.
                  setState(() {
                    _profile.setName(_nameController.text);
                    //_profile.setPosition(_positionSelected);
                    _profile.setSkills(_skillController.selectedItems
                        .map((item) => item.value)
                        .toList());
                  });

                  //saving data to storage
                  widget.storage.writeProfile(_profile);
                  //this read is only for testing purposes
                  widget.storage.readProfile().then((value) {
                    print(value);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Creating Profile')),
                  );

                  //navigating to home page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainAppPage(
                        profile: _profile ??
                            Profile(
                                name: "", position: Position.back, skills: []),
                      ),
                    ),
                  );
                }
              },
              child: const Text('Create Profile'),
            ),
          ),
        ],
      ),
    );
  }
}
