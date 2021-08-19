import 'package:amra/widgets/header.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  TextEditingController usernameController = TextEditingController();

  submitUsername(context) {
    if (!usernameController.text.isEmpty) {
      Navigator.pop(context, usernameController.text);
    } else {
      var snackbar = SnackBar(
          content: Text(
        'Provide Username',
        style: TextStyle(fontSize: 18, color: Colors.red[300]),
      ));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  Scaffold build(BuildContext parentContext) {
    return Scaffold(
      appBar: header(
        context,
        title: "Setup Profile",
        isAppTitle: false,
      ),
      body: ListView(
        children: [
          Container(
            child: Column(
              children: [
                SizedBox(
                  height: 25,
                ),
                Center(
                  child: Text(
                    'Create a username',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Username',
                      labelStyle: TextStyle(fontSize: 16),
                      hintText: 'Must be at least 3 charecters',
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => submitUsername(context),
                  child: Container(
                    height: 50,
                    width: 350,
                    decoration: BoxDecoration(
                      color: Colors.red[300],
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Center(
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
