package prova_graphl.konfort.models.dao;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@ToString(exclude = "calibrationData")
@EqualsAndHashCode(exclude = "calibrationData")
@Entity
@Table (name = "Users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String surname;
    private String email;
    private String password;

    @OneToMany(mappedBy = "user")
    private List<Session> sessions;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL)
    @JsonManagedReference
    private CalibrationData calibrationData;
}
