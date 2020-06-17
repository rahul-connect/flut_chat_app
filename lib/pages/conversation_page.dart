import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutchatapp/models/conversation.dart';
import 'package:flutchatapp/models/message.dart';
import 'package:flutchatapp/services/cloud_storage_service.dart';
import 'package:flutchatapp/services/media_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/db_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ConversationPage extends StatefulWidget {
  String conversationID;
  String receiverID;
  String receiverImage;
  String receiverName;

  ConversationPage({
    this.conversationID,
    this.receiverID,
    this.receiverImage,
    this.receiverName
  });

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  double _deviceHeight;
  double _deviceWidth;
  String _messageText;

  AuthProvider _auth;

  GlobalKey<FormState> _formKey;

  ScrollController _listViewController;

  @override
  void initState() { 
    _formKey = GlobalKey<FormState>();
    _messageText ='';
    _listViewController = ScrollController();
    super.initState();
    
  }
  


  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(31, 31, 31, 1.0),
        title: Text(widget.receiverName),
      ),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationPageUI()),
      
    );
  }


  Widget _conversationPageUI(){
    return Builder(builder: (_context){
      _auth = Provider.of<AuthProvider>(_context);

      return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        _messageListView(),
        Align(
          alignment: Alignment.bottomCenter,
          child: _messageField(_context)),
      ],
    );
    });
  }

  _messageListView(){
    return Container(
      height: _deviceHeight * 0.75,
      width: _deviceWidth,
      child: StreamBuilder<Conversation>(
        stream: DBService.instance.getConversation(this.widget.conversationID),
        builder: (_context,_snapshot){
       Timer(Duration(milliseconds: 50),()=>{
         _listViewController.jumpTo(_listViewController.position.maxScrollExtent),
       });
       
        var _conversationData = _snapshot.data;
        
        if(_conversationData!=null){
          if(_conversationData.messages.length!=0){
              return ListView.builder(
            controller: _listViewController,
            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
        itemCount: _conversationData.members.length,
        itemBuilder: (BuildContext _context,index){
           var _message = _conversationData.messages[index];
            bool _isOwnMessage = _message.senderID == _auth.user.uid;
            return _messageListViewChild(_isOwnMessage,_message);
        });
          }else{
            return Center(
              child: Text("Lets start Conversation"),
            );
          }
        

        }else{
          return SpinKitWanderingCubes(
            color:Colors.blue,
            size: 50,
          );
        }


        
      })
    );
  }


  Widget _messageListViewChild(bool _isOwnMessage,Message _message){
    return Padding(
              padding: EdgeInsets.only(bottom:10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment:_isOwnMessage ? MainAxisAlignment.end: MainAxisAlignment.start,
                children: <Widget>[
                 !_isOwnMessage ? _userImageWidget():SizedBox.shrink(),
                SizedBox(width:_deviceWidth*0.02),
                 _message.type==MessageType.Text?_textMessageBubble(_isOwnMessage,_message.content,_message.timestamp):_imageMessageBubble(_isOwnMessage, _message.content, _message.timestamp)
                ],
              ),
              );
  }

  Widget _userImageWidget(){
    double _imageRadius = _deviceHeight * 0.05;
      return Container(
        height:_imageRadius,
        width: _imageRadius,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(500),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(this.widget.receiverImage))
        ),
      );
  }

  _textMessageBubble(bool _isOwnMessage,String _message,Timestamp _timestamp){
    List<Color> _colorsScheme= _isOwnMessage ? [Colors.blue,Color.fromRGBO(42, 117, 188, 1)]:[Color.fromRGBO(69, 69, 69, 1),Color.fromRGBO(43, 43, 43, 1)];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          stops: [0.30,0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.bottomRight,
          colors: _colorsScheme)
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      height: _deviceHeight * 0.08 + (_message.length/20 * 5.0),
      width: _deviceWidth * 0.75,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(_message),
          Text(timeago.format(_timestamp.toDate()),style: TextStyle(
            color: Colors.white70,
          ),)
        ],
      ),
    );
  }

    _imageMessageBubble(bool _isOwnMessage,String _imageURL,Timestamp _timestamp){
    List<Color> _colorsScheme= _isOwnMessage ? [Colors.blue,Color.fromRGBO(42, 117, 188, 1)]:[Color.fromRGBO(69, 69, 69, 1),Color.fromRGBO(43, 43, 43, 1)];

    DecorationImage image = DecorationImage(image: NetworkImage(_imageURL),fit: BoxFit.cover);
     
     
      return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          stops: [0.30,0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.bottomRight,
          colors: _colorsScheme)
      ),
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      // height: _deviceHeight * 0.08 + (_imageURL.length / 20 * 5.0),
      // width: _deviceWidth * 0.75,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: _deviceHeight * 0.30,
            width: _deviceHeight * 0.40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: image
            ),
          ),
          Text(timeago.format(_timestamp.toDate()),style: TextStyle(
            color: Colors.white70,
          ),)
        ],
      ),
    );
  }



  Widget _messageField(BuildContext _context){
    return Container(
      height: _deviceHeight * 0.08,
      decoration: BoxDecoration(
        color: Color.fromRGBO(43, 43, 43, 1),
        borderRadius: BorderRadius.circular(100)
      ),
      margin: EdgeInsets.symmetric(
        horizontal: _deviceWidth * 0.04,vertical: _deviceHeight * 0.03
      ),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _messageTextField(),
            _sendMessageButton(_context),
            _imageMessageButton(),
          ],
        )
        ),
    );
  }


  Widget _messageTextField(){
    return SizedBox(
      width: _deviceWidth * 0.55,
      child: TextFormField(
        validator: (_input){
          if(_input.length==0){
            return "Please Enter a message";
          }
          return null;
        },
        onChanged: (_input){
          _formKey.currentState.save();
          
        },
        onSaved: (_input){
          setState(() {
            _messageText = _input;
          });
        },
        cursorColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Type a message.."
        ),
        autocorrect: false,
      ),
    );
  }

  Widget _sendMessageButton(BuildContext _context){
    return Container(
      height: _deviceHeight * 0.05,
      width: _deviceHeight * 0.05,
      child: IconButton(icon: Icon(Icons.send), onPressed: (){
        if(_formKey.currentState.validate()){
          DBService.instance.sendMessage(this.widget.conversationID, Message(content: _messageText,timestamp: Timestamp.now(),senderID: _auth.user.uid,type: MessageType.Text));
          _formKey.currentState.reset();
          FocusScope.of(_context).unfocus();
        }
      },color: Colors.white),
    );
  }

  Widget _imageMessageButton(){
    return Container(
      height: _deviceHeight * 0.05,
      width: _deviceHeight * 0.05,
      child: FloatingActionButton(onPressed: ()async{
        var _image = await MediaService.instance.getImageFromLibrary();
        if(_image!=null){
          var _result = await CloudStorageService.instance.uploadMediaMessage(_auth.user.uid, _image);
          var _imageURL = await _result.ref.getDownloadURL();
          await DBService.instance.sendMessage(this.widget.conversationID, Message(
            content: _imageURL,
            senderID: _auth.user.uid,
            timestamp: Timestamp.now(),
            type: MessageType.Image,
          ));
        }
      },
      child: Icon(Icons.camera_enhance),
      ),
    );
  }

}