import 'package:flutchatapp/models/contact.dart';
import 'package:flutchatapp/pages/conversation_page.dart';
import 'package:flutchatapp/services/navigation_service.dart';
import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class SearchPage extends StatefulWidget {
  final double _height;
  final double _width;
  

  SearchPage( this._height, this._width);
  
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  AuthProvider _auth;
  String _searchText;

  _SearchPageState(){
    _searchText = "";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
    child: ChangeNotifierProvider.value(
      value: AuthProvider.instance,
      child: _searchPageUI())
    );
  }

  Widget _searchPageUI(){
    return Builder(builder: (_context){
      _auth = Provider.of<AuthProvider>(_context);

      return SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _userSearchField(),
          _userListView(),
        ],
      ),
    );
    });
  }

  Widget _userSearchField(){
    return Container(
      height: widget._height * 0.09,
      width: widget._width,
      padding: EdgeInsets.symmetric(vertical: widget._height*0.02),
      child: TextField(
        autocorrect: false,
        style: TextStyle(
          color: Colors.white,
        ),
        onSubmitted: (_input){
          setState(() {
            _searchText = _input;
          });
        },
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search,color: Colors.white,),
          labelText: "Search",
          labelStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }


  Widget _userListView(){
    return StreamBuilder<List<Contact>>(
      stream: DBService.instance.getUsersInDB(_searchText),
      builder: (_context,_snapshot){
      
      var _usersData = _snapshot.data;
      if(_usersData != null){
        _usersData.removeWhere((element) => element.id == _auth.user.uid);
      }


      return _snapshot.hasData ? Container(
      height: widget._height * 0.70,
      child: ListView.builder(
        itemCount: _usersData.length,
        itemBuilder: (_context,_index){
          var _userData = _usersData[_index];
          var _currentTime = DateTime.now();
          var _isUserActive = !_userData.lastseen.toDate().isBefore(_currentTime.subtract(Duration(hours: 1)));
          var _receipientID = _usersData[_index].id;
          return ListTile(
            onTap: ()async{
              DBService.instance.createOrGetConversation(_auth.user.uid, _receipientID, (_conversationID){
                NavigationService.instance.navigateToRoute(MaterialPageRoute(builder: (_context){
                  return ConversationPage(
                    conversationID: _conversationID,
                    receiverID: _receipientID,
                    receiverName: _userData.name,
                    receiverImage: _userData.image,
                  );
                }));
              });
            },
            title: Text(_userData.name),
            leading: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                image: DecorationImage(image: NetworkImage(_userData.image),fit: BoxFit.cover)
                
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                _isUserActive? Text("Active Now",style: TextStyle(fontSize: 15),):Text("LastSeen",style: TextStyle(fontSize: 15),),
                 _isUserActive ? Container(
                   height: 10,
                   width: 10,
                   decoration: BoxDecoration(
                     color: Colors.green,
                     borderRadius: BorderRadius.circular(100)
                   ),
                 ) : Text(timeago.format(_userData.lastseen.toDate()),style: TextStyle(fontSize: 15),)
              ],
            ),
          );
        }),
    ):Center(
      child: CircularProgressIndicator(),
    );
    });
  }
}