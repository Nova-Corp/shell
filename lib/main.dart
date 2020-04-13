import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shell/Service/Auth.dart';
import 'RootPage.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<BaseAuth>(
          builder: (_) => Auth(),
        )
      ],
      child: MaterialApp(
        home: RootPage(),
      ),
    );
  }
}
