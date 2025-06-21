package prova_graphl.konfort.resolvers.mutations;

import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.stereotype.Controller;
import prova_graphl.konfort.models.dto.CalibrationDataInput;
import prova_graphl.konfort.models.dto.CalibrationDataPayload;
import prova_graphl.konfort.models.dto.SaveCalibrationDataInput;
import prova_graphl.konfort.services.CalibrationDataService;

@Controller
public class CalibrationDataMutation {

    private final CalibrationDataService calibrationDataService;

    public CalibrationDataMutation(CalibrationDataService calibrationDataService) {
        this.calibrationDataService = calibrationDataService;
    }

    @MutationMapping
    public CalibrationDataPayload saveCalibrationData(
            @Argument SaveCalibrationDataInput input
            ) {

        return calibrationDataService.saveCalibrationData(input);
    }
}
