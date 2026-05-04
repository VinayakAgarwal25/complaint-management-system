# Complaint Management System

**UCS310 - Database Management System | Thapar Institute of Engineering and Technology | 2025-2026**

## Project Team

| Name | Roll Number |
|---|---:|
| Vinayak Agarwal | 1024030915 |
| Shubhr Gupta | 1024030919 |
| Aryan Juneja | 1024030920 |

## 1. Project Overview

The Complaint Management System is an Oracle SQL and PL/SQL based academic database project for logging, tracking, assigning, resolving, escalating, and reviewing complaints raised by users across departments.

The current folder also includes a static browser dashboard demo built with HTML, CSS, and JavaScript. The dashboard mirrors a small sample of the database records for presentation purposes; the main database implementation remains in Oracle SQL and PL/SQL.

**Key Objectives**

- Store complainant, department, staff, category, complaint, assignment, feedback, attachment, escalation, and history data in a normalized schema.
- Enforce integrity using primary keys, foreign keys, unique constraints, check constraints, and sequences.
- Automate complaint lifecycle behavior using PL/SQL procedures and triggers.
- Provide analytical reporting using 30 advanced SQL queries and 3 reusable views.
- Demonstrate transaction control using `SAVEPOINT`, `ROLLBACK TO`, and `COMMIT`.
- Provide a browser-based UI demo for dashboard, complaint list, department performance, and complaint registration flow.

## 2. Technology Stack

| Component | Details |
|---|---|
| Database Engine | Oracle Database |
| SQL Tool | Oracle SQL Developer |
| Database Language | SQL and PL/SQL |
| Frontend Demo | HTML, CSS, JavaScript |
| Key DBMS Concepts | DDL, DML, DQL, joins, subqueries, `EXISTS`, `NOT EXISTS`, `ANY`, `ALL`, inline views, views, stored procedures, functions, triggers, cursors, transactions |

## 3. Current Project Files

| File | Current Purpose |
|---|---|
| `complaint_management_system (1).sql` | Main combined Oracle script containing cleanup, schema creation, sample data, 30 queries, 3 views, PL/SQL units, cursor blocks, and transaction demo. |
| `03_queries.sql` | Separate copy of the 30 advanced SELECT queries for easier review and execution. |
| `index.html` | Static browser dashboard/demo UI. |
| `app.js` | Frontend demo data, filtering, metrics, modal details, view switching, and form behavior. |
| `styles.css` | Styling for the static dashboard/demo UI. |
| `Complaint_Management_System_Report_final.docx` | Final report document. |
| `README (1).md` | This project overview and execution guide. |

> Note: The README has been updated to match the files currently present in this folder. Split scripts such as `01_create_tables.sql`, `02_insert_data.sql`, and `04_plsql.sql` are not present in the current project directory.

## 4. Database Schema

The Oracle database schema contains 10 normalized relational tables.

| Table Name | Purpose |
|---|---|
| `users` | Complainant details: user id, name, and email. |
| `department` | Departments responsible for handling complaints. |
| `staff` | Staff members linked to departments. |
| `complaint_category` | Complaint categories such as Noise, Water Leakage, Power Outage, Internet Issue, Cleanliness, and others. |
| `complaint` | Core complaint table containing complainant, category, department, description, status, priority, registration date, and resolution date. |
| `complaint_status_history` | Audit log of complaint status events. |
| `complaint_assignment` | One-to-one mapping of complaints to assigned staff members. |
| `complaint_feedback` | User ratings and comments for resolved complaints. |
| `complaint_attachment` | Evidence/attachment file paths linked to complaints. |
| `complaint_escalation` | Escalation level and escalation date records. |

**Schema Objects**

| Object Type | Count / Names |
|---|---|
| Tables | 10 tables |
| Sequences | `seq_complaint_id`, `seq_history_id`, `seq_assignment_id`, `seq_feedback_id`, `seq_attachment_id`, `seq_escalation_id` |
| Views | `vw_complaint_summary`, `vw_department_performance`, `vw_staff_workload` |
| Procedures | `register_complaint`, `assign_complaint` |
| Functions | `get_resolved_count`, `get_avg_rating` |
| Triggers | `trg_auto_resolve_date`, `trg_status_history` |
| Cursor Blocks | Department report cursor, escalation report cursor |

## 5. Sample Data

The initial inserted dataset in the combined SQL script contains the following sample records.

| Entity | Rows Inserted |
|---|---:|
| Users | 30 |
| Departments | 8 |
| Staff Members | 20 |
| Complaint Categories | 10 |
| Complaints | 50 |
| Status History Records | 60 |
| Assignments | 40 |
| Feedback Records | 25 |
| Attachments | 20 |
| Escalations | 15 |

Complaint dates span from `2024-01-05` to `2025-06-30`.

The PL/SQL procedure and transaction demo sections also contain extra demonstration inserts using sequence-generated ids. These are separate from the initial sample dataset above.

## 6. Combined SQL Script Sections

`complaint_management_system (1).sql` is the main executable Oracle script.

| Section | Content |
|---|---|
| Section 0 | Cleanup: drops views, tables, and sequences if they already exist. |
| Section 1 | DDL: creates all tables, constraints, and sequences. |
| Section 2 | DML: inserts realistic sample data and commits it. |
| Section 3 | 30 advanced SELECT queries covering subqueries, `EXISTS` / `NOT EXISTS`, inline views, `ANY` / `ALL`, grouped analytics, and window functions. |
| Section 3A | Creates three analytical views. |
| Section 4 | PL/SQL procedures, functions, triggers, and cursor report blocks. |
| Section 5 | Transaction control demo using savepoints, rollback, and commit. |

## 7. Query Coverage

The project contains 30 advanced SELECT queries in both `complaint_management_system (1).sql` and `03_queries.sql`.

| Range | Focus Area | Techniques Demonstrated |
|---|---|---|
| Q1-Q8 | Correlated and aggregate analysis | Correlated subqueries, scalar subqueries, nested aggregates, grouped analysis, and window functions. |
| Q9-Q16 | Existence checks | `EXISTS`, `NOT EXISTS`, anti-join patterns, relational division, and filtering based on related records. |
| Q17-Q23 | Nested and multi-level analysis | Multi-level nesting, inline views, grouped subqueries, ranked month/category/staff analysis, and window functions. |
| Q24-Q30 | Comparative and dashboard queries | `ANY`, `ALL`, comparative subqueries, priority filters, analytical `CASE`, and department health reporting. |

**Selected Query Highlights**

- Q11 uses double `NOT EXISTS` for relational division.
- Q17 ranks complaint volume by month.
- Q23 finds top staff members per department using grouped inline views and correlated comparison.
- Q27 labels resolved complaints as above or below category average.
- Q30 produces a department health dashboard with totals, status counts, average resolution days, average rating, and benchmark labeling.

## 8. PL/SQL Features

| Type | Name | Purpose |
|---|---|---|
| Procedure | `register_complaint` | Inserts a new complaint and initial `Pending` status history record. |
| Procedure | `assign_complaint` | Assigns a complaint to staff and updates complaint status to `In Progress`. |
| Function | `get_resolved_count` | Returns resolved complaint count for a department. |
| Function | `get_avg_rating` | Returns average feedback rating for a department. |
| Trigger | `trg_auto_resolve_date` | Auto-sets `date_resolved` when a complaint becomes `Resolved`. |
| Trigger | `trg_status_history` | Inserts a status history record whenever complaint status changes. |
| Cursor Block | Department Report | Prints department-wise total, resolved, and pending counts using `DBMS_OUTPUT`. |
| Cursor Block | Escalation Report | Prints escalation details using joins across escalation, complaint, user, and department data. |
| Transaction Demo | Section 5 | Demonstrates savepoints, rollback to savepoint, and commit. |

## 9. Static Frontend Demo

The current project includes a browser-based static demo:

- Dashboard metrics for total complaints, open complaints, high-priority open complaints, and resolution rate.
- Status and priority summaries.
- Recent complaint table.
- Complaint list with search and filters for status, priority, and department.
- Department performance view.
- Complaint registration form that mirrors the `complaint` table and `register_complaint` procedure concept.
- Complaint detail modal.

The UI demo uses in-memory JavaScript sample data. It does not connect directly to Oracle Database.

## 10. Execution Guide

### Run the Oracle Database Script

1. Install Oracle Database and Oracle SQL Developer.
2. Open Oracle SQL Developer and connect to your Oracle schema/user.
3. Open `complaint_management_system (1).sql`.
4. Run it as a script, not just as a single statement.
5. Keep `SET SERVEROUTPUT ON` enabled to view PL/SQL cursor and procedure output.
6. Review the Script Output panel for `DBMS_OUTPUT` messages and any execution results.

### Run Only the Query File

1. First run `complaint_management_system (1).sql` so the schema and data exist.
2. Open `03_queries.sql`.
3. Run the file in Oracle SQL Developer to execute the 30 advanced queries separately.

### Open the Static Dashboard Demo

Open `index.html` in a browser. No build step, package installation, or development server is required.

## 11. Important Compatibility Notes

- The database scripts use Oracle-specific SQL and PL/SQL features.
- The scripts are not directly executable in MySQL Workbench or PostgreSQL.
- Oracle-specific features used include `DBMS_OUTPUT`, sequences, anonymous PL/SQL blocks, `DATE` literals, and `/` block terminators.
- The static dashboard is a demo UI and does not persist data to the Oracle database.

## 12. Concepts Covered

| Concept | Implementation |
|---|---|
| DDL | `CREATE TABLE`, `DROP`, primary keys, foreign keys, unique constraints, check constraints, sequences |
| DML | `INSERT ALL`, realistic sample records, `UPDATE`, `COMMIT` |
| DQL | 30 advanced SELECT queries |
| Views | 3 analytical views for summary, department performance, and staff workload |
| Procedures | Complaint registration and assignment workflows |
| Functions | Department resolved count and average rating calculations |
| Triggers | Automatic resolved date and status history audit logging |
| Cursors | Department and escalation reports |
| Transactions | Savepoint, rollback to savepoint, and commit demo |
| Frontend Demo | Static HTML/CSS/JS dashboard for presentation |
