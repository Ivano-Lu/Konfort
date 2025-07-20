package prova_graphl.konfort.models.dao;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.*;
import lombok.NoArgsConstructor;
import prova_graphl.konfort.converters.MatrixConverter;

import java.util.List;

@Getter
@Setter
@ToString(exclude = "user")
@EqualsAndHashCode(exclude = "user")
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "calibration_data")
public class CalibrationData {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Accelerometer calibration data
    @Convert(converter = MatrixConverter.class)
    @Column(columnDefinition = "TEXT")
    private List<List<Double>> accMatrix;

    @Convert(converter = MatrixConverter.class)
    @Column(columnDefinition = "TEXT")
    private List<List<Double>> accInvertedMatrix;

    private Double accDeterminant;

    // Magnetometer calibration data
    @Convert(converter = MatrixConverter.class)
    @Column(columnDefinition = "TEXT")
    private List<List<Double>> magMatrix;

    @Convert(converter = MatrixConverter.class)
    @Column(columnDefinition = "TEXT")
    private List<List<Double>> magInvertedMatrix;

    private Double magDeterminant;

    @OneToOne
    @JoinColumn(name = "user_id", unique = true)
    @JsonBackReference
    private User user;
}
