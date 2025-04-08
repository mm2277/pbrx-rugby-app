import 'package:flutter/material.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:pbrx_rugby_app/models/profile.dart';

class CreateProfileCard extends StatefulWidget {
  CreateProfileCard({super.key,});

  @override
  State<CreateProfileCard> createState() => _CreateProfileCardState();
}

class _CreateProfileCardState extends State<CreateProfileCard>  {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final MultiSelectController<String> _skillsController = MultiSelectController(
    deSelectPerpetualSelectedItems: true
  );

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
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
        children: [Text(
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
                label: Text(
                  'Enter your name',
                  textAlign: TextAlign.center,
                    style: TextStyle(
                      //color: Theme.of(context).colorScheme.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    )
                  ),
              ),
              controller: _nameController,
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                } //TODO: add else if for other validation
                return null;
              },
            ),
          ),

          //Dropdown menu for positions
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: DropdownButtonFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text(
                  'Select your position',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    //color: Theme.of(context).colorScheme.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  )
                ),
              ),
              items: Position.values.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text(
                    p.name, 
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    )
                ),
                  );
              }).toList(), 
              onChanged: (value) {
                //TODO save value locally
              } ,
              validator: (value) {
                if (value == null) {
                  return 'Please select a value';
                } 
                return null;
              },

              ),
          ),

          //multiselect box for skills
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [ Text(
              "Select your skills",
              textAlign: TextAlign.left,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                )),
              MultiSelectContainer(
                itemsDecoration: MultiSelectDecorations(
                    
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.secondary),
                      borderRadius: BorderRadius.circular(20)
                    ),
              
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    
                  ),
                items: Skills.values.map((p) {
                    return MultiSelectCard(
                      value: p,
                      child: Text(
                        p.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                        )
                      ),
                    );
                  }).toList(),  onChange: (allSelectedItems, selectedItem) {}
              ),
            ],
          ),

          //Creating Profile Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. 
                  //TODO save data locally
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Creating Profile')),
                  );
                  //TODO go to home page
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
