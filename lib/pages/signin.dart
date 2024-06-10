import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:tugas_input_data/pages/home.dart';

const users = {
  'test@gmail.com': '12345',
  'hunter@gmail.com': 'hunter',
};

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 200);

  Future<String?> _authUser(LoginData data) {
    debugPrint('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(data.name)) {
        return 'User not exists';
      }
      if (users[data.name] != data.password) {
        return 'Password does not match';
      }
      return null;
    });
  }

  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FlutterLogin(
          onLogin: _authUser,
          onSignup: _signupUser,
          title: 'Data Test Login',
          logo: const AssetImage('assets/images/analytics.png'),
          scrollable: true,
          theme: LoginTheme(
              pageColorLight: const Color.fromARGB(255, 255, 255, 255),
              pageColorDark: Color.fromARGB(255, 28, 201, 253),
              titleStyle: TextStyle(
                  color: Colors.blue[700], fontWeight: FontWeight.bold)),
          onSubmitAnimationCompleted: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const home(),
            ));
          },
          onRecoverPassword: (String) {},
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Icon(Icons.arrow_back),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }
}
