import 'package:brew_crew/models/user.dart';
import 'package:brew_crew/services/database.dart';
import 'package:brew_crew/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:brew_crew/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({Key? key}) : super(key: key);

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {

  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0', '1', '2', '3', '4'];

  String? _currentName;
  String? _currentSugars;
  int? _currentStrength;

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData? userData = snapshot.data;
          return Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                const Text(
                  'Update your brew settings.',
                  style: TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 20.0,),
                TextFormField(
                  initialValue: userData?.name,
                  decoration: textInputDecoration,
                  validator: (val) => val == null || val.isEmpty ? 'Please enter a name' : null,
                  onChanged: (val) => setState(() => _currentName = val),
                ),
                const SizedBox(height: 20.0,),
                // dropdown
                DropdownButtonFormField(
                  decoration: textInputDecoration,
                  value: _currentSugars ?? userData?.sugars,
                  items: sugars.map((sugar) {
                    return DropdownMenuItem(
                      value: sugar,
                      child: Text('$sugar sugars'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _currentSugars = val),
                ),
                Slider(
                  value: (_currentStrength ?? userData?.strength ?? 100).toDouble(),
                  activeColor: Colors.brown[_currentStrength ?? userData?.strength ?? 100],
                  inactiveColor: Colors.brown[_currentStrength ?? userData?.strength ?? 100],
                  min: 100.0,
                  max: 900.0,
                  divisions: 8,
                  onChanged: (val) => setState(() => _currentStrength = val.round()),
                ),
                // slider
                ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll<Color>(Colors.pink),
                  ),
                  child: const Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    if(_formKey.currentState!.validate()) {
                      await DatabaseService(uid: user.uid).updateUserData(
                        _currentSugars ?? userData!.sugars!,
                        _currentName ?? userData!.name!,
                        _currentStrength ?? userData!.strength!
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          );
        } else {
          return const Loading();
        }

      }
    );
  }
}
