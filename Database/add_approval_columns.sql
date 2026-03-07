-- Add approval status and admin approval fields to borrowings-- เพิ่มคอลัมน์สำหรับระบบอนุมัติและการรับอุปกรณ์
ALTER TABLE `borrowings` 
ADD COLUMN `approval_status` ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending' AFTER `status`,
ADD COLUMN `approved_by` INT(11) NULL AFTER `quantity`,
ADD COLUMN `approved_at` TIMESTAMP NULL AFTER `approval_status`,
ADD COLUMN `rejection_reason` TEXT NULL AFTER `approved_at`,
ADD COLUMN `pickup_confirmed` TINYINT(1) NOT NULL DEFAULT 0 AFTER `approved_at`,
ADD COLUMN `pickup_time` TIMESTAMP NULL AFTER `pickup_confirmed`;

-- เพิ่ม Foreign Key สำหรับ approved_by
ALTER TABLE `borrowings` 
ADD CONSTRAINT `fk_borrowings_approved_by` 
FOREIGN KEY (`approved_by`) REFERENCES `users`(`id`) 
ON DELETE SET NULL ON UPDATE CASCADE;

-- เพิ่ม Index สำหรับการค้นหาที่เร็วขึ้น
CREATE INDEX `idx_approval_status` ON `borrowings` (`approval_status`);
CREATE INDEX `idx_pickup_confirmed` ON `borrowings` (`pickup_confirmed`);
CREATE INDEX `idx_approved_by` ON `borrowings` (`approved_by`);
CREATE INDEX `idx_user_approval` ON `borrowings` (`user_id`, `approval_status`, `pickup_confirmed`);
