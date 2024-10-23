# Usa una imagen base de OpenJDK para compilar y ejecutar
FROM openjdk:17-jdk-slim AS builder

# Instala Maven
RUN apt-get update && apt-get install -y maven

# Crea un directorio de trabajo
WORKDIR /app

# Copia el archivo pom.xml y descarga las dependencias necesarias (esto se cachea si el pom.xml no cambia)
COPY pom.xml .

RUN mvn dependency:go-offline

# Copia el código fuente de la aplicación
COPY src ./src

# Compila la aplicación con Maven
RUN mvn clean install -DskipTests

# Usa una imagen más ligera de OpenJDK para ejecutar
FROM openjdk:17-jdk-slim

WORKDIR /app

# Copia el JAR generado desde la imagen builder
COPY --from=builder /app/target/*.jar app.jar

# Expone el puerto de la aplicación
EXPOSE 8080

# Comando para ejecutar la aplicación
ENTRYPOINT ["java", "-jar", "/app.jar"]
