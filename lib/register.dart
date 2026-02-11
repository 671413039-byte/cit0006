import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
      String apiUrl = 'http://192.168.1.228/api_copy/adduser.php';
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
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: firstnameController,
                decoration: const InputDecoration(labelText: "ชื่อ"),
                validator: (value) => value!.isEmpty ? "กรุณากรอกชื่อ" : null,
              ),
              TextFormField(
                controller: lastnameController,
                decoration: const InputDecoration(labelText: "นามสกุล"),
                validator: (value) =>
                    value!.isEmpty ? "กรุณากรอกนามสกุล" : null,
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "ที่อยู่"),
              ),
              TextFormField(
                controller: officeNameController,
                decoration: const InputDecoration(labelText: "ชื่อหน่วยงาน"),
              ),
              TextFormField(
                controller: telnoController,
                decoration: const InputDecoration(labelText: "เบอร์โทรศัพท์"),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "อีเมล"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? "กรุณากรอกอีเมล" : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "รหัสผ่าน"),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? "กรุณากรอกรหัสผ่าน" : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => submitRegister(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 18),
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
