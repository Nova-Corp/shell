import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shell/Chat/NewChat.dart';
import 'package:shell/Service/Auth.dart';
import 'package:shell/Chat/ChatListModel.dart';
import 'package:shell/Conversation/ConversationView.dart';
import 'package:shell/SupportLib/ColorsLib.dart';

class ChatList extends StatefulWidget {
  final dbReference = FirebaseDatabase.instance.reference();
  @override
  State<StatefulWidget> createState() {
    return _ChatList();
  }
}

class _ChatList extends State<ChatList> {
  StreamSubscription<Event> subscription;
  List<ChatUserModel> user = [];
  @override
  Widget build(BuildContext context) {
    BaseAuth auth = Provider.of<BaseAuth>(context);
    return MaterialApp(
      title: "Chat View",
      home: Scaffold(
          appBar: AppBar(
            brightness: Brightness.dark,
            backgroundColor: colorFromHex("#2ecc71"),
            title: Text("Chat"),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add_comment),
                onPressed: () => _gotoNewChat(context),
              ),
              IconButton(
                icon: Icon(Icons.power_settings_new),
                onPressed: () => _signOut(context),
              )
            ],
          ),
          body: Container(
            child: FutureBuilder(
              future: _getMessageList(auth),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _chatListView(snapshot.data);
                } else if (snapshot.hasError) {
                  return Text(snapshot.error);
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.blue[800]),
                    ),
                  );
                }
              },
            ),
          )),
    );
  }

  Future<List<ChatUserModel>> _getMessageList(BaseAuth auth) async {
    var messageNode = widget.dbReference.child("messages");
    var userNode = widget.dbReference.child("users");
    var userMessageNode = widget.dbReference.child("user-messages");
    // rEXoRxgyY7ZzMBQN4nWes7GJbO63
    try {
      await messageNode.once().then((DataSnapshot messageSnap) async {
        // var messageKeys = messageSnap.value.keys;
        var msgData = messageSnap.value;

        await auth.currentUser().then((uid) async {
          try {
            await userMessageNode.once().then((DataSnapshot userMsgSnap) async {
              var userMsgValue = userMsgSnap.value;
              var userMsgKeys = userMsgValue[uid].keys;

              // for (var userMsgKey in userMsgKeys){
              //   print(msgData[userMsgKey]);
              // }
              for (var individualKey in userMsgKeys) {
                // print(messageKeys);
                await userNode.once().then((DataSnapshot userSnap) {
                  var userData = userSnap.value;
                  final ChatUserModel chatList = ChatUserModel(
                      userData[msgData[individualKey]["toId"]]["email"],
                      userData[msgData[individualKey]["toId"]]["name"],
                      userData[msgData[individualKey]["toId"]]["profileImage"],
                      msgData[individualKey]["toId"],
                      msgData[individualKey]["message"],
                      msgData[individualKey]["timeStamp"]);
                  for (var obj in user) {
                    if ((obj.uid.contains(msgData[individualKey]["toId"])) ||
                        (msgData[individualKey]["toId"] == uid)) {
                      // print("contains");
                      return;
                    }
                  }
                  user.add(chatList);
                });
              }
            });
          } catch (err) {
            print("ERROR: $err");
          }
        });
      });
    } catch (err) {
      print(err);
    }
    user.sort((a, b) {
      return a.timeStamp.compareTo(b.timeStamp);
    });
    return user;
  }

  ListView _chatListView(List<ChatUserModel> chat) {
    return ListView.separated(
      itemCount: chat.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(chat[index].name),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(chat[index].profileImage),
          ),
          subtitle: Text(chat[index].message),
          trailing: Icon(
            Icons.notification_important,
            color: Colors.green,
          ),
          onTap: () => _gotoConversation(context, chat[index]),
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final BaseAuth auth = Provider.of<BaseAuth>(context);
      await auth.signOut();
    } catch (e) {
      print("ERROR: $e");
    }
  }

  void _gotoNewChat(BuildContext context) {
    Navigator.of(context).push(CupertinoPageRoute(
        fullscreenDialog: true, builder: (context) => NewChat()));
  }

  void _gotoConversation(BuildContext context, ChatUserModel user) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ConversationView(user: user, context: context);
    }));
  }
}
