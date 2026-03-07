-- สร้างตารางสำหรับเก็บข้อมูลการยืมที่ถูกลบ (ถังขยะ)
CREATE TABLE IF NOT EXISTS deleted_borrowings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    original_id INT NOT NULL,                    -- ID เดิมของการยืม
    equipment_id INT NOT NULL,                  -- ID อุปกรณ์
    user_id INT NOT NULL,                       -- ID ผู้ยืม
    borrow_date DATETIME NOT NULL,               -- วันที่ยืม
    return_date DATETIME NULL,                   -- วันที่คืน
    status ENUM('borrowed', 'returned') NOT NULL, -- สถานะการยืม
    approval_status ENUM('pending', 'approved', 'rejected') NOT NULL, -- สถานะการอนุมัติ
    pickup_confirmed TINYINT(1) DEFAULT 0,     -- การยืนยันการรับ
    pickup_time DATETIME NULL,                  -- เวลาที่รับ
    approved_by INT NULL,                       -- ผู้อนุมัติ
    approved_at DATETIME NULL,                   -- เวลาอนุมัติ
    deleted_at DATETIME NOT NULL,                -- เวลาที่ลบ
    deleted_by INT NOT NULL,                     -- ผู้ที่ลบ
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes
    INDEX idx_original_id (original_id),
    INDEX idx_equipment_id (equipment_id),
    INDEX idx_user_id (user_id),
    INDEX idx_deleted_at (deleted_at),
    INDEX idx_deleted_by (deleted_by),
    
    -- Foreign Keys
    FOREIGN KEY (equipment_id) REFERENCES equipment(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (deleted_by) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- เพิ่มคอลัมน์สำหรับตรวจสอบว่ามีข้อมูลในถังขยะหรือไม่
ALTER TABLE borrowings 
ADD COLUMN IF NOT EXISTS is_deleted TINYINT(1) DEFAULT 0 COMMENT '0=ไม่ถูกลบ, 1=ถูกลบ';

-- สร้าง view สำหรับดูข้อมูลการยืมที่ถูกลบ
CREATE OR REPLACE VIEW deleted_borrowings_view AS
SELECT 
    db.*,
    e.name as equipment_name,
    u.username as borrower_username,
    u.first_name as borrower_firstname,
    u.last_name as borrower_lastname,
    admin.username as deleted_by_username,
    admin.first_name as deleted_by_firstname,
    admin.last_name as deleted_by_lastname
FROM deleted_borrowings db
LEFT JOIN equipment e ON db.equipment_id = e.id
LEFT JOIN users u ON db.user_id = u.id
LEFT JOIN users admin ON db.deleted_by = admin.id
ORDER BY db.deleted_at DESC;
