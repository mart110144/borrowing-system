📁 Borrowing Management System/
├── 🎯 Core Application/
│   ├── admin_dashboard.php      # แดชบอร์ด admin
│   ├── manage_borrowings.php   # 🆕 จัดการการยืม-คืน
│   ├── approval_dashboard.php  # อนุมัติคำร้อง
│   ├── equipment.php           # จัดการอุปกรณ์
│   ├── admins.php              # จัดการสมาชิก
│   └── report_borrowing.php    # รายงาน
├── 👤 User Interface/
│   ├── user_dashboard.php      # แดชบอร์ดผู้ใช้
│   ├── profile.php             # โปรไฟล์ผู้ใช้
│   └── sidebar_user.php        # เมนูผู้ใช้
├── 📱 Advanced Features/
│   ├── qr_scan.php             # สแกน QR Code
│   ├── qr_pickup.php           # QR สำหรับรับ
│   └── calendar.php            # ปฏิทิน
├── 🗃️ Database/
│   ├── create_deleted_borrowings_table_fixed.sql
│   ├── add_approval_columns.sql
│   └── add_pickup_columns.sql
└── � Documentation/
    ├── README.md               # � เอกสารนี้
    ├── user_manual.md          # คู่มือผู้ใช้
    └── CONTRIBUTING.md         # แนวทางการมีส่วนร่วม
## ขั้นตอนการติดตั้ง

### 1. เตรียมสภาพแวดดาน
```bash
# Clone repository
git clone <repository-url>
cd borrowing-system

# สร้างฐานข้อมูล MySQL
mysql -u root -p
CREATE DATABASE equipment_borrowing;
USE equipment_borrowing;
source Database/db.sql;
```

### 2. กำหนดค่าฐานข้อมูล
แก้ไฟล์ `config.php` และอัปเดตข้อมูลการเชื่อมต่อฐาน:
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'equipment_borrowing');
define('DB_USER', 'username');
define('DB_PASS', 'password');
```

### 3. เริ่ม Web Server
```bash
# ใช้ XAMPP/WAMP/MAMP
# หรือ PHP Built-in Server
php -S localhost:8000

# หรือ Apache/Nginx
# วางไฟล์ใน Document Root
```

### 4. เข้าถึงระบบ
เปิดเบราวเซอร์ที่: `http://localhost/borrowing/login`

## โครงสร้าง

```
borrowing-system/
├── Database/
│   ├── db.sql                 # สคริปตารางฐานข้อมูล
│   ├── add_approval_columns.sql # คอลัมน์สำหรับระบบอนุมัติ
│   └── add_student_info.sql     # คอลัมน์ข้อมูลนักศึกษา
├── Uploads/
│   ├── equipment/             # รูปภาพอุปกรณ์
│   └── profiles/              # รูปโปรไฟล์ผู้ใช้
├── config.php                 # ค่าฐานข้อมูล
├── login.php                  # หน้าล็อกอิน
├── logout.php                 # หน้าออกจากระบบ
├── sidebar.php                # Sidebar สำหรับ Admin
├── sidebar_user.php          # Sidebar สำหรับ User
├── admin_dashboard.php        # แดชบอร์ด Admin
├── user_dashboard.php         # แดชบอร์ด User
├── approval_dashboard.php     # หน้าอนุมัติคำร้อง
├── equipment.php              # จัดการอุปกรณ์
├── admins.php                 # จัดการผู้ใช้
├── user_history.php           # ประวัติการยืม User
├── borrowing_dashboard.php     # สถิติการยืม
├── profile.php                # จัดการโปรไฟล์ User
├── user_manual.md             # คู่มือการใช้งาน
└── task.md                   # เอกสารโครงการ
```

## ฐานข้อมูล

### ตาราง Users
```sql
CREATE TABLE `users` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `username` varchar(50) NOT NULL,
    `password` varchar(255) NOT NULL,
    `role` enum('admin','user') NOT NULL DEFAULT 'user',
    `student_id` varchar(20) NULL,
    `first_name` varchar(100) NULL,
    `last_name` varchar(100) NULL,
    `profile_image` varchar(255) DEFAULT 'default.jpg',
    `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `username` (`username`)
);
```

### ตาราง Categories
```sql
CREATE TABLE `categories` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(100) NOT NULL,
    `description` text NULL,
    `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
);
```

### ตาราง Equipment
```sql
CREATE TABLE `equipment` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(255) NOT NULL,
    `description` text NULL,
    `quantity` int(11) NOT NULL DEFAULT 0,
    `category_id` int(11) NOT NULL,
    `image` varchar(255) DEFAULT 'default.jpg',
    `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
);
```

### ตาราง Borrowings
```sql
CREATE TABLE `borrowings` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `user_id` int(11) NOT NULL,
    `equipment_id` int(11) NOT NULL,
    `quantity` int(11) NOT NULL,
    `borrow_date` date NOT NULL,
    `return_date` date NULL,
    `status` enum('borrowed','returned') NOT NULL DEFAULT 'borrowed',
    `approval_status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
    `approved_by` int(11) NULL,
    `approved_at` timestamp NULL,
    `rejection_reason` text NULL,
    `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
    FOREIGN KEY (`equipment_id`) REFERENCES `equipment` (`id`)
);
```

## การใช้งานระบบ

### สำหรับนักศึกษา
1. **ล็อกอินเข้าระบบ** ด้วย username และ password
2. **ดูรายการอุปกรณ์** และสถานะที่มี
3. **ส่งคำร้องยืม** เลือกอุปกรณ์และจำนวน
4. **รอการอนุมัติ** จาก Admin อนุมัติคำร้อง
5. **รับอุปกรณ์** เมื่อได้รับการอนุมัติ
6. **คืนอุปกรณ์** เมื่อใช้งานเสร็จ

### สำหรับ Admin
1. **จัดการอุปกรณ์** เพิ่ม/แก้ไข/ลบ
2. **จัดการผู้ใช้** เพิ่ม/แก้ไข/ลบ
3. **อนุมัติคำร้อง** อนุมัติหรือปฏิเสธ
4. **ดูสถิติ** รายงานการใช้งานทั้งหมด

## ความปลอดภัย

- ✅ **Prepared Statements** ป้องกัน SQL Injection
- ✅ **Password Hashing** ใช้ `password_hash()` และ `password_verify()`
- ✅ **Session Management** ควบคุมสถานะการล็อกอิน
- ✅ **Input Validation** ตรวจสอบข้อมูลทุกครั้ง
- ✅ **CSRF Protection** ใช้ session tokens
- ✅ **XSS Prevention** ใช้ `htmlspecialchars()` และ `strip_tags()`

## เทคโนโลยีที่ใช้

- **PHP 8+**: ภาษาฝั่งฝั่ง
- **MySQL 8.0+**: ระบบจัดการข้อมูล
- **Tailwind CSS**: Framework CSS สำหรับการออกแบบ UI
- **jQuery**: JavaScript Library สำหรับ DOM Manipulation
- **jQuery Confirm**: สำหรับการแจ้งเตือนที่สวยงงาม
- **Animate.css**: Animation library สำหรับ UI Effects
- **Bootstrap Icons**: Icon library

## การปรับแต่งและพัฒนา

### การเพิ่มฟีเจอร์ใหม่
1. แก้ไฟล์ใน `Database/` สำหรับ feature ใหม่
2. อัปเดตตารางฐานข้อมูลตามต้องการ
3. สร้าง PHP Controller สำหรับจัดการ
4. สร้าง View และเพิ่ม JavaScript สำหรับ interaction
5. อัปเดต sidebar และ navigation

### การปรับแต่งฐานข้อมูล
1. สร้าง migration script ใหม่ `.sql` ไฟล์
2. อัปเดต `config.php` สำหรับการเชื่อมต่อฐานใหม่
3. รัน script เพื่ออัปเดตโครงสร้าง
4. ทดสอบการทำงานของฟีเจอร์ใหม่

## การ Deploy

### บน Local Development
```bash
# ใช้ XAMPP
1. ติดตั้ง XAMPP
2. วางไฟล์ใน `htdocs/borrowing/`
3. เปิด `http://localhost/borrowing`

# ใช้ Docker (แนะแนะ)
FROM php:8.0-apache
COPY . /var/www/html/
RUN docker-php-ext-install pdo_mysql
```

### บน Production Server
- อัปโหลดไปยังเซิร์ฟ์เวอร์ที่รองรับ PHP
- ตั้งค่า PHP memory limit และ execution time
- ใช้ HTTPS (SSL Certificate)
- ตั้งค่า MySQL ตามความการใช้งาน
- สำรอง Backup และ Recovery Plan

## การทดสอบ

### การทดสอบฟังก์ชัน
```bash
# ทดสอบ PHP Syntax
php -l filename.php

# ทดสอบ Database Connection
mysql -u username -p database_name

# ทดสอบ SQL Query
mysql -u username -p database_name -e "SELECT * FROM table"
```

### การทดสอบฟีเจอร์
- ทดสอบการ Login/Logout
- ทดสอบการ CRUD อุปกรณ์
- ทดสอบการยืม-คืน
- ทดสอบการอนุมัติ
- ทดสอบ responsive design

## License

โปรเจคนดภายให้้สัญญาต่อ MIT License

## ผู้พัฒนา

- [Developer Name] - Full Stack Developer
- [Email] - developer@example.com
- [GitHub] - https://github.com/username/borrowing-system

## ประวัติอัปเดต

- **Version 1.0** - ระบบพื้นฐานพร้อมฟีเจอร์พื้นฐาน
- **Version 1.1** - เพิ่มระบบอนุมัติคำร้อง
- **Version 1.2** - เพิ่มจัดการโปรไฟล์ผู้ใช้
- **Version 1.3** - ปรับปรุง UI และ UX ให้สวยงงามขึ้น
- **Version 1.4** - เพิ่มคู่มือการใช้งานและเอกสารสำหรับนักพัฒนา

---

**หมายเหตุถลมเพียงความความสำคัญและมาตรฐานที่ได้สร้างขึ้นมาเพื่อให้เป็นระบบที่สมบูรณม์และใช้งานได้อย่างง่าย** 🚀
