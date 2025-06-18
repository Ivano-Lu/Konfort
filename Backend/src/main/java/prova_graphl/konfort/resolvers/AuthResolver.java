package prova_graphl.konfort.resolvers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.stereotype.Controller;
import prova_graphl.konfort.models.dto.LoginResponse;
import prova_graphl.konfort.services.AuthenticationService;

@Controller
public class AuthResolver {

    @Autowired
    private final AuthenticationService authenticationService;


    public AuthResolver(AuthenticationService authenticationService) {
        this.authenticationService = authenticationService;
    }

    //controllo se l'utente esiste
    @MutationMapping
    public LoginResponse login (@Argument String email, @Argument String password) {
        try {
            return authenticationService.login(email, password);
        } catch (Exception e) {
            throw new RuntimeException("Login failed", e);
        }
    }

    @MutationMapping
    public LoginResponse refresh(@Argument String refreshToken){
        try {
            return authenticationService.refresh(refreshToken);
        } catch (Exception e) {
            throw new RuntimeException("Refresh failed", e);
        }
    }

}
