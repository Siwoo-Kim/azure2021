FROM maven:3.3-jdk-8 as build
COPY src /usr/src/app/src/
COPY pom.xml /usr/src/app/pom.xml 
RUN mvn -f /usr/src/app/pom.xml clean install -DskipTests

FROM openjdk:11
COPY --from=build /usr/src/app/target/azure2021.jar /azure2021.jar

ENTRYPOINT ["java", "-cp", "azure2021.jar"]