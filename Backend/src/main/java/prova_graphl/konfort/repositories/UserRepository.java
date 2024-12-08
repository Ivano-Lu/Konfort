package prova_graphl.konfort.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import prova_graphl.konfort.models.dao.User;

public interface UserRepository  extends JpaRepository<User,Long> {
    User findByEmail(String email);
}
