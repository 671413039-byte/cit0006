import 'package:flutter/material.dart';
import 'loginpage.dart';
import 'config/app_theme.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('images/logo.png'),
            SizedBox(height: 20.0),
            Text(
              'Welcome!! CSIT Family',
              style: AppTheme.headingLarge.copyWith(color: AppTheme.primaryColor),
            ),
            SizedBox(height: 20.0),
            SizedBox(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: AppTheme.primaryButtonStyle(),
                child: Text(
                  'เริ่มใช้งาน',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

