package prova_graphl.konfort.models.dto;

import lombok.Data;

import java.util.List;

@Data
public class CalibrationDataInput {
    // Accelerometer calibration data
    private List<List<Double>> accMatrix;
    private List<List<Double>> accInvertedMatrix;
    private Double accDeterminant;
    private List<Double> accVMedia;
    private List<Double> accSigma;
    private Double accThreshold;
    
    // Magnetometer calibration data
    private List<List<Double>> magMatrix;
    private List<List<Double>> magInvertedMatrix;
    private Double magDeterminant;
    private List<Double> magVMedia;
    private List<Double> magSigma;
    private Double magThreshold;
}
