package prova_graphl.konfort.converters;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

import java.io.IOException;
import java.util.List;

@Converter

public class MatrixConverter implements AttributeConverter<List<List<Double>>, String> {
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    public String convertToDatabaseColumn(List<List<Double>> attribute) {
        try {
            return mapper.writeValueAsString(attribute);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Could not convert matrix to JSON", e);
        }
    }

    @Override
    public List<List<Double>> convertToEntityAttribute(String dbData) {
        try {
            return mapper.readValue(dbData, new TypeReference<List<List<Double>>>() {});
        } catch (IOException e) {
            throw new RuntimeException("Could not convert JSON to matrix", e);
        }
    }
}
