import 'package:flutter/material.dart';

class MessageView extends StatelessWidget {
  final String type;
  final String message;
  MessageView({this.type, this.message});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: type == "s"? MainAxisAlignment.end: MainAxisAlignment.start,
      children: <Widget>[
        Card(
          elevation: 8,
          color: Colors.green,
          child: Padding(
            padding: EdgeInsets.all(7.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  width: 300,
                  child: Text(message),
                ),
                Text('17:00'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
