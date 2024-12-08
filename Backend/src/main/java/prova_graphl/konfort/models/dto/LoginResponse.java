package prova_graphl.konfort.models.dto;

import lombok.Data;

@Data
public class LoginResponse {
    private String token;
    private String refreshToken;

    public LoginResponse (String token, String refreshToken) {
        this.token = token;
        this.refreshToken = refreshToken;
    }
}
