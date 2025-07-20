package prova_graphl.konfort.services;

import org.springframework.stereotype.Service;
import prova_graphl.konfort.models.dao.CalibrationData;
import prova_graphl.konfort.models.dao.User;
import prova_graphl.konfort.models.dto.CalibrationDataInput;
import prova_graphl.konfort.models.dto.CalibrationDataPayload;
import prova_graphl.konfort.models.dto.SaveCalibrationDataInput;
import prova_graphl.konfort.repositories.CalibrationDataRepository;
import prova_graphl.konfort.repositories.UserRepository;

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
        
        // Set magnetometer data
        entity.setMagMatrix(dataInput.getMagMatrix());
        entity.setMagInvertedMatrix(dataInput.getMagInvertedMatrix());
        entity.setMagDeterminant(dataInput.getMagDeterminant());
        
        entity.setUser(user);

        CalibrationData saved = calibrationDataRepository.save(entity);

        return mapToPayload(saved);
    }

    public CalibrationDataPayload fetchCalibrationData(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        CalibrationData data = calibrationDataRepository.findByUser(user)
                .orElseThrow(() -> new RuntimeException("CalibrationData not found"));

        return mapToPayload(data);
    }

    public Optional<CalibrationData> getCalibrationDataByUserId(Long userId) {
        return calibrationDataRepository.findByUserId(userId);
    }

    public CalibrationDataPayload mapToPayload(CalibrationData entity) {
        CalibrationDataPayload payload = new CalibrationDataPayload();
        payload.setId(entity.getId());
        
        // Set accelerometer data
        payload.setAccMatrix(entity.getAccMatrix());
        payload.setAccInvertedMatrix(entity.getAccInvertedMatrix());
        payload.setAccDeterminant(entity.getAccDeterminant());
        
        // Set magnetometer data
        payload.setMagMatrix(entity.getMagMatrix());
        payload.setMagInvertedMatrix(entity.getMagInvertedMatrix());
        payload.setMagDeterminant(entity.getMagDeterminant());
        
        return payload;
    }
}

