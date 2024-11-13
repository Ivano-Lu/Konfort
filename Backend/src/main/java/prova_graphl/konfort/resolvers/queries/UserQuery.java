package prova_graphl.konfort.resolvers.queries;

import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;
import prova_graphl.konfort.models.dao.User;
import prova_graphl.konfort.services.UserDetailsService;

@Controller
public class UserQuery {

    private final UserDetailsService userDetailsService;

    public UserQuery(UserDetailsService userDetailsService) {
        this.userDetailsService = userDetailsService;
    }

    @QueryMapping
    public User getUserById(@Argument Long id) {
        return userDetailsService.getUserById(id);
    }
}
