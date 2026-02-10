// 3. สร้างฟอร์มแสดงข้อมูลชื่อ Listcompany.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'user_model.dart';
import 'companylocation.dart';

// Import หน้าแบบฟอร์ม
import 'Company.dart';

class ListCompanyPage extends StatefulWidget {
  const ListCompanyPage({super.key});

  @override
  State<ListCompanyPage> createState() => _ListCompanyPageState();
}

class _ListCompanyPageState extends State<ListCompanyPage> {
  List<Map<String, dynamic>> dataList = [];
  Timer? timer;
  bool isLoading = true;
  String? error;

  // URL API (ปรับตามเครื่องที่รัน)
  final String _baseUrl = "http://192.168.171.1/api_copy";

  @override
  void initState() {
    super.initState();
    fetchData();
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
      final url = Uri.parse("$_baseUrl/getdatacompany.php");
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

  Future<void> _deleteCompany(String companyId) async {
    try {
      final url = Uri.parse("$_baseUrl/savedatacompany.php");
      final response = await http.post(
        url,
        body: {"company_id": companyId, "xcase": "3"},
      );

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          // เปลี่ยนจาก data['status'] เป็น data['success']
          if (data['success'] == true) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(data['message'] ?? "ยกเลิกสถานประกอบการสำเร็จ"),
                  backgroundColor: Colors.green,
                ),
              );
              // Refresh ข้อมูลทันทีหลังลบสำเร็จ
              await Future.delayed(const Duration(milliseconds: 500));
              await fetchData();
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(data['message'] ?? "ยกเลิกข้อมูลไม่สำเร็จ"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          print("Error decoding JSON: $e");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("เกิดข้อผิดพลาดในการแปลง JSON: $e")),
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

  void _confirmDelete(String companyId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ยืนยันการลบ"),
        content: const Text("คุณแน่ใจหรือไม่ที่จะลบข้อมูลสถานประกอบการนี้?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCompany(companyId);
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
        title: const Text("สถานประกอบการ"),
        backgroundColor: Colors.green,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CompanyPage(xcase: 1),
                ),
              ).then((_) => fetchData());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 252, 252, 251),
            ),
            child: const Text("+ เพิ่ม "),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CompanyLocationPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 252, 252, 251),
            ),
            child: const Text("ตำแหน่ง"),
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
                      // company_id ต้องไม่เป็น null หรือว่างสำหรับการแก้ไข
                      final companyId = data['company_id']?.toString() ?? '';
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
                                      "${data['company_name']}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${data['address'] ?? '-'} โทร. ${data['telno'] ?? '-'}",
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
                                  // ปุ่มแก้ไข (ขนาดปกติ ตามต้นฉบับ)
                                  ElevatedButton(
                                    onPressed: companyId.isEmpty
                                        ? null
                                        : () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => CompanyPage(
                                                  xcase: 2,
                                                  company_id: companyId,
                                                  company_name: data['company_name'],
                                                  address: data['address'],
                                                  tumbol_code: data['tumbon']?.toString(),
                                                  amphur_code: data['amphur']?.toString(),
                                                  province_code: data['province']?.toString(),
                                                  postcode: data['postcode'],
                                                  contact_name: data['contact_name'],
                                                  telno: data['telno'],
                                                  latitude: data['latitude']?.toString(),
                                                  longitude: data['longitude']?.toString(),
                                                ),
                                              ),
                                            ).then((_) => fetchData());
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        252,
                                        252,
                                        251,
                                      ),
                                    ),
                                    child: const Text("แก้ไข"),
                                  ),
                                  const SizedBox(width: 8),
                                  // ปุ่มลบ (ขนาดปกติเท่าแก้ไข แต่สีแดง)
                                  ElevatedButton(
                                    onPressed: () {
                                      _confirmDelete(companyId);
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
