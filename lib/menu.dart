import 'package:cit0006/Special_project.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'listcompany.dart';
import 'liststudent.dart';
import 'user_model.dart';
import 'listspecialproject.dart';
import 'intern_term_list.dart'; // import หน้าแสดงภาคการศึกษา
import 'internship_detail.dart'; // import หน้าข้อมูลฝึกประสบการณ์
import 'daily_work_list.dart'; // import หน้าบันทึกปฏิบัติงาน
import 'intern_evaluations_list.dart'; // import หน้าประเมินผลสถานประกอบการ

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);

    final List<Map<String, dynamic>> menuItems = [
      {"title": "ภาคการศึกษา", "image": "images/term.png"}, // เพิ่มเมนูภาคการศึกษา
      {"title": "ข้อมูลฝึกประสบการณ์", "image": "images/student.png"}, // เพิ่มเมนูข้อมูลฝึกประสบการณ์
      {"title": "สถานประกอบการณ์", "image": "images/company.png"},
      {"title": "ข้อมูลนักศึกษา", "image": "images/student.png"},
      {"title": "ส่ง Resume", "image": "images/resume.png"},
      {"title": "เสนอสถานประกอบการณ์", "image": "images/selected_company.png"},
      {"title": "บันทึกปฏิบัติงาน", "image": "images/dailywork.png"},
      {"title": "ประเมินผลสถานประกอบการ","image": "images/dailywork.png"},
      {"title": "หัวข้อศึกษาพิเศษ", "image": "images/special_project.png"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("เมนูหลัก"),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Quit',
            onPressed: () {
              if (Platform.isAndroid || Platform.isIOS) {
                SystemNavigator.pop();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth;

            int crossAxisCount = (width < 400)
                ? 2
                : (width < 700)
                ? 3
                : 4;

            double fontSize = (width < 400)
                ? 12
                : (width < 700)
                ? 14
                : 16;

            return Padding(
              padding: const EdgeInsets.all(6.0),
              child: GridView.builder(
                scrollDirection: Axis.vertical,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return GestureDetector(
                    onTap: () {
                      if (index == 0) {
                        // ไปหน้าแสดงภาคการศึกษา
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => InternTermListPage(),
                          ),
                        );
                      } else if (index == 1) {
                        // ไปหน้าข้อมูลฝึกประสบการณ์
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const InternshipDetailPage(),
                          ),
                        );
                      } else if (index == 2) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ListCompanyPage(),
                          ),
                        );
                      } else if (index == 3) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ListStudentPage(),
                          ),
                        );
                      } else if (index == 6) {
                        // ไปหน้าบันทึกปฏิบัติงาน
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const DailyWorkListPage(),
                          ),
                        );
                      } else if (index == 7) {
                        // ไปหน้าประเมินผลสถานประกอบการ
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const InternEvaluationsListPage(),
                          ),
                        );
                      } else if (index == 8) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ListSpecialProjectPage(),
                          ),
                        );
                      }
                      // เพิ่มเติม: สามารถเพิ่ม else if สำหรับเมนูอื่นๆ ได้
                    },
                    child: Card(
                      color: const Color.fromARGB(255, 193, 203, 192),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 3,
                              child: FractionallySizedBox(
                                widthFactor: 0.6,
                                child: Image.asset(
                                  item['image'],
                                  fit: BoxFit.contain,
                                  // เพิ่ม errorBuilder กันกรณีรูปไม่มี
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: Text(
                                  item['title'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Card(
        margin: EdgeInsets.zero,
        color: const Color.fromARGB(255, 5, 122, 60),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${user.firstname} ${user.lastname}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      user.office_name ?? "-", // กัน error ถ้าค่าเป็น null
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.address ?? "-",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.telno ?? "-",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
