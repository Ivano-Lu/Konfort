package prova_graphl.konfort.services;

import org.springframework.stereotype.Service;
import prova_graphl.konfort.models.dao.AnalizedData;
import prova_graphl.konfort.models.dto.IOData;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Service
public class AnalizedDataService {
    private final Map<Integer, AnalizedData> dataStore  = new HashMap<>();

    public AnalizedDataService() {

        IOData accelerometer = new IOData(1, 2, 3);
        IOData magnetometer = new IOData(4, 5, 6);
        AnalizedData data = new AnalizedData(1,123456, accelerometer, magnetometer);
        dataStore.put(1, data);
    }

    public Optional<AnalizedData> getAnalizedDataById (Integer id) {
        return Optional.ofNullable((dataStore.get(id)));
    }

    public AnalizedData addAnalizedData(AnalizedData data){
        dataStore.put(data.getUserId(), data);
        return data;
    }

}
