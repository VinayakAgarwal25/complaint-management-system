SET SERVEROUTPUT ON;

/*
================================================================
PROJECT: COMPLAINT MANAGEMENT SYSTEM
Oracle SQL + PL/SQL academic database project

Run in Oracle SQL Developer as a script. This script uses Oracle
PL/SQL, sequences, DBMS_OUTPUT, and / block terminators.
================================================================
*/

/* ===== SECTION 0: CLEANUP AND SEQUENCES ===== */
BEGIN EXECUTE IMMEDIATE 'DROP VIEW vw_staff_workload'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW vw_department_performance'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP VIEW vw_complaint_summary'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE complaint_escalation CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE complaint_attachment CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE complaint_feedback CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE complaint_assignment CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE complaint_status_history CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE complaint CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE complaint_category CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE staff CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE department CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE users CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_complaint_id'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_history_id'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_assignment_id'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_feedback_id'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_attachment_id'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE seq_escalation_id'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/

/* ===== SECTION 1: DDL - CREATE ALL TABLES ===== */
CREATE TABLE users (
  user_id NUMBER PRIMARY KEY,
  name VARCHAR2(100) NOT NULL,
  email VARCHAR2(120) NOT NULL UNIQUE,
  CONSTRAINT chk_users_email CHECK (email LIKE '%@%.%')
);

CREATE TABLE department (
  department_id NUMBER PRIMARY KEY,
  department_name VARCHAR2(80) NOT NULL UNIQUE
);

CREATE TABLE staff (
  staff_id NUMBER PRIMARY KEY,
  name VARCHAR2(100) NOT NULL,
  department_id NUMBER NOT NULL,
  CONSTRAINT fk_staff_department FOREIGN KEY (department_id) REFERENCES department(department_id)
);

CREATE TABLE complaint_category (
  category_id NUMBER PRIMARY KEY,
  category_name VARCHAR2(80) NOT NULL UNIQUE
);

CREATE TABLE complaint (
  complaint_id NUMBER PRIMARY KEY,
  user_id NUMBER NOT NULL,
  category_id NUMBER NOT NULL,
  department_id NUMBER NOT NULL,
  description VARCHAR2(500) NOT NULL,
  status VARCHAR2(20) DEFAULT 'Pending' NOT NULL,
  priority VARCHAR2(10) NOT NULL,
  date_registered DATE DEFAULT SYSDATE NOT NULL,
  date_resolved DATE,
  CONSTRAINT fk_complaint_user FOREIGN KEY (user_id) REFERENCES users(user_id),
  CONSTRAINT fk_complaint_category FOREIGN KEY (category_id) REFERENCES complaint_category(category_id),
  CONSTRAINT fk_complaint_department FOREIGN KEY (department_id) REFERENCES department(department_id),
  CONSTRAINT chk_complaint_status CHECK (status IN ('Pending','In Progress','Resolved')),
  CONSTRAINT chk_complaint_priority CHECK (priority IN ('Low','Medium','High')),
  CONSTRAINT chk_complaint_dates CHECK (date_resolved IS NULL OR date_resolved >= date_registered)
);

CREATE TABLE complaint_status_history (
  history_id NUMBER PRIMARY KEY,
  complaint_id NUMBER NOT NULL,
  status VARCHAR2(20) NOT NULL,
  updated_on DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT fk_history_complaint FOREIGN KEY (complaint_id) REFERENCES complaint(complaint_id) ON DELETE CASCADE,
  CONSTRAINT chk_history_status CHECK (status IN ('Pending','In Progress','Resolved'))
);

CREATE TABLE complaint_assignment (
  assignment_id NUMBER PRIMARY KEY,
  complaint_id NUMBER NOT NULL,
  staff_id NUMBER NOT NULL,
  assigned_date DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT fk_assignment_complaint FOREIGN KEY (complaint_id) REFERENCES complaint(complaint_id) ON DELETE CASCADE,
  CONSTRAINT fk_assignment_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
  CONSTRAINT uq_assignment_complaint UNIQUE (complaint_id)
);

CREATE TABLE complaint_feedback (
  feedback_id NUMBER PRIMARY KEY,
  complaint_id NUMBER NOT NULL,
  rating NUMBER NOT NULL,
  comments VARCHAR2(400),
  CONSTRAINT fk_feedback_complaint FOREIGN KEY (complaint_id) REFERENCES complaint(complaint_id) ON DELETE CASCADE,
  CONSTRAINT chk_feedback_rating CHECK (rating BETWEEN 1 AND 5),
  CONSTRAINT uq_feedback_complaint UNIQUE (complaint_id)
);

CREATE TABLE complaint_attachment (
  attachment_id NUMBER PRIMARY KEY,
  complaint_id NUMBER NOT NULL,
  file_path VARCHAR2(255) NOT NULL,
  uploaded_on DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT fk_attachment_complaint FOREIGN KEY (complaint_id) REFERENCES complaint(complaint_id) ON DELETE CASCADE
);

CREATE TABLE complaint_escalation (
  escalation_id NUMBER PRIMARY KEY,
  complaint_id NUMBER NOT NULL,
  escalation_level NUMBER NOT NULL,
  escalation_date DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT fk_escalation_complaint FOREIGN KEY (complaint_id) REFERENCES complaint(complaint_id) ON DELETE CASCADE,
  CONSTRAINT chk_escalation_level CHECK (escalation_level BETWEEN 1 AND 5)
);

CREATE SEQUENCE seq_complaint_id START WITH 1001 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_history_id START WITH 1001 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_assignment_id START WITH 1001 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_feedback_id START WITH 1001 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_attachment_id START WITH 1001 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_escalation_id START WITH 1001 INCREMENT BY 1 NOCACHE;

/* ===== SECTION 2: DML - INSERT REALISTIC SAMPLE DATA ===== */
INSERT ALL
  INTO users (user_id, name, email) VALUES (1, 'Aarav Sharma', 'aarav.sharma@example.com')
  INTO users (user_id, name, email) VALUES (2, 'Ananya Iyer', 'ananya.iyer@example.com')
  INTO users (user_id, name, email) VALUES (3, 'Rohan Verma', 'rohan.verma@example.com')
  INTO users (user_id, name, email) VALUES (4, 'Priya Nair', 'priya.nair@example.com')
  INTO users (user_id, name, email) VALUES (5, 'Karan Mehta', 'karan.mehta@example.com')
  INTO users (user_id, name, email) VALUES (6, 'Sneha Kulkarni', 'sneha.kulkarni@example.com')
  INTO users (user_id, name, email) VALUES (7, 'Aditya Rao', 'aditya.rao@example.com')
  INTO users (user_id, name, email) VALUES (8, 'Meera Menon', 'meera.menon@example.com')
  INTO users (user_id, name, email) VALUES (9, 'Vikram Singh', 'vikram.singh@example.com')
  INTO users (user_id, name, email) VALUES (10, 'Isha Gupta', 'isha.gupta@example.com')
  INTO users (user_id, name, email) VALUES (11, 'Arjun Reddy', 'arjun.reddy@example.com')
  INTO users (user_id, name, email) VALUES (12, 'Neha Joshi', 'neha.joshi@example.com')
  INTO users (user_id, name, email) VALUES (13, 'Siddharth Jain', 'siddharth.jain@example.com')
  INTO users (user_id, name, email) VALUES (14, 'Pooja Patel', 'pooja.patel@example.com')
  INTO users (user_id, name, email) VALUES (15, 'Rahul Das', 'rahul.das@example.com')
  INTO users (user_id, name, email) VALUES (16, 'Kavya Pillai', 'kavya.pillai@example.com')
  INTO users (user_id, name, email) VALUES (17, 'Nikhil Bansal', 'nikhil.bansal@example.com')
  INTO users (user_id, name, email) VALUES (18, 'Aditi Chatterjee', 'aditi.chatterjee@example.com')
  INTO users (user_id, name, email) VALUES (19, 'Manish Malhotra', 'manish.malhotra@example.com')
  INTO users (user_id, name, email) VALUES (20, 'Divya Krishnan', 'divya.krishnan@example.com')
  INTO users (user_id, name, email) VALUES (21, 'Harsh Agarwal', 'harsh.agarwal@example.com')
  INTO users (user_id, name, email) VALUES (22, 'Tanvi Saxena', 'tanvi.saxena@example.com')
  INTO users (user_id, name, email) VALUES (23, 'Yash Kapoor', 'yash.kapoor@example.com')
  INTO users (user_id, name, email) VALUES (24, 'Ritika Sinha', 'ritika.sinha@example.com')
  INTO users (user_id, name, email) VALUES (25, 'Mohit Khanna', 'mohit.khanna@example.com')
  INTO users (user_id, name, email) VALUES (26, 'Shreya Ghosh', 'shreya.ghosh@example.com')
  INTO users (user_id, name, email) VALUES (27, 'Saurabh Mishra', 'saurabh.mishra@example.com')
  INTO users (user_id, name, email) VALUES (28, 'Naina Bhatia', 'naina.bhatia@example.com')
  INTO users (user_id, name, email) VALUES (29, 'Devansh Shah', 'devansh.shah@example.com')
  INTO users (user_id, name, email) VALUES (30, 'Simran Kaur', 'simran.kaur@example.com')
SELECT 1 FROM dual;

INSERT ALL
  INTO department (department_id, department_name) VALUES (1, 'Maintenance')
  INTO department (department_id, department_name) VALUES (2, 'IT')
  INTO department (department_id, department_name) VALUES (3, 'Housekeeping')
  INTO department (department_id, department_name) VALUES (4, 'Security')
  INTO department (department_id, department_name) VALUES (5, 'Mess/Cafeteria')
  INTO department (department_id, department_name) VALUES (6, 'Administration')
  INTO department (department_id, department_name) VALUES (7, 'Electrical')
  INTO department (department_id, department_name) VALUES (8, 'Plumbing')
SELECT 1 FROM dual;

INSERT ALL
  INTO staff (staff_id, name, department_id) VALUES (1, 'Ramesh Yadav', 1)
  INTO staff (staff_id, name, department_id) VALUES (2, 'Suresh Patil', 1)
  INTO staff (staff_id, name, department_id) VALUES (3, 'Kunal Bedi', 2)
  INTO staff (staff_id, name, department_id) VALUES (4, 'Farah Khan', 2)
  INTO staff (staff_id, name, department_id) VALUES (5, 'Manoj Tiwari', 2)
  INTO staff (staff_id, name, department_id) VALUES (6, 'Lata More', 3)
  INTO staff (staff_id, name, department_id) VALUES (7, 'Sunita Yadav', 3)
  INTO staff (staff_id, name, department_id) VALUES (8, 'Prakash Rawat', 4)
  INTO staff (staff_id, name, department_id) VALUES (9, 'Imran Sheikh', 4)
  INTO staff (staff_id, name, department_id) VALUES (10, 'Joseph Dsouza', 5)
  INTO staff (staff_id, name, department_id) VALUES (11, 'Geeta Arora', 5)
  INTO staff (staff_id, name, department_id) VALUES (12, 'Mahesh Pillai', 6)
  INTO staff (staff_id, name, department_id) VALUES (13, 'Rekha Singh', 6)
  INTO staff (staff_id, name, department_id) VALUES (14, 'Vivek Pandey', 7)
  INTO staff (staff_id, name, department_id) VALUES (15, 'Anil Chauhan', 7)
  INTO staff (staff_id, name, department_id) VALUES (16, 'Bharat Lal', 8)
  INTO staff (staff_id, name, department_id) VALUES (17, 'Nirmal Das', 8)
  INTO staff (staff_id, name, department_id) VALUES (18, 'Naveen Kumar', 1)
  INTO staff (staff_id, name, department_id) VALUES (19, 'Pallavi Desai', 6)
  INTO staff (staff_id, name, department_id) VALUES (20, 'Ajay Soni', 7)
SELECT 1 FROM dual;

INSERT ALL
  INTO complaint_category (category_id, category_name) VALUES (1, 'Noise')
  INTO complaint_category (category_id, category_name) VALUES (2, 'Water Leakage')
  INTO complaint_category (category_id, category_name) VALUES (3, 'Power Outage')
  INTO complaint_category (category_id, category_name) VALUES (4, 'Internet Issue')
  INTO complaint_category (category_id, category_name) VALUES (5, 'Cleanliness')
  INTO complaint_category (category_id, category_name) VALUES (6, 'Pest Control')
  INTO complaint_category (category_id, category_name) VALUES (7, 'Furniture Damage')
  INTO complaint_category (category_id, category_name) VALUES (8, 'Food Quality')
  INTO complaint_category (category_id, category_name) VALUES (9, 'Security Breach')
  INTO complaint_category (category_id, category_name) VALUES (10, 'Other')
SELECT 1 FROM dual;

INSERT ALL
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (1, 1, 4, 2, 'Wi-Fi disconnecting repeatedly in hostel block A.', 'Resolved', 'High', DATE '2024-01-05', DATE '2024-01-08')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (2, 2, 2, 8, 'Water leakage near washroom pipeline on second floor.', 'Resolved', 'Medium', DATE '2024-01-18', DATE '2024-01-24')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (3, 3, 3, 7, 'Power outage in computer lab during evening hours.', 'In Progress', 'High', DATE '2024-02-02', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (4, 4, 5, 3, 'Corridor cleaning not completed for three days.', 'Resolved', 'Low', DATE '2024-02-12', DATE '2024-02-13')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (5, 5, 8, 5, 'Dinner quality was poor and food was served cold.', 'Pending', 'Medium', DATE '2024-02-25', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (6, 6, 9, 4, 'Unknown person entered hostel without ID check.', 'In Progress', 'High', DATE '2024-03-03', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (7, 7, 7, 1, 'Study table leg broken in room B-214.', 'Resolved', 'Low', DATE '2024-03-15', DATE '2024-03-18')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (8, 8, 1, 6, 'Loud construction noise during examination week.', 'Resolved', 'Medium', DATE '2024-03-28', DATE '2024-04-03')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (9, 9, 6, 3, 'Cockroaches found in common pantry area.', 'Pending', 'High', DATE '2024-04-07', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (10, 10, 10, 6, 'Request for updated notice board information.', 'Resolved', 'Low', DATE '2024-04-20', DATE '2024-04-22')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (11, 11, 4, 2, 'LAN port not working in room C-109.', 'Resolved', 'Medium', DATE '2024-05-04', DATE '2024-05-10')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (12, 12, 3, 7, 'Frequent voltage fluctuation in seminar hall.', 'Resolved', 'High', DATE '2024-05-17', DATE '2024-06-01')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (13, 13, 2, 8, 'Tap continuously running in ground floor washroom.', 'In Progress', 'Medium', DATE '2024-06-02', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (14, 14, 5, 3, 'Overflowing dustbins near hostel entrance.', 'Resolved', 'Low', DATE '2024-06-16', DATE '2024-06-17')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (15, 15, 8, 5, 'Breakfast items not available by serving time.', 'Pending', 'Medium', DATE '2024-06-30', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (16, 16, 9, 4, 'CCTV camera near gate three is not recording.', 'Resolved', 'High', DATE '2024-07-08', DATE '2024-07-20')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (17, 17, 7, 1, 'Chair in reading room has damaged back support.', 'Resolved', 'Low', DATE '2024-07-19', DATE '2024-07-21')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (18, 18, 4, 2, 'Email portal password reset link not received.', 'In Progress', 'Medium', DATE '2024-08-01', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (19, 19, 3, 7, 'Tube light flickering in room A-310.', 'Pending', 'Low', DATE '2024-08-14', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (20, 20, 2, 8, 'Drain blocked near hostel courtyard.', 'Resolved', 'High', DATE '2024-08-29', DATE '2024-09-04')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (21, 21, 1, 6, 'Auditorium event noise continued beyond permitted time.', 'Resolved', 'Medium', DATE '2024-09-10', DATE '2024-09-14')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (22, 22, 6, 3, 'Mosquito breeding near stagnant water area.', 'In Progress', 'High', DATE '2024-09-21', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (23, 23, 10, 1, 'Window latch requires repair in lab corridor.', 'Resolved', 'Low', DATE '2024-10-05', DATE '2024-10-09')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (24, 24, 4, 2, 'Online attendance portal inaccessible from campus network.', 'Pending', 'High', DATE '2024-10-18', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (25, 25, 8, 5, 'Mess menu not followed for two consecutive days.', 'Resolved', 'Medium', DATE '2024-11-01', DATE '2024-11-06')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (26, 26, 5, 3, 'Washroom mirror and floor not cleaned properly.', 'Resolved', 'Low', DATE '2024-11-12', DATE '2024-11-13')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (27, 27, 3, 7, 'Main corridor lights off after 8 PM.', 'In Progress', 'High', DATE '2024-11-24', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (28, 28, 9, 4, 'Visitor register was unattended at front gate.', 'Pending', 'High', DATE '2024-12-04', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (29, 29, 2, 8, 'Low water pressure in third floor washroom.', 'Resolved', 'Medium', DATE '2024-12-15', DATE '2024-12-28')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (30, 30, 7, 1, 'Cupboard handle broken in room D-102.', 'Resolved', 'Low', DATE '2024-12-26', DATE '2024-12-30')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (31, 1, 4, 2, 'Campus LMS timing out during assignment upload.', 'Pending', 'High', DATE '2025-01-07', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (32, 2, 8, 5, 'Lunch rice was undercooked on multiple days.', 'Resolved', 'Medium', DATE '2025-01-16', DATE '2025-01-22')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (33, 3, 5, 3, 'Staircase area has not been swept after renovation work.', 'In Progress', 'Low', DATE '2025-01-30', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (34, 4, 3, 7, 'Backup generator did not start during power cut.', 'Resolved', 'High', DATE '2025-02-11', DATE '2025-02-25')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (35, 5, 2, 8, 'Seepage visible on ceiling near room B-305.', 'Pending', 'High', DATE '2025-02-20', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (36, 6, 9, 4, 'Hostel gate entry scanner not working.', 'Resolved', 'High', DATE '2025-03-03', DATE '2025-03-14')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (37, 7, 1, 6, 'Late night loudspeaker use near admin lawn.', 'Resolved', 'Medium', DATE '2025-03-12', DATE '2025-03-15')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (38, 8, 6, 3, 'Termite marks found near wooden cupboard.', 'In Progress', 'Medium', DATE '2025-03-24', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (39, 9, 4, 2, 'Computer lab printer not reachable over network.', 'Resolved', 'Low', DATE '2025-04-02', DATE '2025-04-05')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (40, 10, 3, 7, 'Electrical socket sparking in room C-204.', 'Pending', 'High', DATE '2025-04-12', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (41, 11, 10, 6, 'Duplicate fee receipt required from office.', 'Resolved', 'Low', DATE '2025-04-19', DATE '2025-04-21')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (42, 12, 2, 8, 'Water cooler outlet leaking continuously.', 'Resolved', 'Medium', DATE '2025-04-28', DATE '2025-05-03')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (43, 13, 8, 5, 'Tea served was stale in evening snack counter.', 'In Progress', 'Low', DATE '2025-05-05', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (44, 14, 7, 1, 'Bench in classroom F-12 is unstable.', 'Pending', 'Medium', DATE '2025-05-14', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (45, 15, 5, 3, 'Garbage collection skipped behind hostel block.', 'Resolved', 'Medium', DATE '2025-05-21', DATE '2025-05-24')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (46, 16, 4, 2, 'Biometric attendance device offline.', 'Resolved', 'High', DATE '2025-05-27', DATE '2025-06-05')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (47, 17, 3, 7, 'Ceiling fan stopped working in room B-101.', 'In Progress', 'Medium', DATE '2025-06-04', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (48, 18, 9, 4, 'Emergency exit was blocked by parked vehicles.', 'Pending', 'High', DATE '2025-06-11', NULL)
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (49, 19, 6, 3, 'Ant infestation reported in mess storage area.', 'Resolved', 'High', DATE '2025-06-20', DATE '2025-06-29')
  INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved) VALUES (50, 20, 2, 8, 'Bathroom flush tank not filling correctly.', 'Pending', 'Medium', DATE '2025-06-30', NULL)
SELECT 1 FROM dual;

INSERT ALL
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (1, 1, 'Pending', DATE '2024-01-05')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (2, 1, 'In Progress', DATE '2024-01-06')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (3, 1, 'Resolved', DATE '2024-01-08')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (4, 2, 'Pending', DATE '2024-01-18')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (5, 3, 'Pending', DATE '2024-02-02')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (6, 3, 'In Progress', DATE '2024-02-04')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (7, 4, 'Pending', DATE '2024-02-12')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (8, 5, 'Pending', DATE '2024-02-25')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (9, 6, 'Pending', DATE '2024-03-03')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (10, 6, 'In Progress', DATE '2024-03-04')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (11, 7, 'Pending', DATE '2024-03-15')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (12, 8, 'Pending', DATE '2024-03-28')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (13, 9, 'Pending', DATE '2024-04-07')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (14, 10, 'Pending', DATE '2024-04-20')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (15, 11, 'Pending', DATE '2024-05-04')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (16, 11, 'Resolved', DATE '2024-05-10')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (17, 12, 'Pending', DATE '2024-05-17')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (18, 13, 'Pending', DATE '2024-06-02')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (19, 13, 'In Progress', DATE '2024-06-03')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (20, 14, 'Pending', DATE '2024-06-16')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (21, 15, 'Pending', DATE '2024-06-30')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (22, 16, 'Pending', DATE '2024-07-08')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (23, 17, 'Pending', DATE '2024-07-19')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (24, 18, 'Pending', DATE '2024-08-01')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (25, 18, 'In Progress', DATE '2024-08-03')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (26, 19, 'Pending', DATE '2024-08-14')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (27, 20, 'Pending', DATE '2024-08-29')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (28, 21, 'Pending', DATE '2024-09-10')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (29, 22, 'Pending', DATE '2024-09-21')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (30, 22, 'In Progress', DATE '2024-09-22')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (31, 23, 'Pending', DATE '2024-10-05')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (32, 24, 'Pending', DATE '2024-10-18')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (33, 25, 'Pending', DATE '2024-11-01')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (34, 26, 'Pending', DATE '2024-11-12')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (35, 27, 'Pending', DATE '2024-11-24')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (36, 27, 'In Progress', DATE '2024-11-25')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (37, 28, 'Pending', DATE '2024-12-04')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (38, 29, 'Pending', DATE '2024-12-15')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (39, 30, 'Pending', DATE '2024-12-26')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (40, 31, 'Pending', DATE '2025-01-07')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (41, 32, 'Pending', DATE '2025-01-16')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (42, 33, 'Pending', DATE '2025-01-30')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (43, 33, 'In Progress', DATE '2025-02-01')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (44, 34, 'Pending', DATE '2025-02-11')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (45, 35, 'Pending', DATE '2025-02-20')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (46, 36, 'Pending', DATE '2025-03-03')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (47, 37, 'Pending', DATE '2025-03-12')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (48, 38, 'Pending', DATE '2025-03-24')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (49, 39, 'Pending', DATE '2025-04-02')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (50, 40, 'Pending', DATE '2025-04-12')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (51, 41, 'Pending', DATE '2025-04-19')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (52, 42, 'Pending', DATE '2025-04-28')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (53, 43, 'Pending', DATE '2025-05-05')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (54, 44, 'Pending', DATE '2025-05-14')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (55, 45, 'Pending', DATE '2025-05-21')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (56, 46, 'Pending', DATE '2025-05-27')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (57, 47, 'Pending', DATE '2025-06-04')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (58, 49, 'Pending', DATE '2025-06-20')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (59, 48, 'Pending', DATE '2025-06-11')
  INTO complaint_status_history (history_id, complaint_id, status, updated_on) VALUES (60, 50, 'Pending', DATE '2025-06-30')
SELECT 1 FROM dual;

INSERT ALL
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (1, 1, 3, DATE '2024-01-06')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (2, 2, 16, DATE '2024-01-19')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (3, 3, 14, DATE '2024-02-04')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (4, 4, 6, DATE '2024-02-12')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (5, 6, 8, DATE '2024-03-04')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (6, 7, 1, DATE '2024-03-16')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (7, 8, 12, DATE '2024-03-29')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (8, 10, 13, DATE '2024-04-21')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (9, 11, 4, DATE '2024-05-05')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (10, 12, 15, DATE '2024-05-18')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (11, 13, 17, DATE '2024-06-03')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (12, 14, 7, DATE '2024-06-16')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (13, 16, 9, DATE '2024-07-09')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (14, 17, 18, DATE '2024-07-20')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (15, 18, 5, DATE '2024-08-03')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (16, 20, 16, DATE '2024-08-30')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (17, 21, 19, DATE '2024-09-11')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (18, 22, 6, DATE '2024-09-22')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (19, 23, 2, DATE '2024-10-06')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (20, 25, 10, DATE '2024-11-02')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (21, 26, 7, DATE '2024-11-12')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (22, 27, 20, DATE '2024-11-25')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (23, 29, 17, DATE '2024-12-16')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (24, 30, 1, DATE '2024-12-27')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (25, 32, 11, DATE '2025-01-17')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (26, 33, 6, DATE '2025-02-01')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (27, 34, 14, DATE '2025-02-12')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (28, 36, 8, DATE '2025-03-04')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (29, 37, 12, DATE '2025-03-13')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (30, 38, 7, DATE '2025-03-25')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (31, 39, 3, DATE '2025-04-03')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (32, 41, 13, DATE '2025-04-20')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (33, 42, 16, DATE '2025-04-29')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (34, 43, 10, DATE '2025-05-06')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (35, 45, 6, DATE '2025-05-22')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (36, 46, 4, DATE '2025-05-28')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (37, 47, 15, DATE '2025-06-05')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (38, 49, 7, DATE '2025-06-21')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (39, 5, 11, DATE '2024-02-26')
  INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date) VALUES (40, 35, 17, DATE '2025-02-21')
SELECT 1 FROM dual;

INSERT ALL
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (1, 1, 5, 'Issue fixed quickly and internet is stable.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (2, 2, 4, 'Leakage stopped after repair work.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (3, 4, 4, 'Cleaning team responded promptly.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (4, 7, 3, 'Table repaired but finish could be better.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (5, 8, 2, 'Noise reduced only after repeated follow-up.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (6, 10, 5, 'Notice board was updated.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (7, 11, 4, 'LAN port works now.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (8, 12, 3, 'Voltage issue took time but is resolved.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (9, 14, 5, 'Dustbins cleared the same day.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (10, 16, 4, 'CCTV recording restored.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (11, 17, 4, 'Chair replacement was satisfactory.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (12, 20, 3, 'Drain was cleared after inspection.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (13, 21, 2, 'Action was delayed.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (14, 23, 5, 'Window latch repaired properly.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (15, 25, 3, 'Mess menu improved after complaint.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (16, 26, 4, 'Washroom is clean now.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (17, 29, 2, 'Water pressure improved but response was slow.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (18, 30, 5, 'Cupboard handle replaced.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (19, 32, 4, 'Food quality improved.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (20, 34, 3, 'Generator issue resolved.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (21, 36, 4, 'Entry scanner works again.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (22, 37, 5, 'Noise stopped immediately.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (23, 39, 4, 'Printer is reachable.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (24, 41, 5, 'Receipt was issued quickly.')
  INTO complaint_feedback (feedback_id, complaint_id, rating, comments) VALUES (25, 42, 4, 'Cooler repaired.')
SELECT 1 FROM dual;

INSERT ALL
  INTO complaint_attachment (attachment_id, complaint_id, file_path, uploaded_on) VALUES (1, 1, '/uploads/img_001.jpg', DATE '2024-01-05')
  INTO complaint_attachment (attachment_id, complaint_id, file_path, uploaded_on) VALUES (2, 2, '/uploads/leak_002.jpg', DATE '2024-01-18')
  INTO complaint_attachment (attachment_id, complaint_id, file_path, uploaded_on) VALUES (3, 3, '/uploads/power_lab_003.jpg', DATE '2024-02-02')
  INTO complaint_attachment (attachment_id, complaint_id, file_path, uploaded_on) VALUES (4, 6, '/uploads/security_gate_004.png', DATE '2024-03-03')
  INTO complaint_attachment (attachment_id, complaint_id, file_path, uploaded_on) VALUES (5, 7, '/uploads/furniture_005.jpg', DATE '2024-03-15')
  INTO complaint_attachment (attachment_id, complaint_id, file_path, uploaded_on) VALUES (6, 9, '/uploads/pest_006.jpg', DATE '2024-04-07')
  INTO complaint_attachment (attachment_id, complaint_id, file_path, uploaded_on) VALUES (7, 12, '/uploads/voltage_007.pdf', DATE '2024-05-17')
  INTO complaint_attachment (attachment_id, complaint_id, file_path, uploaded_on) VALUES (8, 16, '/uploads/cctv_008.jpg', DATE '2024-07-08')
  INTO complaint_attachment (attachment_id, complaint_id, file_path, uploaded_on) VALUES (9, 20, '/uploads/drain_009.jpg', DATE '2024-08-29')
  INTO complaint_attachment (attachment_id, complaint_id, file_path, uploaded_on) VALUES (10, 24, '/uploads/portal_010.png', DATE '2024-10-18')
  INTO complaint_attachment (attachment_id, complaint_id, file_path, uploaded_on) VALUES (11, 28, '/uploads/security_register_011.jpg', DATE '2024-12-04')
  INTO complaint_attachment (attachment_id, complaint_id, file_path, uploaded_on) VALUES (12, 31, '/uploads/lms_timeout_012.png', DATE '2025-01-07')
  INTO complaint_attachment (attachment_id, complaint_id, file_path, uploaded_on) VALUES (13, 35, '/uploads/seepage_013.jpg', DATE '2025-02-20')
  INTO complaint_attachment (attachment_id, complaint_id, file_path, uploaded_on) VALUES (14, 36, '/uploads/scanner_014.jpg', DATE '2025-03-03')
  INTO complaint_attachment (attachment_id, complaint_id, file_path, uploaded_on) VALUES (15, 38, '/uploads/termite_015.jpg', DATE '2025-03-24')
  INTO complaint_attachment (attachment_id, complaint_id, file_path, uploaded_on) VALUES (16, 40, '/uploads/socket_016.mp4', DATE '2025-04-12')
  INTO complaint_attachment (attachment_id, complaint_id, file_path, uploaded_on) VALUES (17, 44, '/uploads/bench_017.jpg', DATE '2025-05-14')
  INTO complaint_attachment (attachment_id, complaint_id, file_path, uploaded_on) VALUES (18, 46, '/uploads/biometric_018.png', DATE '2025-05-27')
  INTO complaint_attachment (attachment_id, complaint_id, file_path, uploaded_on) VALUES (19, 48, '/uploads/emergency_exit_019.jpg', DATE '2025-06-11')
  INTO complaint_attachment (attachment_id, complaint_id, file_path, uploaded_on) VALUES (20, 50, '/uploads/flush_tank_020.jpg', DATE '2025-06-30')
SELECT 1 FROM dual;

INSERT ALL
  INTO complaint_escalation (escalation_id, complaint_id, escalation_level, escalation_date) VALUES (1, 3, 1, DATE '2024-02-09')
  INTO complaint_escalation (escalation_id, complaint_id, escalation_level, escalation_date) VALUES (2, 6, 1, DATE '2024-03-07')
  INTO complaint_escalation (escalation_id, complaint_id, escalation_level, escalation_date) VALUES (3, 9, 1, DATE '2024-04-11')
  INTO complaint_escalation (escalation_id, complaint_id, escalation_level, escalation_date) VALUES (4, 9, 2, DATE '2024-04-18')
  INTO complaint_escalation (escalation_id, complaint_id, escalation_level, escalation_date) VALUES (5, 22, 1, DATE '2024-09-28')
  INTO complaint_escalation (escalation_id, complaint_id, escalation_level, escalation_date) VALUES (6, 24, 1, DATE '2024-10-24')
  INTO complaint_escalation (escalation_id, complaint_id, escalation_level, escalation_date) VALUES (7, 24, 2, DATE '2024-11-02')
  INTO complaint_escalation (escalation_id, complaint_id, escalation_level, escalation_date) VALUES (8, 27, 1, DATE '2024-12-01')
  INTO complaint_escalation (escalation_id, complaint_id, escalation_level, escalation_date) VALUES (9, 28, 1, DATE '2024-12-09')
  INTO complaint_escalation (escalation_id, complaint_id, escalation_level, escalation_date) VALUES (10, 31, 1, DATE '2025-01-12')
  INTO complaint_escalation (escalation_id, complaint_id, escalation_level, escalation_date) VALUES (11, 35, 1, DATE '2025-02-25')
  INTO complaint_escalation (escalation_id, complaint_id, escalation_level, escalation_date) VALUES (12, 35, 2, DATE '2025-03-04')
  INTO complaint_escalation (escalation_id, complaint_id, escalation_level, escalation_date) VALUES (13, 40, 1, DATE '2025-04-15')
  INTO complaint_escalation (escalation_id, complaint_id, escalation_level, escalation_date) VALUES (14, 48, 1, DATE '2025-06-16')
  INTO complaint_escalation (escalation_id, complaint_id, escalation_level, escalation_date) VALUES (15, 48, 2, DATE '2025-06-23')
SELECT 1 FROM dual;

COMMIT;

/* ================================================================
   FILE: 03_queries.sql
   PROJECT: Complaint Management System
   SECTION 3: 30 COMPLEX SUBQUERIES
   Description: Advanced Oracle SQL SELECT queries demonstrating
   correlated subqueries, nested subqueries, EXISTS / NOT EXISTS,
   scalar subqueries in SELECT/HAVING/WHERE, inline views, multi-level
   nesting, ANY / ALL operators, and analytical CASE expressions.
   ================================================================ */

/* ----------------------------------------------------------------
   TIER 1: CORRELATED SUBQUERIES (Q1 - Q8)
   A subquery that references a column from the outer query,
   re-executed once per row of the outer result.
   ---------------------------------------------------------------- */

-- Q1. Users whose total complaint count exceeds the overall average
--     complaints per user. Uses a two-level nested aggregate:
--     inner inline view computes per-user counts; outer averages them.
SELECT u.user_id,
       u.name,
       COUNT(c.complaint_id) AS total_complaints
FROM users u
JOIN complaint c ON u.user_id = c.user_id
GROUP BY u.user_id, u.name
HAVING COUNT(c.complaint_id) > (
    SELECT AVG(user_complaint_count)
    FROM (
        SELECT COUNT(complaint_id) AS user_complaint_count
        FROM complaint
        GROUP BY user_id
    )
);

-- Q2. Each resolved complaint shown alongside the average resolution
--     time of its own department (correlated scalar subquery in SELECT).
SELECT c.complaint_id,
       c.description,
       c.date_resolved - c.date_registered        AS own_resolution_days,
       (
           SELECT ROUND(AVG(c2.date_resolved - c2.date_registered), 2)
           FROM complaint c2
           WHERE c2.department_id = c.department_id
             AND c2.status = 'Resolved'
       )                                           AS dept_avg_resolution_days
FROM complaint c
WHERE c.status = 'Resolved'
ORDER BY c.department_id, own_resolution_days DESC;

-- Q3. For each user, show their most recent complaint and its current status.
--     Correlated MAX subquery selects only the latest date per user.
SELECT u.name        AS user_name,
       c.complaint_id,
       c.description,
       c.status,
       c.date_registered AS last_complaint_date
FROM complaint c
JOIN users u ON c.user_id = u.user_id
WHERE c.date_registered = (
    SELECT MAX(c2.date_registered)
    FROM complaint c2
    WHERE c2.user_id = c.user_id
)
ORDER BY c.date_registered DESC;

-- Q4. Escalated complaints where the escalation level is strictly above
--     the average escalation level recorded for that complaint's department
--     (correlated subquery joining across two tables in the inner block).
SELECT e.escalation_id,
       c.complaint_id,
       d.department_name,
       e.escalation_level,
       ROUND((
           SELECT AVG(e2.escalation_level)
           FROM complaint_escalation e2
           JOIN complaint c2 ON e2.complaint_id = c2.complaint_id
           WHERE c2.department_id = c.department_id
       ), 2)          AS dept_avg_escalation_level
FROM complaint_escalation e
JOIN complaint    c ON e.complaint_id  = c.complaint_id
JOIN department   d ON c.department_id = d.department_id
WHERE e.escalation_level > (
    SELECT AVG(e2.escalation_level)
    FROM complaint_escalation e2
    JOIN complaint c2 ON e2.complaint_id = c2.complaint_id
    WHERE c2.department_id = c.department_id
)
ORDER BY d.department_name, e.escalation_level DESC;

-- Q5. Complaints where the feedback rating falls below the average
--     rating for their specific category (correlated subquery in WHERE).
SELECT c.complaint_id,
       cc.category_name,
       f.rating,
       ROUND((
           SELECT AVG(f2.rating)
           FROM complaint_feedback f2
           JOIN complaint c2 ON f2.complaint_id = c2.complaint_id
           WHERE c2.category_id = c.category_id
       ), 2)           AS category_avg_rating
FROM complaint         c
JOIN complaint_category cc ON c.category_id   = cc.category_id
JOIN complaint_feedback  f  ON c.complaint_id  = f.complaint_id
WHERE f.rating < (
    SELECT AVG(f2.rating)
    FROM complaint_feedback f2
    JOIN complaint c2 ON f2.complaint_id = c2.complaint_id
    WHERE c2.category_id = c.category_id
)
ORDER BY cc.category_name, f.rating;

-- Q6. Staff who have been assigned complaints spanning more distinct
--     complaint categories than the system-wide average per staff member.
SELECT s.staff_id,
       s.name,
       COUNT(DISTINCT c.category_id) AS distinct_categories_handled
FROM staff s
JOIN complaint_assignment a ON s.staff_id    = a.staff_id
JOIN complaint            c ON a.complaint_id = c.complaint_id
GROUP BY s.staff_id, s.name
HAVING COUNT(DISTINCT c.category_id) > (
    SELECT AVG(cat_count)
    FROM (
        SELECT COUNT(DISTINCT c2.category_id) AS cat_count
        FROM complaint_assignment a2
        JOIN complaint c2 ON a2.complaint_id = c2.complaint_id
        GROUP BY a2.staff_id
    )
);

-- Q7. Unresolved complaints whose description length is longer than the
--     average description length of ALL resolved complaints.
SELECT c.complaint_id,
       c.status,
       c.priority,
       LENGTH(c.description)                         AS desc_length,
       (SELECT ROUND(AVG(LENGTH(description)), 0)
        FROM complaint WHERE status = 'Resolved')    AS avg_resolved_desc_length
FROM complaint c
WHERE c.status <> 'Resolved'
  AND LENGTH(c.description) > (
      SELECT AVG(LENGTH(description))
      FROM complaint
      WHERE status = 'Resolved'
  )
ORDER BY desc_length DESC;

-- Q8. For each department, the percentage share of total High-priority
--     complaints vs that department's total, compared to all High-priority
--     complaints system-wide (two scalar subqueries in one SELECT).
SELECT d.department_name,
       COUNT(c.complaint_id)                                        AS total_complaints,
       SUM(CASE WHEN c.priority = 'High' THEN 1 ELSE 0 END)        AS high_priority_count,
       ROUND(
           SUM(CASE WHEN c.priority = 'High' THEN 1 ELSE 0 END) * 100.0
           / NULLIF(COUNT(c.complaint_id), 0), 2
       )                                                            AS high_pct_within_dept,
       ROUND(
           SUM(CASE WHEN c.priority = 'High' THEN 1 ELSE 0 END) * 100.0
           / NULLIF((SELECT COUNT(*) FROM complaint WHERE priority = 'High'), 0), 2
       )                                                            AS share_of_all_high
FROM department d
LEFT JOIN complaint c ON d.department_id = c.department_id
GROUP BY d.department_name, d.department_id
ORDER BY high_pct_within_dept DESC NULLS LAST;


/* ----------------------------------------------------------------
   TIER 2: EXISTS / NOT EXISTS (Q9 - Q16)
   Efficient semi-join and anti-join patterns that return TRUE/FALSE
   based on whether a subquery produces any rows.
   ---------------------------------------------------------------- */

-- Q9. Departments that have NEVER received a Low-priority complaint.
SELECT d.department_name
FROM department d
WHERE NOT EXISTS (
    SELECT 1
    FROM complaint c
    WHERE c.department_id = d.department_id
      AND c.priority = 'Low'
);

-- Q10. Complaints that have NO entry in the status history table at all.
SELECT c.complaint_id, c.description, c.status, c.date_registered
FROM complaint c
WHERE c.complaint_id NOT IN (
    SELECT DISTINCT complaint_id
    FROM complaint_status_history
);

-- Q11. Users who have filed complaints in EVERY department that has had
--      at least one escalation (relational division via double NOT EXISTS).
SELECT u.user_id, u.name
FROM users u
WHERE NOT EXISTS (
    SELECT 1
    FROM department d
    WHERE EXISTS (
        SELECT 1
        FROM complaint_escalation e
        JOIN complaint ce ON e.complaint_id = ce.complaint_id
        WHERE ce.department_id = d.department_id
    )
    AND NOT EXISTS (
        SELECT 1
        FROM complaint c
        WHERE c.user_id     = u.user_id
          AND c.department_id = d.department_id
    )
);

-- Q12. Departments where no complaint has ever received a feedback
--      rating below 3 but do have at least one feedback record
--      (EXISTS + NOT EXISTS combination for quality filtering).
SELECT d.department_name
FROM department d
WHERE EXISTS (
    SELECT 1
    FROM complaint c
    JOIN complaint_feedback f ON c.complaint_id = f.complaint_id
    WHERE c.department_id = d.department_id
)
AND NOT EXISTS (
    SELECT 1
    FROM complaint c
    JOIN complaint_feedback f ON c.complaint_id = f.complaint_id
    WHERE c.department_id = d.department_id
      AND f.rating < 3
);

-- Q13. Users who have at least one complaint 'In Progress' but have NEVER
--      received a perfect rating of 5 on any of their resolved complaints.
SELECT u.user_id, u.name
FROM users u
WHERE EXISTS (
    SELECT 1
    FROM complaint c
    WHERE c.user_id = u.user_id
      AND c.status  = 'In Progress'
)
AND NOT EXISTS (
    SELECT 1
    FROM complaint c
    JOIN complaint_feedback f ON c.complaint_id = f.complaint_id
    WHERE c.user_id = u.user_id
      AND f.rating  = 5
);

-- Q14. Complaints where BOTH the complainant's department (via the complaint
--      routing) AND the assigned staff's home department have had escalations.
SELECT c.complaint_id,
       c.description,
       u.name  AS user_name,
       s.name  AS staff_name
FROM complaint            c
JOIN users                u  ON c.user_id    = u.user_id
JOIN complaint_assignment a  ON c.complaint_id = a.complaint_id
JOIN staff                s  ON a.staff_id   = s.staff_id
WHERE EXISTS (
    SELECT 1
    FROM complaint_escalation e
    JOIN complaint ce ON e.complaint_id = ce.complaint_id
    WHERE ce.department_id = c.department_id
)
AND EXISTS (
    SELECT 1
    FROM complaint_escalation e2
    JOIN complaint ce2 ON e2.complaint_id = ce2.complaint_id
    JOIN staff s2      ON ce2.department_id = s2.department_id
    WHERE s2.staff_id = s.staff_id
);

-- Q15. Departments that contain at least one staff member who has handled
--      complaints from three or more distinct categories.
SELECT d.department_name
FROM department d
WHERE EXISTS (
    SELECT 1
    FROM staff s
    JOIN complaint_assignment a ON s.staff_id    = a.staff_id
    JOIN complaint            c ON a.complaint_id = c.complaint_id
    WHERE s.department_id = d.department_id
    GROUP BY s.staff_id
    HAVING COUNT(DISTINCT c.category_id) >= 3
);

-- Q16. Users who submitted complaints ONLY in departments that have above-
--      average complaint volume (three-level nesting: exists check → NOT IN
--      → HAVING with inner inline view).
SELECT u.user_id, u.name
FROM users u
WHERE EXISTS (
    SELECT 1 FROM complaint c WHERE c.user_id = u.user_id
)
AND NOT EXISTS (
    SELECT 1
    FROM complaint c
    WHERE c.user_id = u.user_id
      AND c.department_id NOT IN (
          SELECT department_id
          FROM complaint
          GROUP BY department_id
          HAVING COUNT(*) > (
              SELECT AVG(dept_count)
              FROM (
                  SELECT COUNT(*) AS dept_count
                  FROM complaint
                  GROUP BY department_id
              )
          )
      )
);


/* ----------------------------------------------------------------
   TIER 3: NESTED & MULTI-LEVEL SUBQUERIES (Q17 - Q23)
   Subqueries whose WHERE / HAVING clause contains another complete
   SELECT, often producing a single value for comparison.
   ---------------------------------------------------------------- */

-- Q17. Complaints registered in the same calendar month as the peak
--      complaint month (month with highest volume). Three-level nesting:
--      outermost filters month = (middle finds peak month = (inner finds max count)).
SELECT c.complaint_id,
       c.description,
       c.priority,
       TO_CHAR(c.date_registered, 'YYYY-MM') AS reg_month
FROM complaint c
WHERE TO_CHAR(c.date_registered, 'YYYY-MM') = (
    SELECT TO_CHAR(date_registered, 'YYYY-MM')
    FROM complaint
    GROUP BY TO_CHAR(date_registered, 'YYYY-MM')
    HAVING COUNT(*) = (
        SELECT MAX(monthly_count)
        FROM (
            SELECT COUNT(*) AS monthly_count
            FROM complaint
            GROUP BY TO_CHAR(date_registered, 'YYYY-MM')
        )
    )
)
ORDER BY c.date_registered;

-- Q18. Most complained-about category within the single busiest department
--      (three-level nesting: outer filters by category → inner identifies
--      the busiest dept → innermost computes max volume).
SELECT cc.category_name,
       COUNT(c.complaint_id) AS complaint_count
FROM complaint         c
JOIN complaint_category cc ON c.category_id = cc.category_id
WHERE c.department_id = (
    SELECT department_id
    FROM complaint
    GROUP BY department_id
    HAVING COUNT(*) = (
        SELECT MAX(dept_count)
        FROM (
            SELECT COUNT(*) AS dept_count
            FROM complaint
            GROUP BY department_id
        )
    )
)
GROUP BY cc.category_name
ORDER BY complaint_count DESC;

-- Q19. Categories where the average feedback rating is higher than the
--      system-wide average (HAVING with a scalar subquery instead of a literal).
SELECT cc.category_name,
       ROUND(AVG(f.rating), 2)                                AS avg_category_rating,
       (SELECT ROUND(AVG(rating), 2) FROM complaint_feedback) AS system_avg_rating
FROM complaint_category cc
JOIN complaint          c  ON cc.category_id  = c.category_id
JOIN complaint_feedback f  ON c.complaint_id  = f.complaint_id
GROUP BY cc.category_name
HAVING AVG(f.rating) > (
    SELECT AVG(rating)
    FROM complaint_feedback
);

-- Q20. Staff who have resolved more complaints than the average resolutions
--      per assigned staff member across the entire system
--      (HAVING vs two-level inline view average).
SELECT s.staff_id,
       s.name,
       COUNT(c.complaint_id) AS resolved_count
FROM staff                s
JOIN complaint_assignment a ON s.staff_id    = a.staff_id
JOIN complaint            c ON a.complaint_id = c.complaint_id AND c.status = 'Resolved'
GROUP BY s.staff_id, s.name
HAVING COUNT(c.complaint_id) > (
    SELECT AVG(resolved_per_staff)
    FROM (
        SELECT COUNT(c2.complaint_id) AS resolved_per_staff
        FROM complaint_assignment a2
        JOIN complaint c2 ON a2.complaint_id = c2.complaint_id AND c2.status = 'Resolved'
        GROUP BY a2.staff_id
    )
);

-- Q21. Pending complaints belonging to a category whose overall resolution
--      rate (resolved / total) is below 50%  (IN with aggregated HAVING subquery).
SELECT c.complaint_id,
       cc.category_name,
       c.priority,
       c.date_registered
FROM complaint          c
JOIN complaint_category cc ON c.category_id = cc.category_id
WHERE c.status = 'Pending'
  AND c.category_id IN (
      SELECT category_id
      FROM complaint
      GROUP BY category_id
      HAVING SUM(CASE WHEN status = 'Resolved' THEN 1 ELSE 0 END) * 100.0
             / COUNT(*) < 50
  )
ORDER BY c.priority DESC, c.date_registered;

-- Q22. Complaints that are escalated at level 3 or higher AND still unresolved,
--      enriched with department and complainant details.
SELECT c.complaint_id,
       c.description,
       c.priority,
       c.status,
       u.name           AS complainant,
       d.department_name
FROM complaint   c
JOIN users       u ON c.user_id      = u.user_id
JOIN department  d ON c.department_id = d.department_id
WHERE c.complaint_id IN (
    SELECT complaint_id
    FROM complaint_escalation
    WHERE escalation_level >= 3
)
AND c.status <> 'Resolved'
ORDER BY c.priority DESC, c.date_registered;

-- Q23. For each department, the staff member with the highest resolved
--      complaint count (inline view ranked by correlated MAX subquery).
SELECT dept_name,
       staff_name,
       resolved_count
FROM (
    SELECT d.department_name                  AS dept_name,
           s.name                             AS staff_name,
           s.staff_id,
           d.department_id,
           COUNT(c.complaint_id)              AS resolved_count
    FROM department           d
    JOIN staff                s  ON s.department_id = d.department_id
    LEFT JOIN complaint_assignment a ON s.staff_id    = a.staff_id
    LEFT JOIN complaint            c ON a.complaint_id = c.complaint_id AND c.status = 'Resolved'
    GROUP BY d.department_name, s.name, s.staff_id, d.department_id
) ranked
WHERE resolved_count = (
    SELECT MAX(r2.resolved_count)
    FROM (
        SELECT s2.department_id,
               COUNT(c2.complaint_id) AS resolved_count
        FROM staff                s2
        LEFT JOIN complaint_assignment a2 ON s2.staff_id    = a2.staff_id
        LEFT JOIN complaint            c2 ON a2.complaint_id = c2.complaint_id AND c2.status = 'Resolved'
        GROUP BY s2.department_id, s2.staff_id
    ) r2
    WHERE r2.department_id = ranked.department_id
)
ORDER BY dept_name;


/* ----------------------------------------------------------------
   TIER 4: ANY / ALL & ANALYTICAL CASE EXPRESSIONS (Q24 - Q30)
   Quantified comparisons and context-aware labelling using scalar
   subqueries inside CASE/WHEN blocks.
   ---------------------------------------------------------------- */

-- Q24. Departments where the total High-priority complaint count is greater
--      than or equal to ALL other individual departments
--      (finds the single department with the absolute highest High count).
SELECT d.department_name,
       COUNT(c.complaint_id) AS high_priority_count
FROM department d
JOIN complaint  c ON d.department_id = c.department_id
WHERE c.priority = 'High'
GROUP BY d.department_name
HAVING COUNT(c.complaint_id) >= ALL (
    SELECT COUNT(c2.complaint_id)
    FROM complaint c2
    WHERE c2.priority = 'High'
    GROUP BY c2.department_id
);

-- Q25. Users who have filed more complaints than ANY single user within
--      the Housekeeping department (ANY operator with correlated dept lookup).
SELECT u.user_id,
       u.name,
       COUNT(c.complaint_id) AS complaint_count
FROM users    u
JOIN complaint c ON u.user_id = c.user_id
GROUP BY u.user_id, u.name
HAVING COUNT(c.complaint_id) > ANY (
    SELECT COUNT(c2.complaint_id)
    FROM complaint c2
    WHERE c2.department_id = (
        SELECT department_id
        FROM department
        WHERE department_name = 'Housekeeping'
    )
    GROUP BY c2.user_id
);

-- Q26. Staff who handle ONLY High-priority complaints (no Medium or Low)
--      and have been assigned at least 2 such complaints
--      (NOT EXISTS priority filter + scalar count subquery).
SELECT s.name AS staff_name,
       (SELECT COUNT(*)
        FROM complaint_assignment a
        WHERE a.staff_id = s.staff_id) AS total_assigned
FROM staff s
WHERE NOT EXISTS (
    SELECT 1
    FROM complaint_assignment a
    JOIN complaint c ON a.complaint_id = c.complaint_id
    WHERE a.staff_id  = s.staff_id
      AND c.priority <> 'High'
)
AND (SELECT COUNT(*)
     FROM complaint_assignment a
     WHERE a.staff_id = s.staff_id) >= 2;

-- Q27. Label each resolved complaint as 'Above Average' or 'Below Average'
--      relative to its category's average resolution time
--      (CASE with a correlated scalar subquery in both the label and comparison).
SELECT c.complaint_id,
       cc.category_name,
       c.date_resolved - c.date_registered                            AS resolution_days,
       ROUND((
           SELECT AVG(c2.date_resolved - c2.date_registered)
           FROM complaint c2
           WHERE c2.category_id = c.category_id
             AND c2.status = 'Resolved'
       ), 2)                                                          AS category_avg_days,
       CASE
           WHEN (c.date_resolved - c.date_registered) >
                (SELECT AVG(c2.date_resolved - c2.date_registered)
                 FROM complaint c2
                 WHERE c2.category_id = c.category_id
                   AND c2.status = 'Resolved')
           THEN 'Above Average'
           ELSE 'Below Average'
       END                                                            AS resolution_performance
FROM complaint          c
JOIN complaint_category cc ON c.category_id = cc.category_id
WHERE c.status = 'Resolved'
ORDER BY cc.category_name, resolution_days DESC;

-- Q28. Users who have filed more complaints than the system average AND
--      have at least one complaint still unresolved, ordered by risk level.
SELECT u.user_id,
       u.name,
       COUNT(c.complaint_id)                                          AS total_complaints,
       SUM(CASE WHEN c.status <> 'Resolved' THEN 1 ELSE 0 END)       AS open_complaints,
       CASE
           WHEN SUM(CASE WHEN c.priority = 'High' AND c.status <> 'Resolved' THEN 1 ELSE 0 END) > 0
           THEN 'High Risk'
           WHEN SUM(CASE WHEN c.status <> 'Resolved' THEN 1 ELSE 0 END) > 1
           THEN 'Medium Risk'
           ELSE 'Low Risk'
       END                                                            AS risk_level
FROM users    u
JOIN complaint c ON u.user_id = c.user_id
GROUP BY u.user_id, u.name
HAVING COUNT(c.complaint_id) > (
    SELECT AVG(user_count)
    FROM (SELECT COUNT(*) AS user_count FROM complaint GROUP BY user_id)
)
AND SUM(CASE WHEN c.status <> 'Resolved' THEN 1 ELSE 0 END) > 0
ORDER BY CASE WHEN MAX(CASE WHEN c.priority = 'High' AND c.status <> 'Resolved'
                            THEN 1 ELSE 0 END) = 1 THEN 1
              WHEN SUM(CASE WHEN c.status <> 'Resolved' THEN 1 ELSE 0 END) > 1 THEN 2
              ELSE 3 END;

-- Q29. Users who have filed complaints across more distinct categories than
--      the overall average category-diversity per user
--      (inline view comparison + HAVING with nested AVG).
SELECT u.name              AS user_name,
       COUNT(DISTINCT c.category_id) AS distinct_categories
FROM users    u
JOIN complaint c ON u.user_id = c.user_id
GROUP BY u.user_id, u.name
HAVING COUNT(DISTINCT c.category_id) > (
    SELECT AVG(cat_diversity)
    FROM (
        SELECT COUNT(DISTINCT category_id) AS cat_diversity
        FROM complaint
        GROUP BY user_id
    )
);

-- Q30. Full complaint health dashboard per department: total, resolved,
--      pending, in-progress, average resolution days, average feedback
--      rating, and a benchmark label comparing each department's average
--      resolution time to the system-wide average (two scalar subqueries
--      inside CASE, plus multi-metric GROUP BY aggregation).
SELECT d.department_name,
       COUNT(c.complaint_id)                                                       AS total_complaints,
       SUM(CASE WHEN c.status = 'Resolved'    THEN 1 ELSE 0 END)                  AS resolved,
       SUM(CASE WHEN c.status = 'Pending'     THEN 1 ELSE 0 END)                  AS pending,
       SUM(CASE WHEN c.status = 'In Progress' THEN 1 ELSE 0 END)                  AS in_progress,
       ROUND(AVG(CASE WHEN c.status = 'Resolved'
                      THEN c.date_resolved - c.date_registered END), 2)            AS avg_resolution_days,
       ROUND(AVG(f.rating), 2)                                                     AS avg_feedback_rating,
       CASE
           WHEN ROUND(AVG(CASE WHEN c.status = 'Resolved'
                               THEN c.date_resolved - c.date_registered END), 2)
                > (SELECT ROUND(AVG(date_resolved - date_registered), 2)
                   FROM complaint WHERE status = 'Resolved')
           THEN 'Slower than system avg'
           WHEN ROUND(AVG(CASE WHEN c.status = 'Resolved'
                               THEN c.date_resolved - c.date_registered END), 2)
                < (SELECT ROUND(AVG(date_resolved - date_registered), 2)
                   FROM complaint WHERE status = 'Resolved')
           THEN 'Faster than system avg'
           ELSE 'On par'
       END                                                                         AS resolution_benchmark
FROM department d
LEFT JOIN complaint         c ON d.department_id = c.department_id
LEFT JOIN complaint_feedback f ON c.complaint_id  = f.complaint_id
GROUP BY d.department_name
ORDER BY total_complaints DESC NULLS LAST;
/* ===== SECTION 3A: VIEW DEFINITIONS (vw_complaint_summary, vw_department_performance, vw_staff_workload) ===== */
CREATE OR REPLACE VIEW vw_complaint_summary AS
SELECT c.complaint_id, u.name AS user_name, d.department_name AS department, cc.category_name AS category,
       c.status, c.priority, c.date_registered, c.date_resolved
FROM complaint c
JOIN users u ON c.user_id = u.user_id
JOIN department d ON c.department_id = d.department_id
JOIN complaint_category cc ON c.category_id = cc.category_id;

CREATE OR REPLACE VIEW vw_department_performance AS
SELECT d.department_name,
       COUNT(c.complaint_id) AS total_complaints,
       SUM(CASE WHEN c.status = 'Resolved' THEN 1 ELSE 0 END) AS resolved,
       SUM(CASE WHEN c.status = 'Pending' THEN 1 ELSE 0 END) AS pending,
       ROUND(AVG(f.rating), 2) AS avg_rating,
       ROUND(AVG(CASE WHEN c.status = 'Resolved' THEN c.date_resolved - c.date_registered END), 2) AS avg_resolution_days
FROM department d
LEFT JOIN complaint c ON d.department_id = c.department_id
LEFT JOIN complaint_feedback f ON c.complaint_id = f.complaint_id
GROUP BY d.department_name;

CREATE OR REPLACE VIEW vw_staff_workload AS
SELECT s.name AS staff_name, d.department_name AS department,
       COUNT(a.assignment_id) AS total_assigned,
       SUM(CASE WHEN c.status = 'Resolved' THEN 1 ELSE 0 END) AS resolved_count
FROM staff s
JOIN department d ON s.department_id = d.department_id
LEFT JOIN complaint_assignment a ON s.staff_id = a.staff_id
LEFT JOIN complaint c ON a.complaint_id = c.complaint_id
GROUP BY s.name, d.department_name;

-- Views above are used by Q30 (dashboard) and referenced in SECTION 4 PL/SQL functions.
-- All 30 complex subqueries are in SECTION 3 above.

/* ===== SECTION 4: PL/SQL COMPONENTS ===== */
CREATE OR REPLACE PROCEDURE register_complaint(
  p_user_id IN NUMBER,
  p_category_id IN NUMBER,
  p_department_id IN NUMBER,
  p_description IN VARCHAR2,
  p_priority IN VARCHAR2
) AS
  v_complaint_id NUMBER;
  v_history_id NUMBER;
  v_dummy NUMBER;
BEGIN
  SELECT 1 INTO v_dummy FROM users WHERE user_id = p_user_id;
  SELECT 1 INTO v_dummy FROM complaint_category WHERE category_id = p_category_id;
  SELECT 1 INTO v_dummy FROM department WHERE department_id = p_department_id;

  v_complaint_id := seq_complaint_id.NEXTVAL;
  v_history_id := seq_history_id.NEXTVAL;

  INSERT INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved)
  VALUES (v_complaint_id, p_user_id, p_category_id, p_department_id, p_description, 'Pending', p_priority, SYSDATE, NULL);

  INSERT INTO complaint_status_history (history_id, complaint_id, status, updated_on)
  VALUES (v_history_id, v_complaint_id, 'Pending', SYSDATE);

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Complaint registered successfully. Complaint ID: ' || v_complaint_id);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Registration failed: user, category, or department does not exist.');
  WHEN DUP_VAL_ON_INDEX THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Registration failed: duplicate key encountered.');
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Registration failed: ' || SQLERRM);
END register_complaint;
/

CREATE OR REPLACE PROCEDURE assign_complaint(
  p_complaint_id IN NUMBER,
  p_staff_id IN NUMBER
) AS
  v_dummy NUMBER;
  v_assignment_count NUMBER;
  e_already_assigned EXCEPTION;
BEGIN
  SELECT 1 INTO v_dummy FROM complaint WHERE complaint_id = p_complaint_id;
  SELECT 1 INTO v_dummy FROM staff WHERE staff_id = p_staff_id;
  SELECT COUNT(*) INTO v_assignment_count FROM complaint_assignment WHERE complaint_id = p_complaint_id;

  IF v_assignment_count > 0 THEN
    RAISE e_already_assigned;
  END IF;

  INSERT INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date)
  VALUES (seq_assignment_id.NEXTVAL, p_complaint_id, p_staff_id, SYSDATE);

  UPDATE complaint
  SET status = 'In Progress'
  WHERE complaint_id = p_complaint_id
    AND status <> 'Resolved';

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Complaint ' || p_complaint_id || ' assigned to staff ' || p_staff_id || '.');
EXCEPTION
  WHEN e_already_assigned THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Assignment failed: complaint is already assigned.');
  WHEN NO_DATA_FOUND THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Assignment failed: complaint or staff does not exist.');
  WHEN DUP_VAL_ON_INDEX THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Assignment failed: duplicate assignment key.');
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Assignment failed: ' || SQLERRM);
END assign_complaint;
/

CREATE OR REPLACE FUNCTION get_resolved_count(p_dept_id IN NUMBER)
RETURN NUMBER AS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM complaint
  WHERE department_id = p_dept_id
    AND status = 'Resolved';
  RETURN v_count;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('get_resolved_count failed: ' || SQLERRM);
    RETURN 0;
END get_resolved_count;
/

CREATE OR REPLACE FUNCTION get_avg_rating(p_dept_id IN NUMBER)
RETURN NUMBER AS
  v_avg NUMBER;
BEGIN
  SELECT ROUND(AVG(f.rating), 2) INTO v_avg
  FROM complaint_feedback f
  JOIN complaint c ON f.complaint_id = c.complaint_id
  WHERE c.department_id = p_dept_id;
  RETURN NVL(v_avg, 0);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('get_avg_rating failed: ' || SQLERRM);
    RETURN 0;
END get_avg_rating;
/

CREATE OR REPLACE TRIGGER trg_auto_resolve_date
BEFORE UPDATE ON complaint
FOR EACH ROW
WHEN (NEW.status = 'Resolved' AND OLD.status <> 'Resolved')
BEGIN
  :NEW.date_resolved := SYSDATE;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20001, 'trg_auto_resolve_date failed: ' || SQLERRM);
END;
/

CREATE OR REPLACE TRIGGER trg_status_history
AFTER UPDATE OF status ON complaint
FOR EACH ROW
WHEN (NEW.status <> OLD.status)
BEGIN
  INSERT INTO complaint_status_history (history_id, complaint_id, status, updated_on)
  VALUES (seq_history_id.NEXTVAL, :NEW.complaint_id, :NEW.status, SYSDATE);
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20002, 'trg_status_history failed: ' || SQLERRM);
END;
/

-- Cursor: Department-wise Complaint Report
DECLARE
  CURSOR dept_report_cursor IS
    SELECT d.department_name,
           COUNT(c.complaint_id) AS total,
           SUM(CASE WHEN c.status = 'Resolved' THEN 1 ELSE 0 END) AS resolved,
           SUM(CASE WHEN c.status = 'Pending' THEN 1 ELSE 0 END) AS pending
    FROM department d LEFT JOIN complaint c ON d.department_id = c.department_id
    GROUP BY d.department_name
    ORDER BY d.department_name;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Department-wise Complaint Report');
  FOR rec IN dept_report_cursor LOOP
    DBMS_OUTPUT.PUT_LINE(rec.department_name || ' | Total: ' || rec.total || ' | Resolved: ' || rec.resolved || ' | Pending: ' || rec.pending);
  END LOOP;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No department report data found.');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Department report failed: ' || SQLERRM);
END;
/

-- Cursor: Generate Escalation Report
DECLARE
  CURSOR escalation_cursor IS
    SELECT e.escalation_id, c.complaint_id, u.name AS user_name,
           d.department_name, e.escalation_level, e.escalation_date
    FROM complaint_escalation e
    JOIN complaint c ON e.complaint_id = c.complaint_id
    JOIN users u ON c.user_id = u.user_id
    JOIN department d ON c.department_id = d.department_id
    ORDER BY e.escalation_date DESC;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Escalation Report');
  FOR rec IN escalation_cursor LOOP
    DBMS_OUTPUT.PUT_LINE('Escalation ' || rec.escalation_id || ' | Complaint ' || rec.complaint_id || ' | User: ' || rec.user_name || ' | Department: ' || rec.department_name || ' | Level: ' || rec.escalation_level || ' | Date: ' || TO_CHAR(rec.escalation_date, 'YYYY-MM-DD'));
  END LOOP;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No escalation data found.');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Escalation report failed: ' || SQLERRM);
END;
/

/* ===== SECTION 5: TRANSACTION MANAGEMENT ===== */
DECLARE
  v_complaint_id NUMBER;
  v_history_id NUMBER;
BEGIN
  v_complaint_id := seq_complaint_id.NEXTVAL;

  INSERT INTO complaint (complaint_id, user_id, category_id, department_id, description, status, priority, date_registered, date_resolved)
  VALUES (v_complaint_id, 1, 4, 2, 'Transaction test complaint for unstable Wi-Fi in library.', 'Pending', 'High', SYSDATE, NULL);
  DBMS_OUTPUT.PUT_LINE('Step 1 complete: complaint inserted with ID ' || v_complaint_id);
  SAVEPOINT sp_after_complaint;

  INSERT INTO complaint_assignment (assignment_id, complaint_id, staff_id, assigned_date)
  VALUES (seq_assignment_id.NEXTVAL, v_complaint_id, 3, SYSDATE);
  UPDATE complaint SET status = 'In Progress' WHERE complaint_id = v_complaint_id;
  DBMS_OUTPUT.PUT_LINE('Step 2 complete: complaint assigned.');
  SAVEPOINT sp_after_assignment;

  v_history_id := seq_history_id.NEXTVAL;
  INSERT INTO complaint_status_history (history_id, complaint_id, status, updated_on)
  VALUES (v_history_id, v_complaint_id, 'In Progress', SYSDATE);

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Transaction committed successfully.');
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    ROLLBACK TO sp_after_assignment;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Step 3 failed due to duplicate key. Rolled back to assignment savepoint and committed earlier steps.');
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO sp_after_complaint;
    DBMS_OUTPUT.PUT_LINE('Transaction failed: referenced data missing. Rolled back to first savepoint.');
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Transaction failed and was rolled back: ' || SQLERRM);
END;
/
