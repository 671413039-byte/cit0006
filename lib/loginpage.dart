import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
//---- ปิดไว้ก่อน
import 'menu.dart';
import 'user_model.dart';
import 'register.dart';
import 'config/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> submitLogin(BuildContext context) async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกชื่อผู้ใช้และรหัสผ่าน')),
      );
      return;
    }

    try {
      final url = Uri.parse("http://192.168.171.1/api_copy/checklogin.php");
      final response = await http.post(
        url,
        body: {"username": username, "password": password},
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        //print("BBBBBBBB");

        if (data["status"] == "success") {
          final user = data["user"];
          final userId = user["userid"]?.toString() ?? "";
          final firstName = user["firstname"] ?? "";
          final lastName = user["lastname"] ?? "";
          final address = user["address"] ?? "";
          final telno = user["telno"] ?? "";
          final office_name = user["office_name"] ?? "";

          Provider.of<UserModel>(context, listen: false).setUser(
            id: userId,
            first: firstName,
            last: lastName,
            add: address,
            tel: telno,
            office: office_name,
          );

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('ยินดีต้อนรับ $firstName')));

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MenuPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? 'เข้าสู่ระบบไม่สำเร็จ')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('ยินดีต้อนรับ/Welcome'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.paddingXL),
          child: Column(
            children: [
              Image.asset('images/logo.png', width: 400, height: 400),
              const SizedBox(height: AppTheme.paddingL),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'ชื่อผู้ใช้งาน (Username)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.paddingL),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'รหัสผ่าน (Password)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: AppTheme.paddingXL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => submitLogin(context),
                  style: AppTheme.primaryButtonStyle().copyWith(
                    minimumSize: MaterialStateProperty.all(const Size.fromHeight(48)),
                  ),
                  child: const Text('เข้าสู่ระบบ (Login)'),
                ),
              ),
              const SizedBox(height: AppTheme.paddingM),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RegisterUserForm(),
                    ),
                  );
                },
                child: const Text('ลงทะเบียนใช้งาน (Register)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
