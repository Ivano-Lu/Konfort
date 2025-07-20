# Debug Calibration Data Retrieval

## Problem
The calibration data is being saved correctly but the retrieval is not working properly.

## Debug Steps

### 1. Check Database Migration
First, ensure the database migration has been applied:

```sql
-- Check if new columns exist
DESCRIBE calibration_data;

-- Should show these columns:
-- acc_v_media TEXT
-- acc_sigma TEXT  
-- acc_threshold DOUBLE PRECISION
-- mag_v_media TEXT
-- mag_sigma TEXT
-- mag_threshold DOUBLE PRECISION
```

### 2. Check Database Content
Query the database directly to see if data exists:

```sql
-- Check if calibration data exists for a user
SELECT * FROM calibration_data WHERE user_id = 1;

-- Check the structure of saved data
SELECT id, user_id, 
       acc_matrix, acc_inverted_matrix, acc_determinant,
       acc_v_media, acc_sigma, acc_threshold,
       mag_matrix, mag_inverted_matrix, mag_determinant,
       mag_v_media, mag_sigma, mag_threshold
FROM calibration_data;
```

### 3. Test Backend Logs
Start the backend and check the console logs:

```bash
./gradlew bootRun
```

Look for these log messages:
- `🔍 Fetching calibration data for user ID: X`
- `✅ User found: email@example.com`
- `✅ Calibration data found with ID: X`
- `📊 Acc matrix size: X, Mag matrix size: X`
- `✅ Calibration data mapped successfully`

### 4. Test GraphQL Query
Use the debug query to check calibration data:

```graphql
query DebugCalibrationData($userId: ID!) {
  debugCalibrationData(userId: $userId)
}
```

Variables:
```json
{
  "userId": "1"
}
```

### 5. Test App Debug
In the app, call the debug method:

```swift
// In CalibrationViewModel
debugCalibrationData()
```

This will show the debug result in the calibration status.

### 6. Check App Logs
Look for these log messages in the app:
- `📦 JSON response from backend: ...`
- `✅ Calibration data found in response`
- `📊 Calibration data keys: ...`
- `✅ All calibration data extracted successfully`

## Common Issues

### Issue 1: "CalibrationData not found"
- **Cause**: No calibration data exists for the user
- **Solution**: Run a calibration first to create data

### Issue 2: "User not found"
- **Cause**: User ID doesn't exist in database
- **Solution**: Check if user exists in Users table

### Issue 3: "Invalid calibration data format"
- **Cause**: Data structure mismatch between backend and app
- **Solution**: Check if all required fields are present

### Issue 4: "MatrixConverter error"
- **Cause**: Null values in database fields
- **Solution**: Apply database migration and set default values

## Expected Flow

1. **Save**: App saves calibration data → Backend stores in `calibration_data` table
2. **Login**: Backend fetches calibration data → Returns in `LoginResponse`
3. **Fetch**: App calls `fetchCalibrationData` → Backend queries database → Returns data
4. **Load**: App receives data → Converts to `CalibrationResult` → Stores in `CalibrationDataStore`

## Verification Commands

### Backend Verification
```bash
# Check if backend is running
curl -X POST http://localhost:8080/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"query { debugCalibrationData(userId: \"1\") }"}'
```

### Database Verification
```sql
-- Check if data exists
SELECT COUNT(*) FROM calibration_data;

-- Check data structure
SELECT * FROM calibration_data LIMIT 1;
```

### App Verification
- Check console logs for debug messages
- Verify `CalibrationDataStore.shared.hasCalibrationData()` returns `true`
- Check if calibration data is displayed in the UI 