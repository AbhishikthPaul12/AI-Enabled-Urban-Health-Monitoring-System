# AI-Enabled Urban Health Monitoring System
**Team**: G. Shivani, G. Abhishikth Paul, C. Aaron Raj, B. Anish Reddy  
**Faculty**: Dr. S. Bhagya Rekha, Dr. M. Purnachary  
**Institution**: Anurag University | **Date**: March 13th 2026

---

## SLIDE 1: Title & Introduction (3 min)
- **Project**: MedAxis Health Manager - AI-Powered Health Monitoring System
- **Problem**: Fragmented healthcare management, need for centralized platform
- **Solution**: Integrated web-based system with role-based access (Admin/Doctor/Patient)
- **Objectives**: Database-web integration, Secure authentication, Spring Boot + Tomcat deployment

---

## SLIDE 2: Tech Stack & Architecture (4 min)
**Technologies**:
| Layer | Stack |
|-------|-------|
| Frontend | HTML5, CSS3, Bootstrap 5, JavaScript, Chart.js |
| Backend | Java Servlets, JSP, Spring Boot 2.7 |
| Database | Oracle 11g XE, JDBC |
| Server | Apache Tomcat 9.0 (Embedded/External) |
| Security | SHA-256, Session Management |

**Architecture**: 3-Tier (Client → Spring Boot+Tomcat → Oracle DB)

---

## SLIDE 3: Database Design (4 min)
**Tables** (7 total, 3NF Normalized):
- **USERS**: USER_ID, NAME, EMAIL, PASSWORD (SHA-256), ROLE
- **FITNESS_DATA**: Health metrics (height, weight, steps, heart_rate)
- **APPOINTMENT**: Scheduling with doctors
- **PRESCRIPTIONS**: Doctor prescriptions with medications
- **MEDICAL_ADVICE**: Doctor advice with categories & priority

**Relationships**: 1:N (User→Fitness, User→Appointments), N:M (Doctor↔Patient)

---

## SLIDE 4: Live Demo - Patient Module (5 min)
1. **Register** new patient account
2. **Login** → Dashboard with health cards (BMI, Steps, Heart Rate)
3. **Health Tracking** → Log metrics
4. **Health Trends** → Chart.js graphs
5. **Book Appointment** → Schedule with doctor
6. **Medical History** → View prescriptions & advice

---

## SLIDE 5: Live Demo - Doctor & Admin (6 min)

**Doctor Module** (3 min):
1. **Login**: doctor@test.com / test123
2. **Dashboard** → Patient statistics
3. **Appointments** → View scheduled patients
4. **Write Prescription** → Create & save
5. **Medical Advice** → Send to patient

**Admin Module** (3 min):
1. **Login**: admin@test.com / test123
2. **Dashboard** → System statistics (Users, Doctors, Appointments)
3. **User Management** → View/edit/delete users
4. **Analytics** → Data visualization charts
5. **Export Data** → Download report

---

## SLIDE 6: Security & UI/UX (4 min)

**Security Measures**:
- **SHA-256 Password Hashing**
  ```java
  MessageDigest md = MessageDigest.getInstance("SHA-256");
  byte[] hash = md.digest(password.getBytes());
  return Base64.getEncoder().encodeToString(hash);
  ```
- **Session Management**: 30-min timeout, secure cookies
- **Role-Based Access Control**: Filter-based authorization

**UI/UX Highlights**:
- Medical Blue Theme (#0066cc)
- Floating Dark Mode Toggle (☼/☽)
- Responsive Sidebar Navigation
- Card-Based Dashboard Layout
- Interactive Charts (Chart.js)

---

## SLIDE 7: Deployment & Testing (4 min)

**Deployment**:
```bash
# Spring Boot (Embedded Tomcat)
mvn spring-boot:run
# Access: http://localhost:7070/Health-Manager/
```

**Testing Results**:
| Test Case | Status | Test Case | Status |
|-----------|--------|-----------|--------|
| User Registration | ✅ Passed | Appointment Booking | ✅ Passed |
| Login Authentication | ✅ Passed | Prescription Creation | ✅ Passed |
| Health Data Logging | ✅ Passed | Admin User Management | ✅ Passed |
| Dark Mode Toggle | ✅ Passed | Data Export | ✅ Passed |

**Test Accounts**:
- Admin: admin@test.com / test123
- Doctor: doctor@test.com / test123

---

## SLIDE 8: Challenges & Learning (3 min)

**Challenges Faced**:
1. Database connection pooling → Resolved with Spring DataSource
2. Session security → Implemented custom filters
3. Role-based navigation → Dynamic sidebar rendering
4. Dark mode persistence → localStorage implementation
5. Chart.js integration → Dynamic data binding

**Learning Outcomes**:
- Database design & normalization (3NF)
- Spring Boot framework & embedded Tomcat
- MVC architecture & security best practices
- Integration testing strategies

---

## SLIDE 9: Conclusion (2 min)

**Achievements**:
- ✅ Full-stack health management system developed
- ✅ DBMS + Web Technologies successfully integrated
- ✅ Multi-role authentication implemented
- ✅ Spring Boot + Tomcat deployment achieved

**Future Enhancements**:
- Email/SMS notifications
- Mobile app integration
- AI health predictions
- Wearable device connectivity

---

## SLIDE 10: Q&A (2 min)
- Questions?
- Live demo of specific features
- Technical discussion

---

## DEMO CHECKLIST

### Before Presentation
- [ ] Start Oracle Database
- [ ] Deploy application (mvn spring-boot:run)
- [ ] Test all accounts (admin, doctor, patient)
- [ ] Clear browser cache

### Demo Flow (11 min total)
1. [ ] Patient registration & login (2 min)
2. [ ] Log health data & view trends (2 min)
3. [ ] Book appointment (1 min)
4. [ ] Doctor login & view appointment (2 min)
5. [ ] Write prescription & advice (2 min)
6. [ ] Admin login & analytics (2 min)

### Backup
- Screenshots ready if live demo fails
- Database queries ready for verification

---

## TIME ALLOCATION (25 min total)
| Slide | Content | Time |
|-------|---------|------|
| 1 | Title & Introduction | 3 min |
| 2 | Tech Stack & Architecture | 4 min |
| 3 | Database Design | 4 min |
| 4-5 | Live Demo (Patient/Doctor/Admin) | 11 min |
| 6 | Security & UI/UX | 4 min |
| 7 | Deployment & Testing | 4 min |
| 8 | Challenges & Learning | 3 min |
| 9 | Conclusion | 2 min |
| 10 | Q&A | 2 min |

---

**Good Luck with Your Presentation!**
