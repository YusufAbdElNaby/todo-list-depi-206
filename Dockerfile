# Multi-stage Optimized Dockerfile
# the first stage of our build will build and extract the layers
FROM maven:3.6.3-adoptopenjdk-11 as builder
LABEL maintainer="Yusuf Abd El-Nabi"
WORKDIR application
COPY ./pom.xml ./


# store maven dependencies so next build doesn't have to download them again
RUN mvn dependency:go-offline
COPY ./src ./src
RUN mvn package -DskipTests
# LAYERED JAR
ARG JAR_FILE=target/*.jar
RUN cp ${JAR_FILE} application.jar
RUN java -Djarmode=layertools -jar application.jar extract

# the second stage of our build will copy the extracted layers
FROM adoptopenjdk:11-jre-hotspot as runtime
WORKDIR application
COPY --from=builder application/dependencies/ ./
RUN true
COPY --from=builder application/spring-boot-loader/ ./
RUN true
COPY --from=builder application/snapshot-dependencies/ ./
RUN true
COPY --from=builder application/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]