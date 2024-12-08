# Use the official OpenJDK 21 image as a base
FROM openjdk:21-jdk-slim

# Set the working directory in the container
WORKDIR /app

# Copy the JAR file into the container
COPY target/your-app.jar app.jar

# Expose the port your Spring Boot app will run on
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
