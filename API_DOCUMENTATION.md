# API Documentation - ระบบข้อมูลฝึกประสบการณ์

## 🔧 การติดตั้ง API

### ขั้นตอนการวาง API ไฟล์:

1. **คัดลอกไฟล์ API ไปยัง XAMPP/LAMPP**
   - วางไฟล์ `internship_api.php` ในโฟลเดอร์ `htdocs/api_copy/`
   - โครงสร้างโฟลเดอร์:
     ```
     xampp/htdocs/api_copy/
     └── internship_api.php  (API รวมทั้งหมด)
     ```

2. **ตรวจสอบฐานข้อมูล**
   - ชื่อฐานข้อมูล: `cit0006_copy`
   - ตารางที่ต้องการ:
     - `term_intern` - ข้อมูลภาคการศึกษา (คอลัมน์: term)
     - `intern_company` - ข้อมูลฝึกประสบการณ์
     - `student` - ข้อมูลนักศึกษา (คอลัมน์: std_id, std_name)
     - `company` - ข้อมูลสถานประกอบการ (คอลัมน์: company_id, company_name, address)

---

## 📡 API Endpoints (Unified)

### Base URL:
```
http://localhost/api_copy/internship_api.php?action=ACTION
```

---

### 1. **GET - ดึงรายการภาคการศึกษา**
**URL:** `http://localhost/api_copy/internship_api.php?action=terms`

**Method:** GET

**Response:**
```json
[
  {"term": "2568-1"},
  {"term": "2568-2"}
]
```

---

### 2. **GET - ดึงข้อมูลฝึกประสบการณ์ทั้งหมด**
**URL:** `http://localhost/api_copy/internship_api.php?action=intern_company`

**Method:** GET

**Response:**
```json
[
  {
    "std_id": "001",
    "term": "2568-1",
    "type_intern": 1,
    "company_id": "C001",
    "contact_name": "นาย สมชาย",
    "contact_telno": "0812345678",
    "start_date": "2025-01-19",
    "end_date": "2025-05-19",
    "void": 0
  }
]
```

---

### 3. **GET - ดึงรายการนักศึกษา**
**URL:** `http://localhost/api_copy/internship_api.php?action=students`

**Method:** GET

**Response:**
```json
[
  {"std_id": "001", "std_name": "นัฐศน สังสิทธิ์"},
  {"std_id": "002", "std_name": "สมชาย ใจดี"}
]
```

---

### 4. **GET - ดึงรายการสถานประกอบการ**
**URL:** `http://localhost/api_copy/internship_api.php?action=companies`

**Method:** GET

**Response:**
```json
[
  {
    "company_id": "C001",
    "company_name": "บริษัท ABC จำกัด",
    "address": "123 ซอยโชคชัย ม.เก่า"
  }
]
```

---

### 5. **POST - เพิ่มข้อมูลฝึกประสบการณ์ใหม่**
**URL:** `http://localhost/api_copy/internship_api.php?action=add`

**Method:** POST

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "std_id": "001",
  "term": "2568-1",
  "type_intern": 1,
  "company_id": "C001",
  "contact_name": "นาย สมชาย",
  "contact_telno": "0812345678",
  "start_date": "2025-01-19",
  "end_date": "2025-05-19",
  "void": 0
}
```

**Response (Success - 200):**
```json
{
  "message": "Internship added successfully",
  "id": 1
}
```

**Response (Conflict - 409):**
```json
{
  "error": "Record already exists"
}
```

---

### 6. **POST - แก้ไขข้อมูลฝึกประสบการณ์**
**URL:** `http://localhost/api_copy/internship_api.php?action=update`

**Method:** POST

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "std_id": "001",
  "term": "2568-1",
  "type_intern": 2,
  "company_id": "C002",
  "contact_name": "นาย สมชาย",
  "contact_telno": "0812345678",
  "start_date": "2025-01-19",
  "end_date": "2025-05-19",
  "void": 0
}
```

**Response (Success - 200):**
```json
{
  "message": "Internship updated successfully"
}
```

---

### 7. **POST - ยกเลิกข้อมูลฝึกประสบการณ์**
**URL:** `http://localhost/api_copy/internship_api.php?action=cancel`

**Method:** POST

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "std_id": "001",
  "term": "2568-1"
}
```

**Response (Success - 200):**
```json
{
  "message": "Internship cancelled successfully"
}
```

---

## 📋 Database Schema (ตารางที่ต้องการ)

### Table: `intern_company`
```sql
CREATE TABLE `intern_company` (
  `std_id` varchar(10) NOT NULL,
  `term` varchar(6) NOT NULL,
  `type_intern` int(1) DEFAULT 1,
  `company_id` varchar(4) NOT NULL,
  `contact_name` varchar(50) DEFAULT NULL,
  `contact_telno` varchar(20) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `void` int(1) DEFAULT 0,
  PRIMARY KEY (`std_id`, `term`),
  FOREIGN KEY (`std_id`) REFERENCES `student`(`std_id`),
  FOREIGN KEY (`company_id`) REFERENCES `company`(`company_id`),
  FOREIGN KEY (`term`) REFERENCES `term_intern`(`term`)
);
```

### Table: `term_intern`
```sql
CREATE TABLE `term_intern` (
  `term` varchar(6) PRIMARY KEY,
  `term_name` varchar(50) DEFAULT NULL
);
```

### Table: `student`
```sql
CREATE TABLE `student` (
  `std_id` varchar(10) PRIMARY KEY,
  `std_name` varchar(100) NOT NULL,
  -- อื่นๆ
);
```

### Table: `company`
```sql
CREATE TABLE `company` (
  `company_id` varchar(4) PRIMARY KEY,
  `company_name` varchar(255) NOT NULL,
  `address` text,
  -- อื่นๆ
);
```

---

## 🔗 การใช้ใน Flutter App

ในไฟล์ Dart ใช้ URL เหล่านี้:

```dart
final String _baseUrl = "http://localhost/api_copy/internship_api.php";

// ตัวอย่าง GET
final response = await http.get(Uri.parse("$_baseUrl?action=terms"));

// ตัวอย่าง POST
final response = await http.post(
  Uri.parse("$_baseUrl?action=add"),
  headers: {"Content-Type": "application/json"},
  body: jsonEncode(data)
);
```

---

## 🐛 Troubleshooting

1. **Connection refused**
   - ตรวจสอบว่า XAMPP/LAMPP กำลังทำงาน
   - ตรวจสอบพอร์ต (ค่าเริ่มต้น 80 หรือ 8080)

2. **Database error**
   - ตรวจสอบชื่อฐานข้อมูล: `cit0006_copy`
   - ตรวจสอบ username/password ในไฟล์ PHP
   - ตรวจสอบชื่อคอลัมน์ตารางให้ตรงกับ schema

3. **CORS Error**
   - ไฟล์ API มี header CORS ให้แล้ว

4. **Data not showing**
   - ตรวจสอบว่าตารางมีข้อมูลจริงๆ หรือไม่
   - ใช้ `SELECT * FROM intern_company LIMIT 10;` เพื่อตรวจสอบ

---

## 📝 หมายเหตุ

- **void = 0** = ยังไม่ยกเลิก (ใช้งานปกติ)
- **void = 1** = ยกเลิกแล้ว (ซ่อน/ไม่แสดงในรายการ)
- **type_intern = 1** = ธรรมชาติ
- **type_intern = 2** = กิจกรรมสามารถ

---

## ✅ API Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - สำเร็จ |
| 400 | Bad Request - ข้อมูล input ไม่ถูกต้อง |
| 404 | Not Found - ไม่พบ endpoint |
| 409 | Conflict - ระเบียนซ้ำกัน |
| 500 | Server Error - ข้อผิดพลาดทางฐานข้อมูล |

