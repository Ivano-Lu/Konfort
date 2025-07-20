-- Migration script to add new calibration data fields
-- Run this script on your existing database

-- Add new columns for accelerometer calibration data
ALTER TABLE calibration_data 
ADD COLUMN acc_v_media TEXT,
ADD COLUMN acc_sigma TEXT,
ADD COLUMN acc_threshold DOUBLE PRECISION;

-- Add new columns for magnetometer calibration data
ALTER TABLE calibration_data 
ADD COLUMN mag_v_media TEXT,
ADD COLUMN mag_sigma TEXT,
ADD COLUMN mag_threshold DOUBLE PRECISION;

-- Update existing records to have default values (optional)
UPDATE calibration_data 
SET acc_v_media = '[0.0, 0.0, 0.0]',
    acc_sigma = '[0.0, 0.0, 0.0]',
    acc_threshold = 0.0,
    mag_v_media = '[0.0, 0.0, 0.0]',
    mag_sigma = '[0.0, 0.0, 0.0]',
    mag_threshold = 0.0
WHERE acc_v_media IS NULL; 