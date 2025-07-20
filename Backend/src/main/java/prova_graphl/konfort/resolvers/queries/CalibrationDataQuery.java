package prova_graphl.konfort.resolvers.queries;

import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;
import prova_graphl.konfort.models.dto.CalibrationDataPayload;
import prova_graphl.konfort.services.CalibrationDataService;

@Controller
public class CalibrationDataQuery {

    private final CalibrationDataService calibrationDataService;

    public CalibrationDataQuery(CalibrationDataService calibrationDataService) {
        this.calibrationDataService = calibrationDataService;
    }

    @QueryMapping
    public CalibrationDataPayload fetchCalibrationData(@Argument Long userId) {
        System.out.println("🔍 GraphQL query: fetchCalibrationData for userId: " + userId);
        try {
            CalibrationDataPayload result = calibrationDataService.fetchCalibrationData(userId);
            System.out.println("✅ GraphQL query successful, returning calibration data");
            return result;
        } catch (Exception e) {
            System.out.println("❌ GraphQL query failed: " + e.getMessage());
            throw e;
        }
    }
    
    @QueryMapping
    public String debugCalibrationData(@Argument Long userId) {
        System.out.println("🔍 Debug query: checking calibration data for userId: " + userId);
        try {
            var userOpt = calibrationDataService.getCalibrationDataByUserId(userId);
            if (userOpt.isPresent()) {
                var data = userOpt.get();
                return String.format("✅ Calibration data found - ID: %d, Acc matrix: %s, Mag matrix: %s", 
                    data.getId(),
                    data.getAccMatrix() != null ? data.getAccMatrix().size() + "x" + (data.getAccMatrix().isEmpty() ? "0" : data.getAccMatrix().get(0).size()) : "null",
                    data.getMagMatrix() != null ? data.getMagMatrix().size() + "x" + (data.getMagMatrix().isEmpty() ? "0" : data.getMagMatrix().get(0).size()) : "null");
            } else {
                return "❌ No calibration data found for user: " + userId;
            }
        } catch (Exception e) {
            return "❌ Error checking calibration data: " + e.getMessage();
        }
    }
}
