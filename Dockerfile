# Use a base image with a JDK and Maven
FROM maven:3.9.6-eclipse-temurin-17 as builder

# Set the working directory
WORKDIR /app

# Copy the Maven/Gradle build files and source code
COPY pom.xml .
COPY src ./src

# Build the application using Maven (adjust for Gradle if needed)
RUN mvn clean package -DskipTests

# Use a smaller JRE base image for the final stage
FROM eclipse-temurin:17-jre-jammy

# Set the working directory
WORKDIR /app

# Copy the JAR from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose the port your Spring Boot app listens on (default is 8080)
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]