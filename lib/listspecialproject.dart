import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Import หน้าแบบฟอร์ม (Special_project.dart)
import 'Special_project.dart';

class ListSpecialProjectPage extends StatefulWidget {
  const ListSpecialProjectPage({super.key});

  @override
  State<ListSpecialProjectPage> createState() => _ListSpecialProjectPageState();
}

class _ListSpecialProjectPageState extends State<ListSpecialProjectPage> {
  List<Map<String, dynamic>> dataList = [];
  Timer? timer;
  bool isLoading = true;
  String? error;

  // URL API (ปรับตามเครื่องที่รัน: 192.168.1.228 หรือ 10.0.2.2)
  final String _baseUrl = "http://192.168.1.228/api_copy";

  @override
  void initState() {
    super.initState();
    fetchData();
    // ตั้งเวลา refresh ทุก 10 วินาที
    timer = Timer.periodic(const Duration(seconds: 10), (_) => fetchData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    if (!mounted) return;
    try {
      final url = Uri.parse("$_baseUrl/getdataspecialproject.php");
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          if (mounted) {
            setState(() {
              dataList = List<Map<String, dynamic>>.from(data);
              isLoading = false;
              error = null;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              if (data == null) {
                dataList = [];
              } else {
                error = "รูปแบบข้อมูลไม่ถูกต้อง";
              }
              isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            error = "Server error: ${response.statusCode}";
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = "เกิดข้อผิดพลาด: $e";
          isLoading = false;
        });
      }
    }
  }

  // ฟังก์ชันลบข้อมูล (xcase = 3)
  Future<void> _deleteProject(String studentId) async {
    try {
      final url = Uri.parse("$_baseUrl/savedataspecialproject.php");
      final response = await http.post(
        url,
        // ส่ง xcase = "3" เพื่อบอกว่าต้องการลบ
        body: {"student_id": studentId, "xcase": "3"},
      );

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("ลบข้อมูลสำเร็จ")));
            }
            fetchData();
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(data['message'] ?? "ลบข้อมูลไม่สำเร็จ")),
              );
            }
          }
        } catch (e) {
          print("Error decoding JSON: $e");
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
      }
    }
  }

  void _confirmDelete(String studentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ยืนยันการลบ"),
        content: const Text("คุณแน่ใจหรือไม่ที่จะลบข้อมูลโครงงานนี้?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProject(studentId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("ลบ", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("โครงงานพิเศษ"),
        backgroundColor: Colors.green,
        actions: [
          // ปุ่มเพิ่มข้อมูล (ส่ง xcase = 1)
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SpecialProjectPage(xcase: 1),
                ),
              ).then((_) => fetchData());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 252, 252, 251),
            ),
            child: const Text("+ เพิ่ม "),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (error != null
              ? Center(
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : dataList.isEmpty
                  ? const Center(child: Text("ไม่พบข้อมูล"))
                  : ListView.builder(
                      itemCount: dataList.length,
                      itemBuilder: (context, index) {
                        final data = dataList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          color: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${data['special_name']}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      // --- แก้ไขตรงนี้: ลบส่วนแสดงสถานะออก เหลือแค่รหัส ---
                                      Text(
                                        "รหัส: ${data['student_id']}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    // ปุ่มแก้ไข (ส่ง xcase = 2)
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SpecialProjectPage(
                                              xcase: 2, // ระบุว่าเป็นแก้ไข
                                              student_id: data['student_id'],
                                              special_name: data['special_name'],
                                              // ยังคงส่งค่า flag_send ไปเผื่อใช้ในการแก้ไข แต่หน้า list ไม่แสดงแล้ว
                                              flag_send: int.tryParse(data['flag_send'].toString()),
                                            ),
                                          ),
                                        ).then((_) => fetchData());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255, 252, 252, 251,
                                        ),
                                      ),
                                      child: const Text("แก้ไข"),
                                    ),
                                    const SizedBox(width: 8),
                                    // ปุ่มลบ (เรียกฟังก์ชันยืนยันลบ)
                                    ElevatedButton(
                                      onPressed: () {
                                        _confirmDelete(data['student_id']);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text("ลบ"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )),
    );
  }
}