package prova_graphl.konfort.utils;

import org.json.JSONObject;

public class GraphQLUtil {


    public static String extractOperationName(String requestBody) {
        JSONObject jsonObject = new JSONObject(requestBody);
        String operationName = jsonObject.getString("operationName");
        String query = jsonObject.getString("query");

        String[] lines = query.split("\\n");
        boolean isOperation = false;

        for (String line : lines) {
            line = line.trim();
            if (line.startsWith("mutation") || line.startsWith("query")) {
                String[] parts = line.split("\\s+");

                //continua da qua, parts1 ha la parentesi graffa attaccata -> sistemare
                System.out.println(parts[1]);
                if (parts.length > 1 && parts[1].equals(operationName)) {
                    isOperation = true;
                }
            } else if (isOperation) {
                String[] parts = line.split("\\s+");
                if (parts.length > 0) {
                    return parts[0]; // Return the name of the mutation or query
                }
            }
        }
        return null;
    }
}
