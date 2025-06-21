package prova_graphl.konfort.models.dto;

import lombok.Data;

import java.util.List;

@Data
public class CalibrationDataPayload {
    private Long id;
    private List<List<Double>> matrix;
    private List<List<Double>> invertedMatrix;
    private Double determinant;
}
