package prova_graphl.konfort.resolvers.mutations;

import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.stereotype.Controller;
import prova_graphl.konfort.models.dao.User;
import prova_graphl.konfort.models.dto.LoginResponse;
import prova_graphl.konfort.services.UserDetailsService;
import prova_graphl.konfort.utils.JwtTokenUtil;

@Controller
public class UserMutation {

    private final UserDetailsService userDetailsService;
    private final JwtTokenUtil jwtTokenUtil;

    public UserMutation(UserDetailsService userDetailsService, JwtTokenUtil jwtTokenUtil) {
        this.jwtTokenUtil = jwtTokenUtil;
        this.userDetailsService = userDetailsService;
    }

    @MutationMapping
    public User addUser(@Argument String name,@Argument String surname,@Argument String email,@Argument String password) {
        return userDetailsService.addUser(name, surname, email, password);
    }

}
