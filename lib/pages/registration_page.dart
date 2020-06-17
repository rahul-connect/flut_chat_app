import 'package:flutchatapp/providers/auth_provider.dart';
import 'package:flutchatapp/services/cloud_storage_service.dart';
import 'package:flutchatapp/services/db_service.dart';
import 'package:flutchatapp/services/snackbar_service.dart';
import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import '../services/media_service.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  GlobalKey<FormState> _formKey;
  AuthProvider _auth;
  double _deviceHeight;
  double _deviceWidth;
  File image;
  String _name;
  String _email;
  String _password;

  _RegistrationPageState() {
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        alignment: Alignment.center,
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: registrationPageUI()),
      ),
    );
  }

  Widget registrationPageUI() {
    return Builder(builder: (_context){
      SnackBarService.instance.buildContext = _context;
      
      _auth = Provider.of<AuthProvider>(_context);
      return SingleChildScrollView(
              child: Container(
        padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.10),
        height: _deviceHeight * 0.75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _headingWidget(),
            _inputForm(),
            _registerButton(),
            _backToLoginPage(),
          ],
        ),
    ),
      );
    });
  }

  Widget _headingWidget() {
    return Container(
      alignment: Alignment.center,
      height: _deviceHeight * 0.15,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text("Let's get going",
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700)),
          Text("Please enter your details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w200)),
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Container(
      height: _deviceHeight * 0.35,
      child: Form(
          key: _formKey,
          onChanged: () {
            _formKey.currentState.save();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _imageSelectorWidget(),
              _nameTextField(),
              _emailTextField(),
              _passwordTextField(),
            ],
          )),
    );
  }

  Widget _imageSelectorWidget() {
    return Center(
      child: GestureDetector(
        onTap: ()async{
          File _imageFile = await MediaService.instance.getImageFromLibrary();
          setState(() {
              image = _imageFile;
          });
        
        },
              child: Container(
          height: _deviceHeight * 0.10,
          width: _deviceHeight * 0.10,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(500),
            image: DecorationImage(
                fit: BoxFit.cover,
                image: image!=null ? FileImage(image) : NetworkImage(
                    'https://library.kissclipart.com/20181001/wbw/kissclipart-gsmnet-ro-clipart-computer-icons-user-avatar-4898c5072537d6e2.png')),
          ),
        ),
      ),
    );
  }

  Widget _nameTextField() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(
        color: Colors.white,
      ),
      validator: (input) {
        return input.length != 0 ? null : "Please enter a valid name";
      },
      onSaved: (input) {
        setState(() {
          _name = input;

        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
          hintText: "Full Name",
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white))),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(
        color: Colors.white,
      ),
      validator: (input) {
        return input.length != 0 && input.contains("@")
            ? null
            : "Please enter a valid email";
      },
      onSaved: (input) {
        setState(() {
          _email = input;
        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
          hintText: "Email Address",
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white))),
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      obscureText: true,
      autocorrect: false,
      style: TextStyle(
        color: Colors.white,
      ),
      validator: (input) {
        return input.length != 0 ? null : "Please enter a valid password";
      },
      onSaved: (input) {
        setState(() {
          _password = input;
        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
          hintText: "Password",
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white))),
    );
  }

  Widget _registerButton() {
    return _auth.status != AuthStatus.Authenticating ? Container(
      height: _deviceHeight * 0.06,
      width: _deviceWidth,
      child: MaterialButton(
          color: Colors.blue,
          child: Text(
            "Register",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          onPressed: () {
            if(_formKey.currentState.validate() && image!=null){
              _auth.registerUserWithEmailAndPassword(_email, _password, (_uid) async{
                var _result = await CloudStorageService.instance.uploadUserImage(_uid, image);
                var _imageUrl = await _result.ref.getDownloadURL();
                await DBService.instance.createUserInDB(_uid, _name, _email, _imageUrl);

              });
            }
          }),
    ):Center(child: CircularProgressIndicator(),);
  }


  Widget _backToLoginPage(){
    return GestureDetector(
        onTap: (){
          NavigationService.instance.goBack();
        },
          child: Container(
        height: _deviceHeight * 0.06,
        width: _deviceWidth,
        child: Icon(Icons.arrow_back,size: 40,),
      ),
    );
  }

}
