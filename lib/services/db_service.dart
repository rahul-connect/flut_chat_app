import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutchatapp/models/contact.dart';
import 'package:flutchatapp/models/conversation.dart';
import 'package:flutchatapp/models/message.dart';


class DBService{
  static DBService instance = DBService();
  Firestore _db;

  DBService(){
    _db = Firestore.instance;
  }

  String _userCollection = "Users";
  String _conversationCollection = "Conversations";

  Future<void> createUserInDB(String _uid,String _name,String _email,String _imageUrl)async{
   
   try{
      return await _db.collection(_userCollection).document(_uid).setData({
      "name":_name,
      "email":_email,
      "image":_imageUrl,
      "lastSeen":DateTime.now().toUtc(),
    });

   }catch(e){
     print(e);
   }
   
   
  }


  Future<void> updateUserLastSeenTime(String _userID){
    var _ref = _db.collection(_userCollection).document(_userID);
    return _ref.updateData({
      "lastSeen":Timestamp.now(),
    });
  }


  Stream<Contact> getUserData(String _userID){
    var _ref = _db.collection(_userCollection).document(_userID);
    return _ref.get().asStream().map((_snapshot){
      return Contact.fromFireStore(_snapshot);
    });
  }

  Stream<List<ConversationSnippet>> getUSerConversation(String _userID){
    var ref = _db.collection(_userCollection).document(_userID).collection(_conversationCollection);
    return ref.snapshots().map((_snapshot) {
      return _snapshot.documents.map((_doc){
        return ConversationSnippet.fromFirestore(_doc);
      }).toList();
    });
  }


  Stream<List<Contact>> getUsersInDB(String _searchName){


    var _ref = _db.collection(_userCollection).where("name",isGreaterThanOrEqualTo: _searchName).where("name",isLessThan: _searchName + 'z');



    return _ref.getDocuments().asStream().map((_snapshot) {
      return _snapshot.documents.map((_doc){
        return Contact.fromFireStore(_doc);
      }).toList();
    });
  }


  Stream<Conversation> getConversation(String _conversationID){
  
    var _ref = _db.collection(_conversationCollection).document(_conversationID);
    return _ref.snapshots().map((_snapshot){
      return Conversation.fromFirestore(_snapshot);
    });
  }


  Future<void> sendMessage(String _conversationID,Message _message){
    var _ref = _db.collection(_conversationCollection).document(_conversationID);
   var _messageType = "";

   switch(_message.type){
     case MessageType.Text:
     _messageType = "text";
     break;
     case MessageType.Image:
     _messageType = "image";
     break;
     default:
   }

    return _ref.updateData({
      "messages":FieldValue.arrayUnion([{
        "message":_message.content,
        "senderID":_message.senderID,
        "timestamp":_message.timestamp,
        "type": _messageType,
      }])
    });
  }



  Future<void> createOrGetConversation(String _currentID,String _receipientID,Future<void> _onSuccess(String _conversationID))async{
    var _ref = _db.collection(_conversationCollection);
    var _userConversationRef = _db.collection(_userCollection).document(_currentID).collection(_conversationCollection);
  try{
    var conversation = await _userConversationRef.document(_receipientID).get();
    if(conversation.data!=null){
      return _onSuccess(conversation.data['conversationID']);
    }else{
      var _conversationRef = _ref.document();
      await _conversationRef.setData({
        "members":[_currentID,_receipientID],
        "ownerID":_currentID,
        "messages":[],

      });
      return _onSuccess(_conversationRef.documentID);
    }
  }catch(e){
    print(e);
  }


  }



}