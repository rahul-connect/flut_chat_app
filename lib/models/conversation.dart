import 'package:cloud_firestore/cloud_firestore.dart';

import 'message.dart';


class ConversationSnippet{
  final String id;
  final String conversationID;
  final String lastMessage;
  final String name;
  final String image;
  final MessageType type;
  final int unseenCount;
  final Timestamp timestamp;

  ConversationSnippet({this.id, this.conversationID, this.lastMessage, this.name, this.image, this.type,this.unseenCount, this.timestamp});
  
  factory ConversationSnippet.fromFirestore(DocumentSnapshot _snapshot){
    var _data = _snapshot.data;
    var _messageType = MessageType.Text;
    if(_data['type']!=null){
        switch(_data['type']){
          case "text":
          break;

          case "image":
          _messageType = MessageType.Image;
          break;
          default:
        }
    }
    return ConversationSnippet(
      id: _snapshot.documentID,
      conversationID: _data['chatID'],
      lastMessage: _data['lastMessage'] != null ? _data['lastMessage']:'',
      unseenCount: _data['unseenCount'],
      timestamp: _data['timestamp'] != null ?_data['timestamp']:null,
      name: _data['name'],
      image: _data['image'],
      type:_messageType
    );
  
  }
}




class Conversation{
  final String id;
  final List members;
  final List<Message> messages;
  final String ownerID;

  Conversation({this.id, this.members, this.messages, this.ownerID});


  factory Conversation.fromFirestore(DocumentSnapshot snapshot){
    var data = snapshot.data;
    List _messages = data['messages'];
    if(_messages != null){
      _messages = _messages.map((_m){
        return Message(
          senderID: _m['senderID'],
          content: _m['message'],
          timestamp: _m['timestamp'],
          type: _m['type']=="text"?MessageType.Text:MessageType.Image,

        );
      }).toList();
    }else{
      _messages = null;
    }
    return Conversation(
      id: snapshot.documentID,
      members: data['members'],
      ownerID: data['ownerID'],
      messages: _messages,

    );
  }
  
}