package prova_graphl.konfort.resolvers.mutations;

import org.springframework.stereotype.Controller;
import prova_graphl.konfort.services.AnalizedDataService;

@Controller
public class DataMutation {
    private final AnalizedDataService analizedDataService;

    public DataMutation(AnalizedDataService analizedDataService) {
        this.analizedDataService = analizedDataService;
    }

}
