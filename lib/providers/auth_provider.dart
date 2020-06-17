import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutchatapp/services/navigation_service.dart';
import 'package:flutter/material.dart';
import '../services/snackbar_service.dart';
import '../services/db_service.dart';

enum AuthStatus{
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error,
}


class AuthProvider extends ChangeNotifier{
  
  FirebaseAuth _auth;
  AuthStatus status;
  FirebaseUser user;

  static AuthProvider instance = AuthProvider();

  AuthProvider(){
    _auth = FirebaseAuth.instance;
    _checkCurrentUserIsAuthenticated();
  } 

  void _autoLogin(){
    if(user!=null){
      NavigationService.instance.navigateToReplacement('home');
    }
  }

  void _checkCurrentUserIsAuthenticated()async{
    user = await _auth.currentUser();
    if(user!=null){
      await DBService.instance.updateUserLastSeenTime(user.uid);
      notifyListeners();
      _autoLogin();
    }
  }

  void loginUserWithEmailAndPassword(String _email,String _password)async{
    status = AuthStatus.Authenticating;
    notifyListeners();
    try{
    AuthResult _result = await _auth.signInWithEmailAndPassword(email: _email, password: _password);
    user = _result.user;
    status = AuthStatus.Authenticated;
     SnackBarService.instance.showSnackbarSuccess("Welcome, ${user.email}!");
     await DBService.instance.updateUserLastSeenTime(user.uid);
    
    NavigationService.instance.navigateToReplacement('home');

    }catch(e){
      status = AuthStatus.Error;
      user = null;
       SnackBarService.instance..showSnackbarError("Error Authenticating !");
    }
    notifyListeners();
  }


  void registerUserWithEmailAndPassword(String _email,String _password,Future<void> onSuccess(String _uid))async{
    status = AuthStatus.Authenticating;
    notifyListeners();
    try{
      AuthResult _result = await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
      user = _result.user;
      status = AuthStatus.Authenticated;
      await onSuccess(user.uid);
      SnackBarService.instance.showSnackbarSuccess("Welcome, ${user.email}!");
       await DBService.instance.updateUserLastSeenTime(user.uid);

      NavigationService.instance.goBack();
      
      NavigationService.instance.navigateToReplacement('home');

    }catch(e){
      status = AuthStatus.Error;
      user = null;
      SnackBarService.instance.showSnackbarError("Error Registering !");
    }
    notifyListeners();
  }


  void logoutUser(Future<void> onSuccees())async{
    try{
      await _auth.signOut();
      user = null;
      status = AuthStatus.NotAuthenticated;
      await onSuccees();
      await NavigationService.instance.navigateToReplacement('login');

    }catch(e){
      SnackBarService.instance.showSnackbarError("Error Signing Out");
    }
    
    notifyListeners();
  }





}