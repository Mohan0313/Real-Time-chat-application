# Multi-stage Dockerfile for a Maven + Spring Boot (Java 17) app
# Stage 1: build
FROM maven:3.9.4-eclipse-temurin-17 AS build

WORKDIR /app

# Copy only the files needed to build, so Docker layer cache works better
COPY pom.xml mvnw ./
COPY .mvn .mvn
RUN chmod +x mvnw

# Copy sources
COPY src ./src

# Build the project (skip tests for faster build; remove -DskipTests if you want tests)
RUN ./mvnw -DskipTests -B package

# Stage 2: runtime
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Copy fat jar built by Spring Boot plugin
COPY --from=build /app/target/*.jar /app/app.jar

# Expose port (optional, Render sets PORT env var anyway)
EXPOSE 8080

# Use Render's PORT env var or default to 8080
ENV PORT 8080

# Start the Spring Boot app, passing Render's PORT so Spring binds to it
ENTRYPOINT ["sh", "-c", "java -Dserver.port=$PORT -jar /app/app.jar"]
