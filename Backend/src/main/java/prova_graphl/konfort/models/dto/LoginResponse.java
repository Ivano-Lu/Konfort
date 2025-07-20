package prova_graphl.konfort.models.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class LoginResponse {
    private String token;
    private String refreshToken;
    private Long userId;
    private CalibrationDataPayload calibrationData; // Aggiunto per includere i dati di calibrazione
}
