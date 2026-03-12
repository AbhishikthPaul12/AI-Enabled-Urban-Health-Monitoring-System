# MedAxis Health Manager - Spring Boot Deployment Guide

## Prerequisites
- Java 11 or higher
- Maven 3.6+
- Oracle Database 11g XE (running on localhost:1521:xe)
- Git (optional)

## Project Structure
```
Health-Manager/
├── pom.xml                          # Maven configuration
├── src/
│   ├── main/
│   │   ├── java/com/medaxis/
│   │   │   ├── HealthManagerApplication.java
│   │   │   ├── config/DatabaseConfig.java
│   │   │   └── servlet/             # All servlets
│   │   ├── resources/
│   │   │   └── application.properties
│   │   └── webapp/                  # JSP files, HTML, CSS
│   └── test/
└── DEPLOYMENT.md                    # This file
```

## Database Setup
1. Start Oracle Database
2. Run the schema creation scripts (if not already done)
3. Verify connection: `jdbc:oracle:thin:@localhost:1521:xe`

## Deployment Steps

### Option 1: Run with Spring Boot (Embedded Tomcat)
```bash
# Navigate to project directory
cd Health-Manager

# Build the project
mvn clean package

# Run with Spring Boot
mvn spring-boot:run
```

Access the application at: `http://localhost:7070/Health-Manager/`

### Option 2: Deploy to External Tomcat
```bash
# Build WAR file
mvn clean package

# Copy WAR to Tomcat webapps directory
copy target/Health-Manager-1.0.0.war "C:\Program Files\Apache Software Foundation\Tomcat 9.0\webapps\"

# Start Tomcat
```

Access the application at: `http://localhost:7070/Health-Manager-1.0.0/`

## Test Accounts
| Role | Email | Password |
|------|-------|----------|
| Admin | admin@test.com | test123 |
| Doctor | doctor@test.com | test123 |
| User | (register new) | - |

## Features
- **Role-Based Access Control**: Admin, Doctor, Patient roles
- **User Management**: CRUD operations (Admin)
- **Health Tracking**: BMI, Steps, Heart Rate
- **Appointments**: Book with doctors
- **Medical History**: Prescriptions & Advice
- **AI Assistant**: Health recommendations
- **Dark Mode**: UI theme toggle

## Troubleshooting
1. **Database Connection Error**: Verify Oracle is running and credentials are correct
2. **Port 8080 in use**: Change `server.port` in application.properties
3. **JSP not rendering**: Ensure `tomcat-embed-jasper` dependency is included

## Session 8 Deliverables
- ✅ Integrated web application
- ✅ Spring Boot + Tomcat deployment
- ✅ Database connectivity
- ✅ Multi-role authentication
- ✅ Responsive UI with dark mode
