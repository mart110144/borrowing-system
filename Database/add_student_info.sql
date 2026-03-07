-- Add student information fields to users table
ALTER TABLE `users` 
ADD COLUMN `student_id` VARCHAR(20) NULL AFTER `username`,
ADD COLUMN `first_name` VARCHAR(100) NULL AFTER `student_id`,
ADD COLUMN `last_name` VARCHAR(100) NULL AFTER `first_name`,
ADD COLUMN `profile_image` VARCHAR(255) NULL DEFAULT 'default.jpg' AFTER `last_name`;

-- Add index for student_id for faster search
CREATE INDEX `idx_student_id` ON `users` (`student_id`);
