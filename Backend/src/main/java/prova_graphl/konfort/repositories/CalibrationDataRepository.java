package prova_graphl.konfort.repositories;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import org.springframework.data.jpa.repository.JpaRepository;
import com.vladmihalcea.hibernate.type.json.JsonBinaryType;
import org.hibernate.annotations.Type;
import prova_graphl.konfort.models.dao.CalibrationData;
import prova_graphl.konfort.models.dao.User;

import java.util.Optional;


public interface CalibrationDataRepository extends JpaRepository<CalibrationData, Long> {
    Optional<CalibrationData> findByUser(User user);
    Optional<CalibrationData> findByUserId(Long userId);
}
