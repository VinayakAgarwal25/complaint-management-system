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
--     time of its own department using a window function instead of
--     a correlated subquery. The average is computed once per
--     department using PARTITION BY.

SELECT c.complaint_id,
c.description,
c.date_resolved - c.date_registered AS own_resolution_days,
ROUND(
AVG(c.date_resolved - c.date_registered)
OVER (PARTITION BY c.department_id), 2
) AS dept_avg_resolution_days
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

-- Q8. For each department, compute total complaints and High-priority
--     complaint count, along with percentage share and ranking based on
--     High-priority workload using a window function (RANK).

SELECT d.department_name,
COUNT(c.complaint_id)                                        AS total_complaints,
SUM(CASE WHEN c.priority = 'High' THEN 1 ELSE 0 END)        AS high_priority_count,
ROUND(
SUM(CASE WHEN c.priority = 'High' THEN 1 ELSE 0 END) * 100.0
/ NULLIF(COUNT(c.complaint_id), 0), 2
)                                                            AS high_pct_within_dept,
RANK() OVER (
ORDER BY SUM(CASE WHEN c.priority = 'High' THEN 1 ELSE 0 END) DESC
)                                                            AS high_priority_rank
FROM department d
LEFT JOIN complaint c ON d.department_id = c.department_id
GROUP BY d.department_name
ORDER BY high_priority_rank;


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

-- Q17. Identify complaint volume trends by month and rank months based
--      on total complaints. Uses time-based aggregation and window
--      ranking to detect peak periods.

SELECT TO_CHAR(c.date_registered, 'YYYY-MM') AS complaint_month,
COUNT(*)                               AS total_complaints,
RANK() OVER (
ORDER BY COUNT(*) DESC
)                                       AS month_rank
FROM complaint c
GROUP BY TO_CHAR(c.date_registered, 'YYYY-MM')
ORDER BY month_rank;


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

-- Q20. Staff members who have resolved more complaints than the system-
--      wide average. Uses aggregation combined with a window function
--      (AVG OVER) instead of nested subqueries.

SELECT s.staff_id,
s.name,
COUNT(c.complaint_id) AS resolved_count,
ROUND(
AVG(COUNT(c.complaint_id)) OVER (), 2
)                     AS avg_resolved_per_staff
FROM staff s
JOIN complaint_assignment a ON s.staff_id = a.staff_id
JOIN complaint c ON a.complaint_id = c.complaint_id
WHERE c.status = 'Resolved'
GROUP BY s.staff_id, s.name
HAVING COUNT(c.complaint_id) >
AVG(COUNT(c.complaint_id)) OVER ()
ORDER BY resolved_count DESC;


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
JOIN users       u ON c.user_id         = u.user_id
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
