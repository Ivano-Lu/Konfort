# Database Migration for Calibration Data

## Problem
The login was failing due to a `MatrixConverter` error when trying to read `null` values from the database for the new calibration data fields.

## Solution
We've updated the converters and database schema to handle the new fields properly.

## Steps to Apply Migration

### 1. Stop the Backend Application
```bash
# Stop your Spring Boot application if it's running
```

### 2. Apply Database Migration
Run the SQL migration script on your database:

```sql
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
```

### 3. Restart the Backend Application
```bash
# Start your Spring Boot application
./gradlew bootRun
```

## Changes Made

### Backend Changes:
1. **MatrixConverter.java** - Added null handling
2. **VectorConverter.java** - New converter for List<Double> fields
3. **CalibrationData.java** - Updated entity with new fields and proper converters
4. **CalibrationDataService.java** - Added null handling in mapping
5. **AuthenticationServiceImplementation.java** - Better error handling
6. **schema.graphqls** - Made new fields optional for backward compatibility

### App Changes:
1. **CalibrationService.swift** - Handle optional fields with defaults
2. **LoginViewModel.swift** - Handle optional fields with defaults

## Verification
After applying the migration:
1. Try logging in with existing user credentials
2. The login should work without errors
3. If the user has calibration data, it should load properly
4. If the user doesn't have calibration data, login should still work

## Notes
- The new fields are optional in GraphQL schema for backward compatibility
- Default values are provided for missing fields
- Existing calibration data will continue to work
- New calibration data will include all fields 