package prova_graphl.konfort.services;

import org.springframework.stereotype.Service;
import prova_graphl.konfort.models.dao.CalibrationData;
import prova_graphl.konfort.models.dao.User;
import prova_graphl.konfort.models.dto.CalibrationDataInput;
import prova_graphl.konfort.models.dto.CalibrationDataPayload;
import prova_graphl.konfort.models.dto.SaveCalibrationDataInput;
import prova_graphl.konfort.repositories.CalibrationDataRepository;
import prova_graphl.konfort.repositories.UserRepository;

import java.util.List;
import java.util.Optional;

@Service
public class CalibrationDataService {

    private final CalibrationDataRepository calibrationDataRepository;
    private final UserRepository userRepository;

    public CalibrationDataService(CalibrationDataRepository calibrationDataRepository, UserRepository userRepository) {
        this.calibrationDataRepository = calibrationDataRepository;
        this.userRepository = userRepository;
    }

    public CalibrationDataPayload saveCalibrationData(SaveCalibrationDataInput input) {
        User user = userRepository.findById(input.getUserId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        Optional<CalibrationData> existingOpt = calibrationDataRepository.findByUser(user);
        CalibrationData entity = existingOpt.orElse(new CalibrationData());

        CalibrationDataInput dataInput = input.getCalibrationData();

        // Set accelerometer data
        entity.setAccMatrix(dataInput.getAccMatrix());
        entity.setAccInvertedMatrix(dataInput.getAccInvertedMatrix());
        entity.setAccDeterminant(dataInput.getAccDeterminant());
        entity.setAccVMedia(dataInput.getAccVMedia());
        entity.setAccSigma(dataInput.getAccSigma());
        entity.setAccThreshold(dataInput.getAccThreshold());
        
        // Set magnetometer data
        entity.setMagMatrix(dataInput.getMagMatrix());
        entity.setMagInvertedMatrix(dataInput.getMagInvertedMatrix());
        entity.setMagDeterminant(dataInput.getMagDeterminant());
        entity.setMagVMedia(dataInput.getMagVMedia());
        entity.setMagSigma(dataInput.getMagSigma());
        entity.setMagThreshold(dataInput.getMagThreshold());
        
        entity.setUser(user);

        CalibrationData saved = calibrationDataRepository.save(entity);

        return mapToPayload(saved);
    }

    public CalibrationDataPayload fetchCalibrationData(Long userId) {
        System.out.println("🔍 Fetching calibration data for user ID: " + userId);
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + userId));

        System.out.println("✅ User found: " + user.getEmail());

        Optional<CalibrationData> dataOpt = calibrationDataRepository.findByUser(user);
        
        if (dataOpt.isEmpty()) {
            System.out.println("❌ No calibration data found for user: " + userId);
            throw new RuntimeException("CalibrationData not found for user: " + userId);
        }

        CalibrationData data = dataOpt.get();
        System.out.println("✅ Calibration data found with ID: " + data.getId());
        System.out.println("📊 Acc matrix size: " + (data.getAccMatrix() != null ? data.getAccMatrix().size() : "null"));
        System.out.println("📊 Mag matrix size: " + (data.getMagMatrix() != null ? data.getMagMatrix().size() : "null"));

        CalibrationDataPayload payload = mapToPayload(data);
        System.out.println("✅ Calibration data mapped successfully");
        
        return payload;
    }

    public Optional<CalibrationData> getCalibrationDataByUserId(Long userId) {
        return calibrationDataRepository.findByUserId(userId);
    }

    public CalibrationDataPayload mapToPayload(CalibrationData entity) {
        System.out.println("🔄 Mapping CalibrationData entity to payload...");
        
        CalibrationDataPayload payload = new CalibrationDataPayload();
        payload.setId(entity.getId());
        
        // Set accelerometer data (handle null values)
        payload.setAccMatrix(entity.getAccMatrix());
        payload.setAccInvertedMatrix(entity.getAccInvertedMatrix());
        payload.setAccDeterminant(entity.getAccDeterminant());
        payload.setAccVMedia(entity.getAccVMedia() != null ? entity.getAccVMedia() : List.of(0.0, 0.0, 0.0));
        payload.setAccSigma(entity.getAccSigma() != null ? entity.getAccSigma() : List.of(0.0, 0.0, 0.0));
        payload.setAccThreshold(entity.getAccThreshold() != null ? entity.getAccThreshold() : 0.0);
        
        // Set magnetometer data (handle null values)
        payload.setMagMatrix(entity.getMagMatrix());
        payload.setMagInvertedMatrix(entity.getMagInvertedMatrix());
        payload.setMagDeterminant(entity.getMagDeterminant());
        payload.setMagVMedia(entity.getMagVMedia() != null ? entity.getMagVMedia() : List.of(0.0, 0.0, 0.0));
        payload.setMagSigma(entity.getMagSigma() != null ? entity.getMagSigma() : List.of(0.0, 0.0, 0.0));
        payload.setMagThreshold(entity.getMagThreshold() != null ? entity.getMagThreshold() : 0.0);
        
        System.out.println("📊 Mapped payload - Acc matrix: " + (payload.getAccMatrix() != null ? payload.getAccMatrix().size() : "null") + 
                          ", Mag matrix: " + (payload.getMagMatrix() != null ? payload.getMagMatrix().size() : "null"));
        
        return payload;
    }
}

