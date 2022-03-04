import 'dart:convert';

import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_share_me/flutter_share_me.dart';

void main() {
  runApp(const LoginPage());
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoggedIn = false;
  var profileData;

  var facebookLogin = FacebookLogin();

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Facebook Login"),
        ),
        body: Container(
          child: Center(
            child: isLoggedIn
                ? _displayUserData(profileData)
                : _displayLoginButton(),
          ),
        ),
      ),
    );
  }

  void loginButtonClicked() async {
    var facebookLoginResult = await facebookLogin.logIn(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        var graphResponse = await http.get(Uri.parse(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(200)&access_token=${facebookLoginResult.accessToken.token}'));

        var profile = json.decode(graphResponse.body);
        debugPrint(profile.toString());

        onLoginStatusChanged(true, profileData: profile);
        break;
    }
  }

  _displayUserData(profileData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 200.0,
          width: 200.0,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(
                profileData['picture']['data']['url'],
              ),
            ),
          ),
        ),
        const SizedBox(height: 28.0),
        Text(
          "Name: ${profileData['name']}",
          style: const TextStyle(
            fontSize: 20.0,
          ),
        ),
        Text(
          "Email: ${profileData['email']}",
          style: const TextStyle(
            fontSize: 20.0,
          ),
        ),
        ElevatedButton(
          onPressed: () => onButtonTap(
            'Đổi cái này trong main.dart, ở dòng số 104',
            'https://github.com/often127',
          ),
          child: const Text("Facebook share"),
        ),
        ElevatedButton(
          child: const Text("Logout"),
          onPressed: () => facebookLogin.isLoggedIn
              .then((isLoggedIn) => isLoggedIn ? _logout() : {}),
        )
      ],
    );
  }

  _displayLoginButton() {
    return ElevatedButton(
      child: const Text("Login with Facebook"),
      onPressed: () => loginButtonClicked(),
    );
  }

  _logout() async {
    await facebookLogin.logOut();
    onLoginStatusChanged(false);
    debugPrint("Logged out");
  }

  Future<void> onButtonTap(String msg, String url) async {
    String? response;
    final FlutterShareMe flutterShareMe = FlutterShareMe();
    response = await flutterShareMe.shareToFacebook(url: url, msg: msg);
    debugPrint(response);
  }
}
