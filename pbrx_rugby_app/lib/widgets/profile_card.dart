import 'package:flutter/material.dart';
import 'package:pbrx_rugby_app/models/profile.dart';
import 'package:pbrx_rugby_app/models/store_data_locally.dart';
import 'package:pbrx_rugby_app/widgets/create_profile_card.dart';

class ProfileCard extends StatefulWidget {
  final Profile profile;
  final VoidCallback onEdit;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.onEdit,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height*0.8,
      width: MediaQuery.sizeOf(context).width, 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Padding(
            padding: EdgeInsets.all(50.0),
            child: Icon(
              Icons.account_circle_outlined,  
              size: 80,
              ),
          ),


          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Name",
              ),
              Text(
                widget.profile.safeName
              )
            ],
          ),


          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Position",
              ),
              Text(
                widget.profile.safePosition
              )
            ],
          ),


          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Skills",
              ),
              Text(
                widget.profile.safeSkills
              )
            ],
          ),

          ElevatedButton(
            onPressed: widget.onEdit,
 
            child: Text('Edit Profile')
          ),
        ],
      ),
    );
  }
}