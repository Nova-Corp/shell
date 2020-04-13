import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shell/Chat/ChatListModel.dart';
import 'package:shell/Chat/MessageModel.dart';
import 'package:shell/Service/Auth.dart';
import '../SupportLib/ColorsLib.dart';
import 'package:shell/Conversation/MessageView.dart';

class ConversationView extends StatefulWidget {
  final ChatUserModel user;
  final BuildContext context;
  ConversationView({this.user, this.context});
  final dbReference = FirebaseDatabase.instance.reference();
  final List<MessageModel> message = [];
  @override
  State<StatefulWidget> createState() {
    return _ConversationView();
  }
}

class _ConversationView extends State<ConversationView> {
  final TextEditingController _textEditingController = TextEditingController();
  // StreamSubscription<DataSnapshot> subscription;

  void initState() {
    super.initState();
    widget.dbReference.child("messages").onChildAdded.listen(_onMessageAdded);
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }
  // @override
  // void dispose() {
  //   super.dispose();
  //   // var sub =  widget.dbReference.child("messages").onChildAdded.listen(_onMessageAdded);
  // }

  @override
  Widget build(BuildContext context) {
    void _back() {
      Navigator.pop(context);
    }

    final auth = Provider.of<BaseAuth>(context);
    var user = widget.user;
    return MaterialApp(
        title: "Conversation Page",
        home: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => _back(),
                icon: Icon(Icons.arrow_back),
              ),
              brightness: Brightness.dark,
              backgroundColor: colorFromHex("#2ecc71"),
              title: Text(widget.user.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            body: Container(
                child: Column(
              children: <Widget>[
                Flexible(
                    child: FutureBuilder(
                  future: auth.currentUser(),
                  builder: (context, uidSnap) {
                    return _msgListView(widget.message, uidSnap.data);
                  },
                )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: TextField(
                          controller: _textEditingController,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () => _sendMessage(auth, user),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ))));
  }

  void _onMessageAdded(Event event) {
    // print();
    // print("Message Added");
    var newMsg = event.snapshot.value;
    print(newMsg);

    final auth = Provider.of<BaseAuth>(widget.context);
    auth.currentUser().then((uID) {
      _loadMessages(auth).then((val) {
        print(val);
        print("New");
        _msgListView(val, uID);
        setState(() {});
      });
    });
    // print(event.snapshot.value["message"]);
    // setState(() {message.clear();});
  }

  // void _onMessageUpdated(Event event) {
  //   print("Message Updated");

    // print(event.snapshot.value);
  // }

  Future<List<MessageModel>> _loadMessages(BaseAuth auth) async {
    // message.clear();
    await widget.dbReference
        .child("user-messages")
        .once()
        .then((DataSnapshot snapshot) async {
      var msgRecipient = snapshot.value;
      // var recipientKey = snapshot.value.keys;
      try {
        await auth.currentUser().then((uId) async {
          var allMsgNode = msgRecipient[uId];
          var allMsgNodeKey = allMsgNode.keys;
          // await widget.dbReference
          //     .child("messages")
          //     .once()
          //     .then((DataSnapshot snapshot) async {
            var allMsgs = snapshot.value;
            for (var iKey in allMsgNodeKey) {
              MessageModel msg = MessageModel(
                  allMsgs[iKey]["timeStamp"],
                  allMsgs[iKey]["message"],
                  allMsgs[iKey]["toId"],
                  allMsgs[iKey]["fromId"]);

              await auth.currentUser().then((uId) {
                String partnerId;
                if (allMsgs[iKey]["fromId"] == uId) {
                  partnerId = allMsgs[iKey]["toId"];
                } else {
                  partnerId = allMsgs[iKey]["fromId"];
                }
                if (partnerId == widget.user.uid) {
                  widget.message.add(msg);
                }
              });
            }
          // });
        });
      } catch (err) {
        print(err);
      }
    });
    widget.message.sort((a, b) {
      return a.timeStamp.compareTo(b.timeStamp);
    });
    return widget.message;
  }

  void _sendMessage(BaseAuth auth, ChatUserModel user) {
    String toId = user.uid;
    String message = _textEditingController.text;
    var timeStamp = DateTime.now().millisecondsSinceEpoch;
    var messageNode = widget.dbReference.child("messages").push();
    var userMessageNode = widget.dbReference.child("user-messages");
    final messageId = messageNode.key;

    auth.currentUser().then((fromId) {
      messageNode.set({
        "message": "$message",
        "fromId": fromId,
        "toId": toId,
        "timeStamp": timeStamp
      });

      userMessageNode.child(fromId).update({messageId: 1});
      userMessageNode.child(toId).update({messageId: 1});

      // widget.dbReference.child("messages").onChildAdded.listen(_onMessageAdded);
      // print(widget.messages);
      // widget.dbReference.child("messages").onChildAdded.listen(_onMessageAdded);
      MessageModel msg = MessageModel(timeStamp, message, toId, fromId);
      widget.message.add(msg);
      setState(() {});
    });
    _textEditingController.clear();
  }

  ListView _msgListView(List<MessageModel> messages, String uId) {
    return ListView.separated(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        // print(messages[index].message);
        String type;
        if (uId == messages[index].fromId) {
          type = "s";
        } else {
          type = "r";
        }
        return MessageView(
          message: messages[index].message,
          type: type,
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
  }
}
