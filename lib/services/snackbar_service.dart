import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SnackBarService {
  BuildContext _buildContext;
  static SnackBarService instance = SnackBarService();

  SnackBarService(){}

  set buildContext(BuildContext _context){
    _buildContext = _context;
  }

  void showSnackbarError(String _message){
    Scaffold.of(_buildContext).showSnackBar(SnackBar(
      duration: Duration(seconds: 2),
      content: Text(_message,style: TextStyle(color: Colors.white,fontSize: 15),),backgroundColor: Colors.red,));
  }


  
  void showSnackbarSuccess(String _message){
    Scaffold.of(_buildContext).showSnackBar(SnackBar(
      duration: Duration(seconds: 2),
      content: Text(_message,style: TextStyle(color: Colors.white,fontSize: 15),),backgroundColor: Colors.green,));
  }

}