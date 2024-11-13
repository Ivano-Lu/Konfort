package prova_graphl.konfort.resolvers.queries;

import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.QueryMapping;


import org.springframework.stereotype.Controller;
import prova_graphl.konfort.models.dao.AnalizedData;
import prova_graphl.konfort.services.AnalizedDataService;




import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Controller
public class DataResolver {

    private static final Logger logger = LoggerFactory.getLogger(DataResolver.class);

    private final AnalizedDataService analizedDataService;

    public DataResolver(AnalizedDataService analizedDataService) {
        this.analizedDataService = analizedDataService;
    }

    @QueryMapping
    public AnalizedData getAnalizedDataById(@Argument Integer id) {
        return analizedDataService.getAnalizedDataById(id).orElse(null);
    }
}
