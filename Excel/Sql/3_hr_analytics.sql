/* ============================================================
   PROJECT 3: HR ANALYTICS
   Focus: Attrition, Salary, Leaves, Performance
   Tables: Employees, Leaves, PerformanceReviews
   Skills demonstrated: JOINs, CASE, window functions, CTEs,
   date functions, subqueries
   ============================================================ */

-- ---------- SCHEMA ----------
DROP TABLE IF EXISTS PerformanceReviews;
DROP TABLE IF EXISTS Leaves;
DROP TABLE IF EXISTS Employees;

CREATE TABLE Employees (
    emp_id       INTEGER PRIMARY KEY,
    emp_name     TEXT NOT NULL,
    department   TEXT,
    hire_date    DATE,
    exit_date    DATE,             -- NULL if still active
    salary       DECIMAL(10,2),
    status       TEXT CHECK (status IN ('Active','Exited'))
);

CREATE TABLE Leaves (
    leave_id     INTEGER PRIMARY KEY,
    emp_id       INTEGER NOT NULL,
    leave_type   TEXT,
    start_date   DATE,
    end_date     DATE,
    days_taken   INTEGER,
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
);

CREATE TABLE PerformanceReviews (
    review_id    INTEGER PRIMARY KEY,
    emp_id       INTEGER NOT NULL,
    review_year  INTEGER,
    rating       INTEGER CHECK (rating BETWEEN 1 AND 5),
    FOREIGN KEY (emp_id) REFERENCES Employees(emp_id)
);

-- ---------- SAMPLE DATA ----------
INSERT INTO Employees (emp_id, emp_name, department, hire_date, exit_date, salary, status) VALUES
(1, 'Aarav Sharma', 'Sales', '2021-03-15', NULL, 80000, 'Active'),
(2, 'Priya Nair', 'Sales', '2022-06-01', '2026-04-30', 40000, 'Exited'),
(3, 'Rohan Mehta', 'IT', '2020-01-10', NULL, 90000, 'Active'),
(4, 'Sneha Kapoor', 'IT', '2022-09-12', NULL, 55000, 'Active'),
(5, 'Vikram Singh', 'HR', '2019-11-05', NULL, 75000, 'Active'),
(6, 'Anjali Rao', 'HR', '2023-02-20', '2026-05-15', 35000, 'Exited'),
(7, 'Karan Malhotra', 'Finance', '2020-07-01', NULL, 85000, 'Active'),
(8, 'Divya Iyer', 'Finance', '2023-05-15', NULL, 45000, 'Active'),
(9, 'Arjun Verma', 'IT', '2021-08-18', '2026-02-28', 60000, 'Exited'),
(10, 'Neha Joshi', 'Sales', '2023-01-09', NULL, 32000, 'Active'),
(11, 'Ishaan Bose', 'Marketing', '2022-03-01', NULL, 70000, 'Active'),
(12, 'Meera Pillai', 'Marketing', '2023-07-22', '2026-06-10', 30000, 'Exited');

INSERT INTO Leaves (leave_id, emp_id, leave_type, start_date, end_date, days_taken) VALUES
(1, 1, 'Sick', '2026-01-10', '2026-01-11', 2),
(2, 1, 'Casual', '2026-03-05', '2026-03-05', 1),
(3, 3, 'Annual', '2026-02-01', '2026-02-05', 5),
(4, 4, 'Sick', '2026-04-12', '2026-04-13', 2),
(5, 5, 'Casual', '2026-01-20', '2026-01-20', 1),
(6, 7, 'Annual', '2026-05-01', '2026-05-07', 7),
(7, 8, 'Sick', '2026-03-15', '2026-03-16', 2),
(8, 10, 'Casual', '2026-02-10', '2026-02-10', 1),
(9, 11, 'Annual', '2026-06-01', '2026-06-04', 4),
(10, 3, 'Sick', '2026-05-20', '2026-05-21', 2);

INSERT INTO PerformanceReviews (review_id, emp_id, review_year, rating) VALUES
(1, 1, 2025, 4), (2, 2, 2025, 3), (3, 3, 2025, 5), (4, 4, 2025, 4),
(5, 5, 2025, 4), (6, 6, 2025, 2), (7, 7, 2025, 5), (8, 8, 2025, 3),
(9, 9, 2025, 2), (10, 10, 2025, 4), (11, 11, 2025, 4), (12, 12, 2025, 3);

/* ============================================================
   ANALYSIS QUERIES
   ============================================================ */

-- Q1: Overall attrition rate (exited / total)
SELECT
    COUNT(*) AS total_employees,
    SUM(CASE WHEN status = 'Exited' THEN 1 ELSE 0 END) AS exited_employees,
    ROUND(100.0 * SUM(CASE WHEN status = 'Exited' THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_rate_pct
FROM Employees;

-- Q2: Attrition rate by department
SELECT
    department,
    COUNT(*) AS headcount,
    SUM(CASE WHEN status = 'Exited' THEN 1 ELSE 0 END) AS exits,
    ROUND(100.0 * SUM(CASE WHEN status = 'Exited' THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_rate_pct
FROM Employees
GROUP BY department
ORDER BY attrition_rate_pct DESC;

-- Q3: Average tenure (in months) of exited employees vs active employees
SELECT
    status,
    ROUND(AVG(
        (julianday(COALESCE(exit_date, '2026-06-30')) - julianday(hire_date)) / 30.0
    ), 1) AS avg_tenure_months
FROM Employees
GROUP BY status;

-- Q4: Salary distribution by department (min, max, avg)
SELECT
    department,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary,
    ROUND(AVG(salary), 0) AS avg_salary
FROM Employees
GROUP BY department
ORDER BY avg_salary DESC;

-- Q5: Total leave days taken per employee (LEFT JOIN to include employees with 0 leaves)
SELECT
    e.emp_name,
    e.department,
    COALESCE(SUM(l.days_taken), 0) AS total_leave_days
FROM Employees e
LEFT JOIN Leaves l ON e.emp_id = l.emp_id
GROUP BY e.emp_id
ORDER BY total_leave_days DESC;

-- Q6: Performance rating vs attrition - do low performers leave more? (JOIN + CASE)
SELECT
    CASE WHEN pr.rating <= 2 THEN 'Low (1-2)'
         WHEN pr.rating = 3 THEN 'Medium (3)'
         ELSE 'High (4-5)' END AS performance_band,
    COUNT(*) AS total,
    SUM(CASE WHEN e.status = 'Exited' THEN 1 ELSE 0 END) AS exited,
    ROUND(100.0 * SUM(CASE WHEN e.status = 'Exited' THEN 1 ELSE 0 END) / COUNT(*), 1) AS attrition_pct
FROM Employees e
JOIN PerformanceReviews pr ON e.emp_id = pr.emp_id
GROUP BY performance_band
ORDER BY attrition_pct DESC;

-- Q7: Rank employees by salary within department (window function)
SELECT
    department,
    emp_name,
    salary,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank
FROM Employees
WHERE status = 'Active'
ORDER BY department, salary_rank;

-- Q8: Employees with above-average performance rating but below-average salary (subquery)
SELECT
    e.emp_name,
    e.department,
    e.salary,
    pr.rating
FROM Employees e
JOIN PerformanceReviews pr ON e.emp_id = pr.emp_id
WHERE pr.rating > (SELECT AVG(rating) FROM PerformanceReviews)
  AND e.salary < (SELECT AVG(salary) FROM Employees)
ORDER BY pr.rating DESC;

-- Q9: CTE - Monthly exits trend (headcount lost per month)
WITH MonthlyExits AS (
    SELECT
        strftime('%Y-%m', exit_date) AS exit_month,
        COUNT(*) AS exits
    FROM Employees
    WHERE exit_date IS NOT NULL
    GROUP BY exit_month
)
SELECT * FROM MonthlyExits ORDER BY exit_month;

-- Q10: Employees who took more than 3 leave days AND have a rating below 3 (flight risk flag)
SELECT
    e.emp_name,
    e.department,
    COALESCE(SUM(l.days_taken), 0) AS total_leave_days,
    pr.rating
FROM Employees e
JOIN PerformanceReviews pr ON e.emp_id = pr.emp_id
LEFT JOIN Leaves l ON e.emp_id = l.emp_id
WHERE e.status = 'Active'
GROUP BY e.emp_id
HAVING total_leave_days > 3 OR pr.rating < 3
ORDER BY pr.rating ASC;
