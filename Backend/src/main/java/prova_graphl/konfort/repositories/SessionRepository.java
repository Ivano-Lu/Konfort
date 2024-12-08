package prova_graphl.konfort.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import prova_graphl.konfort.models.dao.Session;

import java.util.Optional;

public interface SessionRepository extends JpaRepository<Session, Long> {
    Optional<Session> findByRefreshToken(String refreshToken);
}
