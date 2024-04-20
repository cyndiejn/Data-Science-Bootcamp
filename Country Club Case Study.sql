/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name, membercost 
FROM `Facilities`
WHERE membercost <> 0

-- Tennis Court 1 is 5.0, Tennis Court 2 is 5.0, Massage Room 1 is 9.9, Massage Room 2 is 9.9, Squash Room is 3.5

/* Q2: How many facilities do not charge a fee to members? */
-- Question 2 --
SELECT COUNT(membercost)
FROM Facilities
WHERE membercost = 0;
	-- 4 Facilities do not charge a fee to members --

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid,name,membercost, monthlymaintenance 
FROM `Facilities`
WHERE membercost <> 0
AND membercost < .2 * monthlymaintenance

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM `Facilities`
WHERE facid = 1 OR facid = 5 

SELECT *
FROM `Facilities`
WHERE facid IN (1,5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance, IF(monthlymaintenance > 100, "Expensive", "Cheap") AS cost
FROM Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE joindate IN (SELECT MAX(joindate) FROM Members)

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT name, CONCAT_WS(' ', firstname,surname) AS fullname
FROM Bookings as b
INNER JOIN Members as m
ON m.memid = b.memid
INNER JOIN Facilities as f
ON f.facid = b.facid
WHERE b.facid IN (0,1)
ORDER BY full_name

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT name, CONCAT_WS(' ', firstname,surname) , membercost, guestcost
FROM Bookings as b
INNER JOIN Members as m
ON m.memid = b.memid
INNER JOIN Facilities as f
ON f.facid = b.facid
WHERE starttime LIKE '2012-09-14%'
AND ((m.memid = 0 AND guestcost >30) OR (m.memid<>0 AND membercost > 30) )
ORDER BY membercost, guestcost


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT name, CONCAT_WS(' ', firstname,surname) , membercost, guestcost
FROM Bookings as b
INNER JOIN Members as m
ON m.memid = b.memid
INNER JOIN Facilities as f
ON f.facid = b.facid
WHERE m.memid IN (SELECT memid
                FROM Members
                WHERE (memid = 0 AND guestcost > 30)
                OR (memid <> 0 AND membercost > 30))
AND starttime LIKE '2012-09-14%'
ORDER BY membercost, guestcost

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

-- python code:

query10 = pd.read_sql('SELECT name, initialoutlay + (COUNT(memid = 0) * guestcost) + (COUNT(memid<> 0) * membercost) AS revenue FROM Facilities INNER JOIN Members ON facid GROUP BY facid ORDER BY revenue DESC', conn)
query10

-- sql code: 

SELECT *, initialoutlay + (COUNT(memid = 0) * guestcost) + (COUNT(memid<> 0) * membercost) AS revenue
FROM Facilities
INNER JOIN Members
ON facid
GROUP BY facid
ORDER BY revenue DESC

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

-- python code:

query11 = pd.read_sql("SELECT CONCAT_WS(' ', m1.firstname, m1.surname), CONCAT_WS(' ', m2.firstname, m2.surname) AS recommended_by FROM Members AS m1 INNER JOIN Members AS m2 ON m1.memid = m2.recommendedby", conn)
query11

-- sql code:

SELECT CONCAT_WS(' ', m1.firstname, m1.surname), CONCAT_WS(' ', m2.firstname, m2.surname) AS recommended_by
FROM Members AS m1
INNER JOIN Members AS m2
ON m1.recommendedby = m2.memid
WHERE m1.recommendedby <> 0
ORDER BY m2.surname, m2.firstname

/* Q12: Find the facilities with their usage by member, but not guests */

-- python code:

query12 =pd.read_sql("SELECT name, COUNT(memid <> 0) AS member_usage FROM Facilities AS f INNER JOIN Bookings AS b ON f.facid = b.facid GROUP BY f.facid", conn)
query12

-- sql code:

SELECT name, COUNT(memid <> 0) AS member_usage
FROM Facilities AS f
INNER JOIN Bookings AS b
ON f.facid = b.facid
GROUP BY f.facid

/* Q13: Find the facilities usage by month, but not guests */

-- python code:

query13 = pd.read_sql("SELECT name, COUNT(memid <> 0) AS member_usage, MONTH(starttime) AS month FROM Facilities AS f INNER JOIN Bookings AS b ON f.facid = b.facid GROUP BY f.facid, MONTH(starttime)", conn)
query13

-- sql code:

SELECT name, COUNT(memid <> 0) AS member_usage, MONTH(starttime) AS month
FROM Facilities AS f
INNER JOIN Bookings AS b
ON f.facid = b.facid
GROUP BY f.facid, MONTH(starttime)