# สถาปัตยฐานข้อมูลระบบยืมอุปกรณ์

## ภาพรวมทั่วไป

ระบบยืมอุปกรณ์ใช้สถาปัตยฐานข้อมูลแบบ Relational Database ด้วย MySQL ออกแบบตารางหลายๆที่เชื่อมต่อกันเพื่อจัดการข้อมูลอย่างมีประสิทธิภาพ

## ตารางหลักๆ

### 1. ตาราง `users`
จัดเก็บข้อมูลผู้ใช้ในระบบ

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**คำอธิบายฟิลด์:**
- `id`: Primary Key ระบุนแบบักข้อมูลผู้ใช้
- `username`: ชื่อผู้ใช้สำหรับ Login (Unique)
- `password`: รหัสผ่านที่ถูก hash ด้วย `password_hash()`
- `role`: บทบาทผู้ใช้ (admin/user)
- `student_id`: รหัสนักศึกษา (Optional)
- `first_name`, `last_name`: ชื่อจริงและนามสกุล (Optional)
- `profile_image`: ชื่อไฟล์รูปโปรไฟล์ (Default: 'default.jpg')
- `created_at`: วันที่สร้างบัญชี

### 2. ตาราง `categories`
จัดเก็บหมวดหมู่ของอุปกรณ์

```sql
CREATE TABLE `categories` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(100) NOT NULL,
    `description` text NULL,
    `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**คำอธิบายฟิลด์:**
- `id`: Primary Key ระบุนแบบักข้อมูลหมวดหมู่
- `name`: ชื่อหมวดหมู่
- `description`: รายละเอียนของหมวดหมู่ (Optional)
- `created_at`: วันที่สร้างหมวดหมู่

### 3. ตาราง `equipment`
จัดเก็บข้อมูลอุปกรณ์ที่สามารถยืมได้

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
    FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**คำอธิบายฟิลด์:**
- `id`: Primary Key ระบุนแบบักข้อมูลอุปกรณ์
- `name`: ชื่ออุปกรณ์
- `description`: รายละเอียนอุปกรณ์
- `quantity`: จำนวนอุปกรณ์ที่มีพร้อมให้้ยืม
- `category_id`: Foreign Key อ้างตาราง `categories`
- `image`: ชื่อไฟล์รูปอุปกรณ์ (Default: 'default.jpg')
- `created_at`, `updated_at`: วันที่สร้างและอัปเดตล่าสุด

### 4. ตาราง `borrowings`
จัดเก็บข้อมูลการยืม-คืนอุปกรณ์

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
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`equipment_id`) REFERENCES `equipment` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**คำอธิบายฟิลด์:**
- `id`: Primary Key ระบุนแบบักข้อมูลการยืม
- `user_id`: Foreign Key อ้างตาราง `users`
- `equipment_id`: Foreign Key อ้างตาราง `equipment`
- `quantity`: จำนวนที่ยืม
- `borrow_date`: วันที่ยืม
- `return_date`: วันที่คืน (NULL ถ้ายังไม่คืน)
- `status`: สถานะการยืม ('borrowed', 'returned')
- `approval_status`: สถานะการอนุมัติ ('pending', 'approved', 'rejected')
- `approved_by`: ผู้ที่อนุมัติ (Foreign Key อ้าง `users.id`)
- `approved_at`: วันเวลาที่อนุมัติ
- `rejection_reason`: เหตุผลการปฏิเสธ
- `created_at`: วันที่สร้างคำร้อง

## ความสัมพันธ์ (Constraints)

### Foreign Key Constraints
- `equipment.category_id` → `categories.id` (CASCADE DELETE/UPDATE)
- `borrowings.user_id` → `users.id` (CASCADE DELETE/UPDATE)
- `borrowings.equipment_id` → `equipment.id` (CASCADE DELETE/UPDATE)
- `borrowings.approved_by` → `users.id` (CASCADE DELETE/UPDATE)

### Unique Constraints
- `users.username`: ชื่อผู้ใช้ต้องไม่ซ้ำกัน

## การเชื่อมต่อกัน (Relationships)

```
users (1) ---- (N) borrowings
  - ผู้ใช้สามารถยืมได้หลายหลายอุปกรณ์
  - การลบผู้ใช้จะลบข้อมูล borrowing ทั้งหมด

categories (1) ---- (N) equipment
  - แต่ละหมวดหมู่มีหลายอุปกรณ์ได้
  - การลบหมวดหมู่จะลบอุปกรณ์ทั้งหมด

equipment (1) ---- (N) borrowings
  - แต่ละอุปกรณ์สามารถู่ยืมได้หลายครั้ง
  - การลบอุปกรณ์จะลบข้อมูล borrowing ทั้งหมด
```

## การอัปเดตตาราง (Alter Tables)

### เพิ่มคอลัมน์สำหรับระบบอนุมัติ
```sql
ALTER TABLE `borrowings` 
ADD COLUMN `approval_status` ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending' AFTER `status`,
ADD COLUMN `approved_by` INT(11) NULL AFTER `quantity`,
ADD COLUMN `approved_at` TIMESTAMP NULL AFTER `approval_status`,
ADD COLUMN `rejection_reason` TEXT NULL AFTER `approved_at`;
```

### เพิ่มข้อมูลนักศึกษา
```sql
ALTER TABLE `users` 
ADD COLUMN `student_id` VARCHAR(20) NULL AFTER `username`,
ADD COLUMN `first_name` VARCHAR(100) NULL AFTER `student_id`,
ADD COLUMN `last_name` VARCHAR(100) NULL AFTER `first_name`,
ADD COLUMN `profile_image` VARCHAR(255) NULL DEFAULT 'default.jpg' AFTER `last_name`;

CREATE INDEX `idx_student_id` ON `users` (`student_id`);
```

## การสร้าง Index

### Index ที่แนะนำอัตโนมี
```sql
-- Index สำหรับการค้นหาเร็วดว
CREATE INDEX `idx_student_id` ON `users` (`student_id`);

-- Index สำหรับการอนุมัติ
CREATE INDEX `idx_approval_status` ON `borrowings` (`approval_status`);
CREATE INDEX `idx_approved_by` ON `borrowings` (`approved_by`);
CREATE INDEX `idx_borrow_date` ON `borrowings` (`borrow_date`);
CREATE INDEX `idx_user_borrowing` ON `borrowings` (`user_id`, `status`);

-- Index สำหรับการค้นหาอุปกรณ์
CREATE INDEX `idx_equipment_name` ON `equipment` (`name`);
CREATE INDEX `idx_category_id` ON `equipment` (`category_id`);
CREATE INDEX `idx_quantity` ON `equipment` (`quantity`);
```

## การสำรองข้อมูล

### Sample Data Insert Statements
```sql
-- แทรกข้อมูลหมวดหมู่
INSERT INTO `categories` (`name`, `description`) VALUES
('คอมพิวเตอร์', 'อุปกรณ์คอมพิวเตอร์'),
('อุปกรณ์สำนักง', 'อุปกรณ์สำหรับในการเรียน'),
('อุปกรณ์กีฬา', 'อุปกรณ์สำหรับในการกีฬา'),
('อุปกรณ์ทั่วไป', 'อุปกรณ์ทั่วไป');

-- แทรกข้อมูลอุปกรณ์
INSERT INTO `equipment` (`name`, `description`, `quantity`, `category_id`) VALUES
('Laptop Dell XPS 15', 'Laptop สำหรับงานนักศึกษา', 5, 1),
('Projector Epson EB-X41', 'Projector สำหรับการนำเสนอน', 3, 2),
('Camera Canon EOS 80D', 'กล้องถ่ายภาพถ สำหรับถ่ายภาพถ', 2, 1),
('Tablet iPad Air', 'Tablet สำหรับเรียนและค้นค้น', 4, 1);

-- แทรกข้อมูลผู้ใช้ Admin
INSERT INTO `users` (`username`, `password`, `role`, `first_name`, `last_name`) VALUES
('admin', password_hash('admin123'), 'admin', 'สมชชิช', 'ใจอนย์สมชิช');

-- แทรกข้อมูลผู้ใช้ทั่วไป
INSERT INTO `users` (`username`, `password`, `role`, `student_id`, `first_name`, `last_name`) VALUES
('student1', password_hash('student123'), 'user', '6401001', 'นายสมชิช', 'ใจอนย์สมิต'),
('student2', password_hash('student456'), 'user', '6401002', 'มานนาวสมิต', 'ใจอนย์สมิต');
```

## การทำงานกับฐานข้อมูล

### การ Backup
```sql
-- Backup ทั้งหมด
mysqldump -u username -p equipment_borrowing > backup_$(date +%Y%m%d).sql

-- Backup เฉพาะตารางที่เลือก
mysqldump -u username -p equipment_borrowing users > backup_users_$(date +%Y%m%d).sql
```

### การ Restore
```sql
-- Restore จาก backup
mysql -u username -p equipment_borrowing < backup_20240101.sql

-- Restore เฉพาะตารางที่เลือก
mysql -u username -p equipment_borrowing < backup_users_20240101.sql
```

### การดูข้อมูล
```sql
-- ดูข้อมูลทั้งหมดในตาราง
SELECT * FROM users;
SELECT * FROM categories;
SELECT * FROM equipment;
SELECT * FROM borrowings;

-- ดูข้อมูลพร้อมรายละเอียน
SELECT u.username, e.name as equipment_name, b.quantity, b.borrow_date, b.status
FROM users u
JOIN borrowings b ON u.id = b.user_id
JOIN equipment e ON b.equipment_id = e.id;

-- ดูสถิติการยืมตามผู้ใช้
SELECT u.username, COUNT(*) as borrowing_count
FROM users u
JOIN borrowings b ON u.id = b.user_id
GROUP BY u.id
ORDER BY borrowing_count DESC;
```

## การปรับปรุงฐานข้อมูล

### เพิ่มฟิลด์ใหม่
1. สร้าง SQL script สำหรับเพิ่มคอลัมน์ใหม่
2. รัน script บนฐานข้อมูล
3. อัปเดด PHP code ใหม่เพื่อรองรับฟิลด์ใหม่
4. ทดสอบการทำงาน

### การเปลี่ยนชื่อตาราง
1. สร้าง script สำหรับเปลี่ยนชื่อตาราง
2. อัปเดด PHP code ที่เกี่ยวข้อง
3. รัน script และทดสอบ
4. อัปเดด Foreign Key constraints ถ้าจำเป็นน

### การเพิ่มฟิลด์ในตาราง
1. ใช้ `ALTER TABLE` เพิ่มคอลัมน์ใหม่
2. อัปเดด default value ถ้าจำเป็นน
3. ทดสอบว่าข้อมูลเดิมถูกต้อง
4. อัปเดด PHP code ที่เกี่ยวข้อง

---

**หมายเหตุถลมอออกแบบตารางฐานข้อมูลให้รองรับความประสิทธิภาพและมีประสิทธิภาพที่ดีที่สุดท้ายสำหรับระบบยืมอุปกรณ์** 🗄️
