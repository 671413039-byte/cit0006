import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SpecialProjectPage extends StatefulWidget {
  final String? student_id;
  final String? special_name;
  final int? flag_send;
  final int? xcase; // 1=เพิ่ม, 2=แก้ไข, 3=ลบ

  const SpecialProjectPage({
    super.key,
    this.student_id,
    this.special_name,
    this.flag_send,
    this.xcase,
  });

  @override
  State<SpecialProjectPage> createState() => _SpecialProjectPageState();
}

class _SpecialProjectPageState extends State<SpecialProjectPage> {
  final TextEditingController student_idController = TextEditingController();
  final TextEditingController special_nameController = TextEditingController();
  
  // ใช้ตัวแปรนี้เก็บค่าสถานะแทน Controller (ค่าเริ่มต้น 1 = เพิ่ม)
  int _selectedStatus = 1; 

  @override
  void initState() {
    super.initState();
    // กรณีแก้ไข: ดึงข้อมูลเดิมมาใส่
    if (widget.student_id != null) {
      student_idController.text = widget.student_id!;
    }
    if (widget.special_name != null) {
      special_nameController.text = widget.special_name!;
    }
    // ถ้ามีค่าสถานะส่งมา (กรณีแก้ไข) ให้ใช้ค่านั้น
    if (widget.flag_send != null) {
      _selectedStatus = widget.flag_send!;
    }
  }

  Future<void> _submitData() async {
    final student_id = student_idController.text.trim();
    final special_name = special_nameController.text.trim();
    
    // ตรวจสอบข้อมูลว่าง
    if (widget.xcase == 1) { 
         // กรณีเพิ่มใหม่ ต้องกรอกทั้งสองช่อง
         if (student_id.isEmpty || special_name.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("กรุณากรอกรหัสนักศึกษาและชื่อโครงงาน")),
            );
            return;
         }
    } else if (widget.xcase == 2) { 
         // กรณีแก้ไข ชื่อต้องไม่ว่าง
         if (special_name.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("กรุณากรอกชื่อโครงงาน")),
            );
            return;
         }
    }

    try {
      // URL API (ปรับตามเครื่องที่รัน: 192.168.1.228 หรือ 10.0.2.2)
      final url = Uri.parse("http://192.168.1.228/api_copy/savedataspecialproject.php"); 
      
      final response = await http.post(
        url,
        body: {
          "student_id": student_id,
          "special_name": special_name,
          "flag_send": _selectedStatus.toString(), // ส่งค่าจากตัวแปร (ไม่ต้องพิมพ์)
          "xcase": widget.xcase.toString(),
        },
      );

      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["status"] == "success") {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("บันทึกข้อมูลสำเร็จ")),
            );
            Navigator.pop(context, true); // ส่งค่า true กลับไปให้หน้ารายการ refresh
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data["message"] ?? "บันทึกไม่สำเร็จ")),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Server error: ${response.statusCode}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String titleText = "";
    if (widget.xcase == 1) {
      titleText = "เพิ่มโครงงานพิเศษ";
    } else if (widget.xcase == 2) {
      titleText = "แก้ไขโครงงานพิเศษ";
    } else if (widget.xcase == 3) {
      titleText = "ลบโครงงานพิเศษ";
    } else {
      titleText = "ข้อมูลโครงงานพิเศษ";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        backgroundColor: widget.xcase == 3 ? Colors.red : Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: student_idController,
              // ปิดการแก้ไขรหัสถ้านี่ไม่ใช่การเพิ่มข้อมูลใหม่ (case 1)
              enabled: widget.xcase == 1, 
              decoration: const InputDecoration(
                labelText: "รหัสนักศึกษา",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: special_nameController,
              decoration: const InputDecoration(
                labelText: "ชื่อโครงงานพิเศษ",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.assignment),
              ),
            ),
            
            // --- ส่วนสถานะ (แสดงเฉพาะตอนแก้ไข) ---
            // ถ้าเพิ่มใหม่ (xcase=1) จะซ่อนส่วนนี้ และใช้ค่า default = 1
            if (widget.xcase == 2) ...[
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: const Text("สถานะ:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedStatus,
                    isExpanded: true,
                    // ตัวเลือก: 1=เพิ่ม, 0=ยกเลิก
                    items: const [
                      DropdownMenuItem(
                        value: 1,
                        child: Text("เพิ่ม (Active)"),
                      ),
                      DropdownMenuItem(
                        value: 0,
                        child: Text("ยกเลิก (Inactive)"),
                      ),
                    ],
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedStatus = newValue!;
                      });
                    },
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.xcase == 3 ? Colors.red : Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text(widget.xcase == 3 ? "ยืนยันการลบ" : "บันทึกข้อมูล"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}