import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutchatapp/models/conversation.dart';
import 'package:flutchatapp/models/message.dart';
import 'package:flutchatapp/pages/conversation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/db_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/navigation_service.dart';


class RecentConversationPage extends StatelessWidget {
  final double _height;
  final double _width;

  const RecentConversationPage(this._height, this._width);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      height: _height,
      child: ChangeNotifierProvider.value(
        value: AuthProvider.instance,
        child: _conversationsListView()),
      
    );
  }


  Widget _conversationsListView(){
    return Builder(builder: (BuildContext _context){
      var _auth = Provider.of<AuthProvider>(_context);

     return Container(
      height: _height,
      width: _width,
      child: StreamBuilder<List<ConversationSnippet>>(
        stream: DBService.instance.getUSerConversation(_auth.user.uid),
        builder: (_context,_snapshot){
          var _data = _snapshot.data;
          _data.removeWhere((element){return element.timestamp==null;});
        if(!_snapshot.hasData){
          return Center(
            child: SpinKitRotatingCircle(
  color: Colors.white,
  size: 50.0,
)
          );
        }else if(_data.length < 1){
          return Text("No Conversation Started yet");
        }
        return ListView.builder(
        itemCount: _data.length,
        itemBuilder: (_context,index){
          
          return ListTile(
            onTap: (){
              NavigationService.instance.navigateToRoute(
                MaterialPageRoute(builder: (BuildContext _context)=>ConversationPage(
                  conversationID: _data[index].conversationID,
                  receiverID: _data[index].id,
                  receiverName: _data[index].name,
                  receiverImage: _data[index].image,
                ))
              );
            },
            title: Text(_data[index].name),
            subtitle: Text(_data[index].type==MessageType.Text?_data[index].lastMessage:"Attachment : image"),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                image: DecorationImage(image: NetworkImage(_data[index].image),fit: BoxFit.cover)
              ),
            ),
            trailing: _listTileTrailingWidget(_data[index].timestamp),
          );
        }
        
        );
      })
    );
    });
  }


  Widget _listTileTrailingWidget(Timestamp _lastMessageTimeStamp){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(timeago.format(_lastMessageTimeStamp.toDate()),style:TextStyle(fontSize: 15)),
        // Container(
        //   height: 12,
        //   width: 12,
        //   decoration: BoxDecoration(
        //     color: Colors.blue,
        //     borderRadius: BorderRadius.circular(100)
        //   ),
        // )
      ],

    );
  }


}