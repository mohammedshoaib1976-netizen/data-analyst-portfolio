/* ============================================================
   PROJECT 1: EMPLOYEE DATABASE
   Tables: Department, Employee, Salary, Attendance
   Skills demonstrated: JOINs, GROUP BY/HAVING, subqueries,
   CASE, window functions, CTEs
   ============================================================ */

-- ---------- SCHEMA ----------
DROP TABLE IF EXISTS Attendance;
DROP TABLE IF EXISTS Salary;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Department;

CREATE TABLE Department (
    dept_id     INTEGER PRIMARY KEY,
    dept_name   TEXT NOT NULL,
    location    TEXT
);

CREATE TABLE Employee (
    emp_id      INTEGER PRIMARY KEY,
    first_name  TEXT NOT NULL,
    last_name   TEXT NOT NULL,
    dept_id     INTEGER,
    manager_id  INTEGER,
    hire_date   DATE,
    job_title   TEXT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id),
    FOREIGN KEY (manager_id) REFERENCES Employee(emp_id)
);

CREATE TABLE Salary (
    salary_id   INTEGER PRIMARY KEY,
    emp_id      INTEGER NOT NULL,
    basic_pay   DECIMAL(10,2),
    bonus       DECIMAL(10,2),
    effective_date DATE,
    FOREIGN KEY (emp_id) REFERENCES Employee(emp_id)
);

CREATE TABLE Attendance (
    attendance_id INTEGER PRIMARY KEY,
    emp_id      INTEGER NOT NULL,
    work_date   DATE,
    status      TEXT CHECK (status IN ('Present','Absent','Leave','Half Day')),
    FOREIGN KEY (emp_id) REFERENCES Employee(emp_id)
);

-- ---------- SAMPLE DATA ----------
INSERT INTO Department (dept_id, dept_name, location) VALUES
(1, 'Sales', 'Bengaluru'),
(2, 'IT', 'Bengaluru'),
(3, 'HR', 'Mumbai'),
(4, 'Finance', 'Mumbai'),
(5, 'Marketing', 'Pune');

INSERT INTO Employee (emp_id, first_name, last_name, dept_id, manager_id, hire_date, job_title) VALUES
(1, 'Aarav', 'Sharma', 1, NULL, '2021-03-15', 'Sales Manager'),
(2, 'Priya', 'Nair', 1, 1, '2022-06-01', 'Sales Executive'),
(3, 'Rohan', 'Mehta', 2, NULL, '2020-01-10', 'IT Manager'),
(4, 'Sneha', 'Kapoor', 2, 3, '2022-09-12', 'Software Engineer'),
(5, 'Vikram', 'Singh', 3, NULL, '2019-11-05', 'HR Manager'),
(6, 'Anjali', 'Rao', 3, 5, '2023-02-20', 'HR Executive'),
(7, 'Karan', 'Malhotra', 4, NULL, '2020-07-01', 'Finance Manager'),
(8, 'Divya', 'Iyer', 4, 7, '2023-05-15', 'Financial Analyst'),
(9, 'Arjun', 'Verma', 2, 3, '2021-08-18', 'Software Engineer'),
(10, 'Neha', 'Joshi', 1, 1, '2023-01-09', 'Sales Executive'),
(11, 'Ishaan', 'Bose', 5, NULL, '2022-03-01', 'Marketing Manager'),
(12, 'Meera', 'Pillai', 5, 11, '2023-07-22', 'Marketing Executive');

INSERT INTO Salary (salary_id, emp_id, basic_pay, bonus, effective_date) VALUES
(1, 1, 80000, 8000, '2026-01-01'),
(2, 2, 40000, 3000, '2026-01-01'),
(3, 3, 90000, 9000, '2026-01-01'),
(4, 4, 55000, 4000, '2026-01-01'),
(5, 5, 75000, 6000, '2026-01-01'),
(6, 6, 35000, 2000, '2026-01-01'),
(7, 7, 85000, 8500, '2026-01-01'),
(8, 8, 45000, 3500, '2026-01-01'),
(9, 9, 60000, 4500, '2026-01-01'),
(10, 10, 32000, 2000, '2026-01-01'),
(11, 11, 70000, 5500, '2026-01-01'),
(12, 12, 30000, 1500, '2026-01-01');

INSERT INTO Attendance (attendance_id, emp_id, work_date, status) VALUES
(1, 1, '2026-06-01', 'Present'), (2, 1, '2026-06-02', 'Present'), (3, 1, '2026-06-03', 'Leave'),
(4, 2, '2026-06-01', 'Present'), (5, 2, '2026-06-02', 'Absent'), (6, 2, '2026-06-03', 'Present'),
(7, 3, '2026-06-01', 'Present'), (8, 3, '2026-06-02', 'Present'), (9, 3, '2026-06-03', 'Present'),
(10, 4, '2026-06-01', 'Half Day'), (11, 4, '2026-06-02', 'Present'), (12, 4, '2026-06-03', 'Present'),
(13, 5, '2026-06-01', 'Present'), (14, 5, '2026-06-02', 'Present'), (15, 5, '2026-06-03', 'Leave'),
(16, 6, '2026-06-01', 'Present'), (17, 6, '2026-06-02', 'Present'), (18, 6, '2026-06-03', 'Absent'),
(19, 9, '2026-06-01', 'Present'), (20, 9, '2026-06-02', 'Leave'), (21, 9, '2026-06-03', 'Present');

/* ============================================================
   ANALYSIS QUERIES
   ============================================================ */

-- Q1: List all employees with their department name and manager's name
SELECT
    e.emp_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    d.dept_name,
    m.first_name || ' ' || m.last_name AS manager_name,
    e.job_title
FROM Employee e
LEFT JOIN Department d ON e.dept_id = d.dept_id
LEFT JOIN Employee m ON e.manager_id = m.emp_id
ORDER BY d.dept_name, e.emp_id;

-- Q2: Total monthly payroll cost (basic + bonus) per department
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS headcount,
    SUM(s.basic_pay) AS total_basic,
    SUM(s.bonus) AS total_bonus,
    SUM(s.basic_pay + s.bonus) AS total_payroll
FROM Department d
JOIN Employee e ON d.dept_id = e.dept_id
JOIN Salary s ON e.emp_id = s.emp_id
GROUP BY d.dept_name
ORDER BY total_payroll DESC;

-- Q3: Departments with average basic pay above 50,000 (GROUP BY + HAVING)
SELECT
    d.dept_name,
    ROUND(AVG(s.basic_pay), 2) AS avg_basic_pay
FROM Department d
JOIN Employee e ON d.dept_id = e.dept_id
JOIN Salary s ON e.emp_id = s.emp_id
GROUP BY d.dept_name
HAVING AVG(s.basic_pay) > 50000
ORDER BY avg_basic_pay DESC;

-- Q4: Rank employees by total compensation within each department (window function)
SELECT
    d.dept_name,
    e.first_name || ' ' || e.last_name AS employee_name,
    s.basic_pay + s.bonus AS total_compensation,
    RANK() OVER (PARTITION BY d.dept_name ORDER BY s.basic_pay + s.bonus DESC) AS dept_rank
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id
JOIN Salary s ON e.emp_id = s.emp_id
ORDER BY d.dept_name, dept_rank;

-- Q5: Employees earning more than their department's average (subquery)
SELECT
    e.first_name || ' ' || e.last_name AS employee_name,
    d.dept_name,
    s.basic_pay
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id
JOIN Salary s ON e.emp_id = s.emp_id
WHERE s.basic_pay > (
    SELECT AVG(s2.basic_pay)
    FROM Employee e2
    JOIN Salary s2 ON e2.emp_id = s2.emp_id
    WHERE e2.dept_id = e.dept_id
)
ORDER BY d.dept_name;

-- Q6: Attendance summary per employee (attendance %) using CASE + GROUP BY
SELECT
    e.first_name || ' ' || e.last_name AS employee_name,
    COUNT(a.attendance_id) AS total_days_logged,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS days_present,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS days_absent,
    ROUND(100.0 * SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) / COUNT(a.attendance_id), 1) AS attendance_pct
FROM Employee e
JOIN Attendance a ON e.emp_id = a.emp_id
GROUP BY e.emp_id
ORDER BY attendance_pct DESC;

-- Q7: Managers and the number of direct reports (self-join + GROUP BY)
SELECT
    m.first_name || ' ' || m.last_name AS manager_name,
    COUNT(e.emp_id) AS direct_reports
FROM Employee m
JOIN Employee e ON e.manager_id = m.emp_id
GROUP BY m.emp_id
ORDER BY direct_reports DESC;

-- Q8: CTE - Top 3 highest-paid employees company-wide
WITH RankedSalaries AS (
    SELECT
        e.first_name || ' ' || e.last_name AS employee_name,
        d.dept_name,
        s.basic_pay + s.bonus AS total_pay,
        ROW_NUMBER() OVER (ORDER BY s.basic_pay + s.bonus DESC) AS rn
    FROM Employee e
    JOIN Department d ON e.dept_id = d.dept_id
    JOIN Salary s ON e.emp_id = s.emp_id
)
SELECT employee_name, dept_name, total_pay
FROM RankedSalaries
WHERE rn <= 3;

-- Q9: Employees hired in the last 3 years (date filtering)
SELECT
    first_name || ' ' || last_name AS employee_name,
    hire_date,
    job_title
FROM Employee
WHERE hire_date >= DATE('2026-06-30', '-3 years')
ORDER BY hire_date DESC;

-- Q10: Department headcount vs open management structure (LEFT JOIN + IS NULL)
SELECT
    d.dept_name,
    e.first_name || ' ' || e.last_name AS employee_without_manager
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id
WHERE e.manager_id IS NULL;
