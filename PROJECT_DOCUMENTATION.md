# MedAxis Health Manager
## Integrated DBMS + Web Technologies Project
### Academic Year 2025-26

---

## 1. PROJECT OVERVIEW

### 1.1 Project Title
**MedAxis Health Manager** - An AI-Powered Health Monitoring System

### 1.2 Project Domain
Healthcare Management System with Role-Based Access Control

### 1.3 Technologies Used

| Category | Technologies |
|----------|-------------|
| **Frontend** | HTML5, CSS3, JavaScript, Bootstrap 5.3, Chart.js |
| **Backend** | Java Servlets, JSP, Spring Boot 2.7.14 |
| **Database** | Oracle 11g XE, JDBC |
| **Web Server** | Apache Tomcat 9.0 (Embedded & External) |
| **Security** | SHA-256 Password Hashing, Session Management |
| **Build Tool** | Maven 3.6+ |

### 1.4 Project Objectives
1. Develop a comprehensive health management platform
2. Implement role-based access control (Admin/Doctor/Patient)
3. Integrate database operations with web interface
4. Demonstrate CRUD operations and complex queries
5. Showcase modern web development practices

---

## 2. SYSTEM ARCHITECTURE

### 2.1 Architecture Diagram
```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Admin   │  │  Doctor  │  │  Patient │  │  Guest   │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
└───────┼─────────────┼─────────────┼─────────────┼──────────┘
        │             │             │             │
        └─────────────┴──────┬──────┴─────────────┘
                             │
┌────────────────────────────┼────────────────────────────────┐
│                    WEB LAYER│                               │
│  ┌─────────────────────────┴─────────────────────────────┐  │
│  │           Spring Boot + Embedded Tomcat                │  │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │  │
│  │  │   Servlets  │ │     JSP     │ │   Filters   │      │  │
│  │  └─────────────┘ └─────────────┘ └─────────────┘      │  │
│  └─────────────────────────────────────────────────────────┘  │
└────────────────────────────┬────────────────────────────────┘
                             │
┌────────────────────────────┼────────────────────────────────┐
│              DATABASE LAYER│                                 │
│  ┌─────────────────────────┴─────────────────────────────┐  │
│  │              Oracle Database 11g XE                    │  │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐     │  │
│  │  │  USERS  │ │ FITNESS │ │APPOINTMT│ │PROFILE  │     │  │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘     │  │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐                 │  │
│  │  │PRESCRIPT│ │  ADVICE │ │  AI_LOG │                 │  │
│  │  └─────────┘ └─────────┘ └─────────┘                 │  │
│  └─────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘
```

### 2.2 Database Schema

#### USERS Table
| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| USER_ID | NUMBER | PRIMARY KEY, AUTO_INCREMENT | Unique user identifier |
| NAME | VARCHAR2(100) | NOT NULL | Full name |
| EMAIL | VARCHAR2(100) | UNIQUE, NOT NULL | Login email |
| PASSWORD | VARCHAR2(100) | NOT NULL | SHA-256 hashed password |
| ROLE | VARCHAR2(20) | CHECK (admin/doctor/user) | User role |
| CREATED_AT | TIMESTAMP | DEFAULT SYSDATE | Registration date |

#### FITNESS_DATA Table
| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| FITNESS_ID | NUMBER | PRIMARY KEY | Record ID |
| USER_ID | NUMBER | FOREIGN KEY | Reference to USERS |
| HEIGHT | NUMBER | | Height in cm |
| WEIGHT | NUMBER | | Weight in kg |
| STEPS | NUMBER | | Daily step count |
| HEART_RATE | NUMBER | | Heart rate BPM |
| TIMESTAMP | TIMESTAMP | DEFAULT SYSDATE | Record date |

#### APPOINTMENT Table
| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| APPOINTMENT_ID | NUMBER | PRIMARY KEY | Appointment ID |
| USER_ID | NUMBER | FOREIGN KEY | Patient reference |
| DOCTOR_NAME | VARCHAR2(100) | | Doctor name |
| APPOINTMENT_DATE | DATE | | Scheduled date |
| STATUS | VARCHAR2(20) | DEFAULT 'Pending' | Appointment status |

#### PRESCRIPTIONS Table
| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| PRESCRIPTION_ID | NUMBER | PRIMARY KEY | Prescription ID |
| DOCTOR_ID | NUMBER | FOREIGN KEY | Doctor reference |
| PATIENT_ID | NUMBER | FOREIGN KEY | Patient reference |
| MEDICATION | VARCHAR2(200) | | Medicine name |
| DOSAGE | VARCHAR2(100) | | Dosage instructions |
| INSTRUCTIONS | CLOB | | Additional notes |
| CREATED_AT | TIMESTAMP | DEFAULT SYSDATE | Issue date |

#### MEDICAL_ADVICE Table
| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| ADVICE_ID | NUMBER | PRIMARY KEY | Advice ID |
| DOCTOR_ID | NUMBER | FOREIGN KEY | Doctor reference |
| PATIENT_ID | NUMBER | FOREIGN KEY | Patient reference |
| CATEGORY | VARCHAR2(50) | | Advice category |
| PRIORITY | VARCHAR2(20) | | Priority level |
| ADVICE_TEXT | CLOB | | Detailed advice |
| CREATED_AT | TIMESTAMP | DEFAULT SYSDATE | Date issued |

---

## 3. MODULES & FEATURES

### 3.1 Authentication Module
- **Registration**: New user signup with role selection
- **Login**: Secure authentication with SHA-256 hashing
- **Session Management**: 30-minute session timeout
- **Password Recovery**: Email-based password reset
- **Role-Based Redirection**: Auto-redirect based on user role

### 3.2 Admin Module
| Feature | Description |
|---------|-------------|
| Dashboard | System statistics (Users, Doctors, Appointments) |
| User Management | View, edit roles, delete user accounts |
| Analytics | System usage charts and reports |
| Data Export | Download system reports |

### 3.3 Doctor Module
| Feature | Description |
|---------|-------------|
| Dashboard | Patient statistics and appointments |
| Appointments | View scheduled appointments |
| Patients | Patient list and history |
| Prescriptions | Write and view prescriptions |
| Medical Advice | Send and view medical advice |

### 3.4 Patient Module
| Feature | Description |
|---------|-------------|
| Dashboard | Health overview with BMI, steps, heart rate |
| Health Tracking | Log daily health metrics |
| Health Trends | Visual charts of health data |
| Appointments | Book appointments with doctors |
| Calendar | View appointment calendar |
| Medical History | View prescriptions and advice |
| AI Assistant | Health recommendations |
| Profile | Update personal information |

---

## 4. KEY IMPLEMENTATIONS

### 4.1 Security Implementation
```java
// SHA-256 Password Hashing
public static String hash(String password) {
    MessageDigest md = MessageDigest.getInstance("SHA-256");
    byte[] hash = md.digest(password.getBytes());
    return Base64.getEncoder().encodeToString(hash);
}
```

### 4.2 Session Filter
```java
// Session validation for protected routes
HttpSession session = request.getSession(false);
if(session == null || session.getAttribute("user_id") == null) {
    response.sendRedirect("index.html");
    return;
}
```

### 4.3 Database Connection Pooling
```java
// Spring Boot DataSource Configuration
@Bean
public DataSource dataSource() {
    DriverManagerDataSource ds = new DriverManagerDataSource();
    ds.setUrl("jdbc:oracle:thin:@localhost:1521:xe");
    ds.setUsername("abhi");
    ds.setPassword("ap1234");
    return ds;
}
```

---

## 5. USER INTERFACE

### 5.1 Design System
- **Primary Color**: #0066cc (Medical Blue)
- **Secondary Color**: #00a8e8 (Sky Blue)
- **Accent Color**: #00d4aa (Teal)
- **Font Family**: System fonts (Bootstrap default)
- **Dark Mode**: Full theme support with localStorage persistence

### 5.2 Responsive Layout
- **Sidebar Navigation**: Fixed left panel (250px)
- **Main Content**: Flexible grid system
- **Mobile Support**: Collapsible sidebar on small screens

### 5.3 UI Components
- Floating dark mode toggle (top-right)
- Toast notifications for actions
- Card-based dashboard layout
- Tabbed interfaces for complex data
- Interactive charts with Chart.js

---

## 6. DEPLOYMENT

### 6.1 Prerequisites
- Java 11 or higher
- Maven 3.6+
- Oracle Database 11g XE
- 4GB RAM minimum

### 6.2 Deployment Steps

#### Step 1: Database Setup
```sql
-- Start Oracle Database
-- Verify connection: jdbc:oracle:thin:@localhost:1521:xe
```

#### Step 2: Build Application
```bash
cd Health-Manager
mvn clean package
```

#### Step 3: Run Application
```bash
# Option A: Spring Boot (Embedded Tomcat)
mvn spring-boot:run

# Option B: External Tomcat
copy target/Health-Manager-1.0.0.war C:\Tomcat\webapps\
start Tomcat
```

#### Step 4: Access Application
- **URL**: http://localhost:7070/Health-Manager/
- **Test Accounts**:
  - Admin: admin@test.com / test123
  - Doctor: doctor@test.com / test123

### 6.3 Project Structure
```
Health-Manager/
├── pom.xml
├── src/
│   ├── main/
│   │   ├── java/com/medaxis/
│   │   │   ├── HealthManagerApplication.java
│   │   │   ├── config/
│   │   │   │   └── DatabaseConfig.java
│   │   │   └── servlet/
│   │   │       ├── LoginServlet.java
│   │   │       ├── RegisterServlet.java
│   │   │       ├── LogoutServlet.java
│   │   │       ├── ProfileServlet.java
│   │   │       ├── HealthServlet.java
│   │   │       ├── AppointmentServlet.java
│   │   │       ├── PrescriptionServlet.java
│   │   │       ├── AdviceServlet.java
│   │   │       ├── ForgotServlet.java
│   │   │       ├── AIServlet.java
│   │   │       └── PasswordHash.java
│   │   ├── resources/
│   │   │   └── application.properties
│   │   └── webapp/
│   │       ├── index.html
│   │       ├── register.html
│   │       ├── forgot.html
│   │       ├── dashboard.jsp
│   │       ├── health.jsp
│   │       ├── healthTrends.jsp
│   │       ├── appointment.jsp
│   │       ├── calendar.jsp
│   │       ├── profile.jsp
│   │       ├── ai.jsp
│   │       ├── patientMedicalHistory.jsp
│   │       ├── doctorDashboard.jsp
│   │       ├── doctorAppointments.jsp
│   │       ├── doctorPatients.jsp
│   │       ├── doctorPrescription.jsp
│   │       ├── doctorAdvice.jsp
│   │       ├── doctorViewPrescriptions.jsp
│   │       ├── doctorViewAdvice.jsp
│   │       ├── adminDashboard.jsp
│   │       ├── adminUsers.jsp
│   │       ├── dataAnalytics.jsp
│   │       ├── style.css
│   │       └── script.js
│   └── test/
└── PROJECT_DOCUMENTATION.md
```

---

## 7. TESTING STRATEGY

### 7.1 Test Cases

| Module | Test Case | Expected Result |
|--------|-----------|-----------------|
| Auth | Valid login | Redirect to role dashboard |
| Auth | Invalid login | Error message displayed |
| Auth | Registration | Account created, redirect to login |
| Admin | View users | User list displayed |
| Admin | Change role | Role updated in database |
| Doctor | Write prescription | Prescription saved |
| Doctor | View appointments | Appointment list displayed |
| Patient | Book appointment | Appointment created |
| Patient | Log health data | Data saved to FITNESS_DATA |
| Patient | View trends | Charts displayed correctly |

### 7.2 Test Accounts
| Role | Email | Password | Purpose |
|------|-------|----------|---------|
| Admin | admin@test.com | test123 | System management |
| Doctor | doctor@test.com | test123 | Medical operations |
| Patient | (register new) | - | Patient features |

---

## 8. PRESENTATION POINTS

### 8.1 Key Features to Demo
1. **Multi-Role Authentication** - Show login with different roles
2. **Health Tracking** - Log BMI, steps, heart rate
3. **Appointment System** - Book and view appointments
4. **Medical History** - Show prescriptions and advice
5. **Admin Controls** - User management and analytics
6. **Dark Mode** - Toggle between themes
7. **Responsive Design** - Show on different screen sizes

### 8.2 Technical Highlights
- Secure password hashing (SHA-256)
- Session-based authentication
- Database normalization (3NF)
- Spring Boot integration
- Embedded Tomcat deployment
- Role-based access control

### 8.3 Database Concepts Demonstrated
- Table relationships (1:N, N:M)
- Foreign key constraints
- Normalization
- Complex queries with JOINs
- Transaction management

---

## 9. CONCLUSION

### 9.1 Project Outcomes
- Successfully developed a full-stack health management system
- Implemented secure authentication and authorization
- Demonstrated database integration with web technologies
- Achieved responsive and modern UI design
- Deployed using Spring Boot and Tomcat

### 9.2 Future Enhancements
- Email notifications for appointments
- SMS alerts for medication
- Mobile app integration
- AI-powered health predictions
- Integration with wearable devices

### 9.3 Learning Outcomes
- Database design and normalization
- Web application development
- Security best practices
- Spring Boot framework
- Project deployment strategies

---

## 10. REFERENCES

1. Oracle Database Documentation
2. Spring Boot Reference Guide
3. Bootstrap 5 Documentation
4. Chart.js Documentation
5. Java Servlet Specification

---

**Project Team**: G. Shivani, G. Abhishikth Paul, C. Aaron Raj, B. Anish Reddy
**Guide**: Dr. S. Bhagya Rekha, Dr. M. Purnachary
**Institution**: Anurag University
**Date**: March 13th 2026
