# 1. ETAPA DE CONSTRUCCIÓN (BUILD)
# Usamos una imagen base de Maven para compilar el código.
FROM maven:3.9-jdk-17 AS build
# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos de configuración de Maven (pom.xml)
COPY pom.xml .

# Descarga las dependencias (optimización de caché)
RUN mvn dependency:go-offline

# Copia el código fuente completo
COPY src /app/src

# Compila el proyecto, genera el WAR y omite los tests
RUN mvn clean package -DskipTests

# ----------------------------------------------------
# 2. ETAPA DE EJECUCIÓN (RUNTIME)
# Usamos una imagen base de Tomcat 10 (compatible con Jakarta EE 9/10)
FROM tomcat:10.1.18-jdk17-temurin

# Establece el puerto en el que escucha el contenedor (mapeo interno)
EXPOSE 8080

# Copia el WAR generado desde la etapa de 'build' al directorio de despliegue de Tomcat
# nmtelecom-1.0-SNAPSHOT es el nombre de tu WAR según tu pom.xml
COPY --from=build /app/target/nmtelecom-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/

# Comando de inicio: Tomcat se iniciará por defecto y cargará el WAR
CMD ["catalina.sh", "run"]
