import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config/app_theme.dart';

class RegisterUserForm extends StatefulWidget {
  const RegisterUserForm({super.key});

  @override
  State<RegisterUserForm> createState() => _RegisterUserFormState();
}

class _RegisterUserFormState extends State<RegisterUserForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController officeNameController = TextEditingController();
  final TextEditingController telnoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> submitRegister(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final firstname = firstnameController.text.trim();
    final lastname = lastnameController.text.trim();
    final address = addressController.text.trim();
    final officeName = officeNameController.text.trim();
    final telno = telnoController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      String apiUrl = 'http://192.168.171.1/api_copy/adduser.php';
      final url = Uri.parse(apiUrl); // [TODO: ใส่ URL เต็มของ API]
      final response = await http.post(
        url,
        body: {
          "firstname": firstname,
          "lastname": lastname,
          "address": address,
          "office_name": officeName,
          "telno": telno,
          "email": email,
          "password": password,
          "case": "1",
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["status"] == "success") {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("ลงทะเบียนสำเร็จ!")));
          Navigator.pop(context); // กลับไปหน้า Login
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "ลงทะเบียนไม่สำเร็จ")),
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
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ลงทะเบียนผู้ใช้งาน"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingXL),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: firstnameController,
                decoration: InputDecoration(
                  labelText: "ชื่อ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                validator: (value) => value!.isEmpty ? "กรุณากรอกชื่อ" : null,
              ),
              const SizedBox(height: AppTheme.paddingM),
              TextFormField(
                controller: lastnameController,
                decoration: InputDecoration(
                  labelText: "นามสกุล",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? "กรุณากรอกนามสกุล" : null,
              ),
              const SizedBox(height: AppTheme.paddingM),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: "ที่อยู่",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.paddingM),
              TextFormField(
                controller: officeNameController,
                decoration: InputDecoration(
                  labelText: "ชื่อหน่วยงาน",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.paddingM),
              TextFormField(
                controller: telnoController,
                decoration: InputDecoration(
                  labelText: "เบอร์โทรศัพท์",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppTheme.paddingM),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "อีเมล",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? "กรุณากรอกอีเมล" : null,
              ),
              const SizedBox(height: AppTheme.paddingM),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "รหัสผ่าน",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? "กรุณากรอกรหัสผ่าน" : null,
              ),
              const SizedBox(height: AppTheme.paddingXL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => submitRegister(context),
                  style: AppTheme.primaryButtonStyle().copyWith(
                    minimumSize: MaterialStateProperty.all(const Size.fromHeight(48)),
                  ),
                  child: const Text("ลงทะเบียน"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
