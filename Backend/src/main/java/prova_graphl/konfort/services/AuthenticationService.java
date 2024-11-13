package prova_graphl.konfort.services;

import prova_graphl.konfort.models.dto.LoginResponse;

public interface AuthenticationService {
    LoginResponse login(String username, String password) throws Exception;
    LoginResponse refresh(String refreshToken) throws Exception;
}
