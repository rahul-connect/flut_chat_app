import 'package:flutter/material.dart';
import './profile_page.dart';
import 'recent_conversation_page.dart';
import './search_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  double _height;
  double _width;

  TabController _tabController;

  _HomePageState(){
    _tabController = TabController(length: 3, vsync: this,initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text("FlutChat"),
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        bottom: TabBar(
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          controller: _tabController,
          labelColor: Colors.blue,
          tabs: [
          Tab(icon: Icon(Icons.people_outline,size: 25.0,),),
           Tab(icon: Icon(Icons.chat_bubble_outline,size: 25.0,),),
            Tab(icon: Icon(Icons.person_outline,size: 25.0,),),

        ]),
      ),
      body: _tabBarPages(),

      
    );
  }


  Widget _tabBarPages(){
    return TabBarView(
      controller: _tabController,
      children: [
        SearchPage(_height,_width),
        RecentConversationPage(_height,_width),
        ProfilePage(_height,_width),
    ]);
  }
}