# Build stage
FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /build
COPY pom.xml .
# cache dependencies
RUN mvn -B -DskipTests dependency:go-offline


COPY src ./src
RUN mvn -B package -DskipTests


# Runtime stage
FROM eclipse-temurin:17-jdk-alpine
EXPOSE 8080
ENV APP_HOME /usr/src/app
WORKDIR $APP_HOME


# copy built jar
COPY --from=build /build/target/*.jar app.jar


ENTRYPOINT ["java","-jar","/usr/src/app/app.jar"]