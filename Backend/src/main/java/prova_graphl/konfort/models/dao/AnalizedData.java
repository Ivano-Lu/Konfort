package prova_graphl.konfort.models.dao;

import lombok.*;
import prova_graphl.konfort.models.dto.IOData;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AnalizedData {
    private int userId;
    private int timestamp;
    private IOData accelerometer;
    private IOData magnetometer;
}
