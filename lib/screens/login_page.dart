import 'package:flutter/material.dart';
import 'package:mediblock/res/custom_colors.dart';
import 'package:mediblock/screens/name_screen.dart';
import 'package:mediblock/utils/authentication.dart';
import 'package:mediblock/widgets/logo_widget.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoggingIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.dark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/medi_cover.png'),
                    SizedBox(height: 80),
                    LogoWidget(textSize: 50),
                  ],
                ),
              ),
              _isLoggingIn
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                          CustomColors.blue,
                        ),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Container(
                        width: double.maxFinite,
                        child: RaisedButton(
                          color: CustomColors.blue,
                          onPressed: () async {
                            setState(() {
                              _isLoggingIn = true;
                            });
                            await signInWithGoogle().then((result) {
                              if (result != null) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => NamePage(),
                                  ),
                                );
                              }
                            }).catchError((e) => print('Google sign in error: $e'));
                            setState(() {
                              _isLoggingIn = false;
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                            child: Text(
                              'LOGIN',
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                child: Text(
                  '* Uses Google Sign In for authentication (none of the user identifiable information is stored on the backend)',
                  style: TextStyle(color: Colors.white60, fontSize: 12.0, letterSpacing: 1.4),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
