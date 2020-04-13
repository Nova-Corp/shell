import 'package:flutter/material.dart';

import 'SupportLib/ColorsLib.dart';

class CreateAccount extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateAccount();
  }
}

class _CreateAccount extends State<CreateAccount> {
  final formKey = GlobalKey<FormState>();
  String _email, _password;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Create Account",
      home: Scaffold(
        appBar: AppBar(
          title: Text("Create Account"),
        ),
        body: Container(
          color: colorFromHex("#e0e0e0"),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Form(
                      key: formKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(8)),
                            child: TextFormField(
                              validator: (input) =>
                                  !input.contains("@") ? "Not valid email" : null,
                              onSaved: (input) => _email = input,
                              decoration: InputDecoration(
                                  labelText: 'Enter your email',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(20)),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(8)),
                            child: TextFormField(
                              validator: (input) => input.length < 8
                                  ? "Please enter 8 digit password"
                                  : null,
                              obscureText: true,
                              onSaved: (input) => _password = input,
                              decoration: InputDecoration(
                                  labelText: 'Enter your password',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(20)),
                            ),
                          ),
                          MaterialButton(
                            onPressed: () => _submit(),
                            color: Colors.blueAccent,
                            child: Text(
                              "Sign Up",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  void _submit() async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      
    }
  }
}
