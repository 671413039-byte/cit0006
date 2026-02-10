import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'intern_term_form.dart';
import 'config/app_theme.dart';

class InternTermListPage extends StatefulWidget {
  @override
  _InternTermListPageState createState() => _InternTermListPageState();
}

class _InternTermListPageState extends State<InternTermListPage> {
  List<Map<String, dynamic>> terms = [];
  Timer? timer;
  bool isLoading = true;
  String? error;
  final String _baseUrl = "http://192.168.171.1/api_copy";

  @override
  void initState() {
    super.initState();
    fetchTerms();
    timer = Timer.periodic(const Duration(seconds: 10), (_) => fetchTerms());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchTerms() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final url = Uri.parse("$_baseUrl/intern_term_api.php");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'xcase': '0'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if ((data['status'] == 'success' || data['success'] == true) && data['terms'] is List) {
          setState(() {
            terms = List<Map<String, dynamic>>.from(data['terms']);
            isLoading = false;
            error = null;
          });
        } else {
          setState(() {
            error = "ข้อมูลผิดรูปแบบหรือไม่สำเร็จ";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = "Server error: "+response.statusCode.toString();
          isLoading = false;
        });
      }
    } catch (e) {
      print('fetchTerms error: ' + e.toString());
      if (mounted) {
        setState(() {
          error = "เกิดข้อผิดพลาด: $e";
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: ' + e.toString())),
        );
      }
    }
  }


  void addTerm() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InternTermFormPage(),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      final url = Uri.parse('$_baseUrl/intern_term_api.php');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'term': result['term'],
            'start_date': result['start_date'],
            'end_date': result['end_date'],
            'xcase': '1',
          },
        );
        final data = json.decode(response.body);
        if (response.statusCode == 200 && data['status'] == 'success') {
          fetchTerms();
        } else {
          print('addTerm error: ' + response.body);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('เกิดข้อผิดพลาดในการเพิ่มข้อมูล: ' + (data['message'] ?? ''))),
            );
          }
        }
      } catch (e) {
        print('addTerm error: ' + e.toString());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาดในการเพิ่มข้อมูล: ' + e.toString())),
          );
        }
      }
    }
  }

  void editTerm(Map<String, dynamic> term) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InternTermFormPage(term: term),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      if (result['delete'] == true) {
        deleteTerm(term['term']);
      } else {
        final url = Uri.parse('$_baseUrl/intern_term_api.php');
        final body = {
          'term': result['term'],
          'start_date': result['start_date'],
          'end_date': result['end_date'],
          'xcase': '2',
        };
        print('editTerm body: $body');
        try {
          final response = await http.post(
            url,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: body,
          );
          print('editTerm response: ${response.body}');
          final data = json.decode(response.body);
          if (response.statusCode == 200 && data['status'] == 'success') {
            fetchTerms();
          } else {
            print('editTerm error: ' + response.body);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('เกิดข้อผิดพลาดในการแก้ไขข้อมูล: ' + (data['message'] ?? ''))),
              );
            }
          }
        } catch (e) {
          print('editTerm error: ' + e.toString());
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('เกิดข้อผิดพลาดในการแก้ไขข้อมูล: ' + e.toString())),
            );
          }
        }
      }
    }
  }

  void deleteTerm(String termId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบ'),
          content: const Text('คุณแน่ใจว่าต้องการลบข้อมูลนี้หรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final url = Uri.parse('$_baseUrl/intern_term_api.php');
                try {
                  final response = await http.post(
                    url,
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: {
                      'term': termId,
                      'xcase': '3',
                    },
                  );
                  final data = json.decode(response.body);
                  if (response.statusCode == 200 && data['status'] == 'success') {
                    fetchTerms();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ลบข้อมูลสำเร็จ')),
                      );
                    }
                  } else {
                    print('deleteTerm error: ' + response.body);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('เกิดข้อผิดพลาดในการลบข้อมูล: ' + (data['message'] ?? ''))),
                      );
                    }
                  }
                } catch (e) {
                  print('deleteTerm error: ' + e.toString());
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('เกิดข้อผิดพลาดในการลบข้อมูล: ' + e.toString())),
                    );
                  }
                }
              },
              child: const Text('ลบ', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อมูลภาคการศึกษา'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: addTerm,
              icon: const Icon(Icons.add, size: 18),
              label: const Text("เพิ่ม"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (error != null
              ? Center(
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : terms.isEmpty
                  ? const Center(child: Text("ไม่พบข้อมูล"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: terms.length,
                      itemBuilder: (context, index) {
                        final term = terms[index];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                          color: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        term['term'] ?? 'N/A',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'เริ่ม: ${term['start_date']} - สิ้นสุด: ${term['end_date']}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 70,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                        onPressed: () => editTerm(term),
                                        child: const Text(
                                          'แก้ไข',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 70,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                        onPressed: () => deleteTerm(term['term']),
                                        child: const Text(
                                          'ลบ',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
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