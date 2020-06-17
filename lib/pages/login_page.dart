import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/snackbar_service.dart';
import '../services/navigation_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AuthProvider _auth;
  String _email;
  String _password;

  double _deviceHeight;
  double _deviceWidth;


  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Align(
        alignment: Alignment.center,
        child: ChangeNotifierProvider<AuthProvider>.value(value: AuthProvider.instance,child: _loginPageUI(),)
        ),
      
    );
  }


  Widget _loginPageUI(){
    return Builder(builder: (_context){
      SnackBarService.instance.buildContext = _context;

      _auth = Provider.of<AuthProvider>(_context);
      return Container(
      padding: EdgeInsets.symmetric(horizontal: _deviceWidth*0.10),
      height: _deviceHeight * 0.60,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _headingWidget(),
          _inputForm(),
          _loginButton(),
          _registerButton(),
        ],
      ),
    );
    });
  }

  Widget _headingWidget(){
    return Container(
      alignment: Alignment.center,
      height: _deviceHeight * 0.15,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text("Welcome Back",style:TextStyle(fontSize: 35,fontWeight: FontWeight.w700)),
          Text("Please login to your account",style:TextStyle(fontSize: 20,fontWeight: FontWeight.w200)),
        ],
      ),
    );
  }


  Widget _inputForm(){
    return Container(
      height: _deviceHeight * 0.24,
      child: Form(
        key: _formKey,
        onChanged: (){
          _formKey.currentState.save();

        },
        child:Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _emailTextField(),
            SizedBox(height: 10,),
            _passwordTextField(),
            
          ],
        ),
         ),
    );
  }


  Widget _emailTextField(){
    return TextFormField(
      autocorrect: false,
      style: TextStyle(
        color: Colors.white,

      ),
      validator: (input){
        return input.length != 0 && input.contains("@")?null:"Please enter a valid email";
      },
      onSaved: (input){
        setState(() {
          _email = input;
        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
         hintText: "Email Address",
         focusedBorder: UnderlineInputBorder(
           borderSide: BorderSide(color: Colors.white)
         )
      ),
    );
  }

    Widget _passwordTextField(){
    return TextFormField(
      autocorrect: false,
      obscureText: true,
      style: TextStyle(
        color: Colors.white,

      ),
      validator: (input){
        return input.length != 0 ? null : "Please enter a password";
      },
      onSaved: (input){
         setState(() {
          _password = input;
        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
         hintText: "Password",
         focusedBorder: UnderlineInputBorder(
           borderSide: BorderSide(color: Colors.white)
         )
      ),
    );
  }

  Widget _loginButton(){
    return (_auth.status == AuthStatus.Authenticating) ? Center(child: CircularProgressIndicator()): Container(
      height: _deviceHeight * 0.06,
      width: _deviceWidth,
      child: MaterialButton(
        color: Colors.blue,
        child: Text("LOGIN",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w700),),
        onPressed: (){
          if(_formKey.currentState.validate()){
            _auth.loginUserWithEmailAndPassword(_email, _password);
          }

      }),
    );
  }

  Widget _registerButton(){
    return GestureDetector(
      onTap: (){
        NavigationService.instance.navigateTo('register');
      },
          child: Container(
        height: _deviceWidth * 0.06,
        width: _deviceWidth,
        child: Text("REGISTER",style: TextStyle(fontSize: 15,color: Colors.white60),textAlign: TextAlign.center,),
      ),
    );
  }


}