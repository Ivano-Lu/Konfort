package prova_graphl.konfort.models.dto;

import lombok.Data;

import java.util.List;

@Data
public class CalibrationDataPayload {
    private Long id;
    
    // Accelerometer calibration data
    private List<List<Double>> accMatrix;
    private List<List<Double>> accInvertedMatrix;
    private Double accDeterminant;
    
    // Magnetometer calibration data
    private List<List<Double>> magMatrix;
    private List<List<Double>> magInvertedMatrix;
    private Double magDeterminant;
}
