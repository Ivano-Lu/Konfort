package prova_graphl.konfort.models.dao;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
public class Session{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", referencedColumnName = "id")
    private User user;
    private String accessToken;
    private String refreshToken;
    private boolean refreshTokenUsed;

}
