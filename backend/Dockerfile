FROM openjdk:17-jdk-slim

COPY build/libs/*.jar app.jar

EXPOSE 8090

ENTRYPOINT ["java", "-jar", "/app.jar"]