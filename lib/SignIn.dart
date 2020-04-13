import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shell/Service/Auth.dart';
import 'package:shell/CreateAccount.dart';
import 'package:shell/SupportLib/HorizontalLine.dart';
import 'SupportLib/ColorsLib.dart';

class SignIn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SignIn();
  }
}

class _SignIn extends State<SignIn> {
  final formKey = GlobalKey<FormState>();
  String _email, _password;
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<BaseAuth>(context);
    return MaterialApp(
        title: "Chat View",
        home: Scaffold(
            appBar: AppBar(
                brightness: Brightness.dark,
                backgroundColor: colorFromHex("#2ecc71"),
                title: Text("Sign In")),
            body: Container(
                color: colorFromHex("#f0f0f0"),
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
                                  validator: (input) => !input.contains("@")
                                      ? "Not valid email"
                                      : null,
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
                                onPressed: () => _submit(auth),
                                color: Colors.blueAccent,
                                child: Text(
                                  "Login",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Builder(
                            builder: (context) => FlatButton(
                                  onPressed: () => _goToCreateAccount(context),
                                  child: Text("Create an account here"),
                                )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CustomPaint(
                              painter: Drawhorizontalline(true, 100.0),
                            ),
                            Text("Or"),
                            CustomPaint(
                              painter: Drawhorizontalline(false, 100.0),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                height: 54,
                                width: 54,
                                child: Builder(
                                  builder: (context) => MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(27)),
                                    color: Colors.white,
                                    onPressed: () {
                                      try {
                                        auth.signInWithGoogle();
                                      } catch (err){
                                        print("$err");
                                      }
                                    },
                                    child: Image.asset(
                                      "asset/go-logo.png",
                                    ),
                                  ),
                                )),
                            SizedBox(
                              width: 12,
                            ),
                            Container(
                                height: 54,
                                width: 54,
                                child: Builder(
                                  builder: (context) => MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(27)),
                                    color: colorFromHex("#4266b2"),
                                    onPressed: () => auth.signInWithFacebook(),
                                    child: Image.asset(
                                      "asset/fb-logo.png",
                                    ),
                                  ),
                                )),
                          ],
                        )
                      ],
                    ),
                  )),
                ))));
  }

  void _goToCreateAccount(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CreateAccount()));
  }

  void _submit(BaseAuth auth) async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      try {
        await auth.signInWithEmailAndPassword(_email, _password);
      } catch (err) {
        print("Error: $err");
      }
    }
  }
}
