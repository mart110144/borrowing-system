-- เพิ่มคอลัมน์สำหรับรับอุปกรณ์ (QR Code)
-- สคริปต์นี้เพิ่มเฉพาะฟิลด์ใหม่ที่จำเป็นต้องสำหรับระบบ QR Code

-- เพิ่มคอลัมน์สำหรับการรับอุปกรณ์
ALTER TABLE `borrowings` 
ADD COLUMN `pickup_confirmed` TINYINT(1) NOT NULL DEFAULT 0 AFTER `approved_at`,
ADD COLUMN `pickup_time` TIMESTAMP NULL AFTER `pickup_confirmed`;

-- เพิ่ม Index สำหรับการค้นหาที่เร็วขึ้น
CREATE INDEX `idx_pickup_confirmed` ON `borrowings` (`pickup_confirmed`);
CREATE INDEX `idx_user_approval` ON `borrowings` (`user_id`, `approval_status`, `pickup_confirmed`);
