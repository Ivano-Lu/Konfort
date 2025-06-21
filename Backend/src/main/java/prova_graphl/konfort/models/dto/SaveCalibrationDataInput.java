package prova_graphl.konfort.models.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SaveCalibrationDataInput {
    private Long userId;
    private CalibrationDataInput calibrationData;
}
