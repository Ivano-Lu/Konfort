package prova_graphl.konfort.resolvers.queries;

import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;
import prova_graphl.konfort.models.dao.CalibrationData;
import prova_graphl.konfort.services.CalibrationDataService;

@Controller
public class CalibrationDataQuery {

    private final CalibrationDataService calibrationDataService;

    public CalibrationDataQuery(CalibrationDataService calibrationDataService) {
        this.calibrationDataService = calibrationDataService;
    }

    @QueryMapping
    public CalibrationData fetchCalibrationData(@Argument Long userId) {
        return calibrationDataService.getCalibrationDataByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Dati non trovati per userId: " + userId));
    }
}
