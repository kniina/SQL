SET SQL_SAFE_UPDATES = 0;
USE sakila;

-- 1A - Display first and last name of all actors from Actor table
SELECT first_name, last_name FROM actor;

-- 1B - Add first and last names to 'Actor Name' column of Actor table
UPDATE actor 
	SET actor_name = CONCAT(first_name, '  ', last_name); 

-- 1B - Display first and last name of each actor in column 'Actor Name'
SELECT actor_name FROM actor;

-- 2A - Display ID Number, first and last name of an actor using first name
SELECT actor_id, first_name, last_name FROM actor
	WHERE first_name = 'Joe';
    
-- 2B - Find actors whose last name contains the letters 'GEN'
SELECT actor_id, first_name, last_name FROM actor
	WHERE last_name LIKE '%GEN%'; 
    
-- 2C - Find actors whose last name contain letters 'LI' - Order rows by last name and first name
SELECT last_name, first_name FROM actor
	WHERE last_name LIKE '%LI%';
    
-- 2D - Using `IN`, display the `country_id` and `country` columns of Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
	WHERE country IN ('Afghanistan', 'Bangladesh', 'China');
    
-- 3A - Create column in Actor Table named 'Description' and use data type BLOB
ALTER TABLE actor
	ADD COLUMN Description BLOB;

-- 3B - Delete the description column
ALTER TABLE actor
	DROP COLUMN Description; 

-- 4A - List the last names of actors, and how many actors have that last name
SELECT last_name, COUNT(last_name) FROM actor
    GROUP BY last_name;
    
-- 4B - List last names of actors and number of actors with same last name, but only for names shared by at least 2 actors
SELECT last_name, COUNT(last_name) FROM actor
    GROUP BY last_name
    HAVING COUNT(last_name) >= 2;  

-- 4C - Fix record from "Groucho Williams' to 'Harpo Williams'
UPDATE actor 
	SET first_name = 'HARPO'
	WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS'; 

-- 4D - In a single query, change first name of actor from 'Harpo' to 'Groucho'
UPDATE actor
	SET first_name = 'GROUCHO'
	WHERE first_name = 'HARPO'; 

-- 5A - Recreate schema of 'Address' Table
DESCRIBE address;
-- OR
SHOW CREATE TABLE address;

-- 6A - Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`
SELECT s.first_name, s.last_name, a.address FROM staff s
	JOIN address a
	ON s.address_id = a.address_id; 
    
-- 6B - Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`
SELECT s.first_name, s.last_name, SUM(p.amount) AS 'Total Amount'
FROM staff s 
	JOIN payment p 
	ON s.staff_id = p.staff_id
    WHERE p.payment_date >= '2005-08-01 00:00:00' AND p.payment_date <= '2005-08-31 23:59:59'
    GROUP BY s.first_name, s.last_name;

-- 6C - List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT f.title, COUNT(a.actor_id) AS 'Total Actors'
FROM film f
	INNER JOIN film_actor a
    ON f.film_id = a.film_id
    GROUP BY f.title;
    
-- 6D - How many copies of the film `Hunchback Impossible` exist in the inventory system? 6 Copies
SELECT f.title, COUNT(i.film_id) AS 'Total Copies'
FROM film f
	JOIN inventory i
    ON f.film_id = i.film_id
    WHERE f.title = 'Hunchback Impossible'
    GROUP BY f.title;
 
-- 6E - Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount) AS 'Total Amount Paid'
FROM customer c
	JOIN payment p 
	ON c.customer_id = p.customer_id
    GROUP BY c.first_name, c.last_name
    ORDER BY c.last_name;

-- 7A - Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 
SELECT title, language_id FROM film
WHERE SUBSTR(title, 1, 1) = 'K' OR SUBSTR(title, 1, 1) = 'Q' AND language_id IN 
(
	SELECT language_id FROM language
    WHERE name IN
	(
		SELECT name FROM language
        WHERE name = 'English'
    )
);

-- 7B - Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name FROM actor
WHERE actor_id IN
(
	SELECT actor_id FROM film_actor
	WHERE film_id IN
	(	
		SELECT film_id FROM film
		WHERE title = 'Alone Trip'
	)
);

-- 7C - You will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT c.first_name, c.last_name, c.email FROM customer c
	INNER JOIN address a
    ON c.address_id = a.address_id
    INNER JOIN city ct
    ON a.city_id = ct.city_id
    INNER JOIN country ctr
    ON ct.country_id = ctr.country_id
    WHERE country = 'Canada';
    
-- 7D - Identify all movies categorized as family films.
SELECT f.title FROM film f
	INNER JOIN film_category fc
    ON f.film_id = fc.film_id
    INNER JOIN category c
    ON fc.category_id = c.category_id
    WHERE c.name = 'Family';

-- 7E - Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(f.title) AS 'Number of Times Rented' FROM film f
	INNER JOIN inventory i
    ON f.film_id = i.film_id
    INNER JOIN rental r
    ON i.inventory_id = r.inventory_id
    GROUP BY f.title
    ORDER BY COUNT(f.title) DESC;

-- 7F - Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) AS 'Total Revenue' FROM staff s 
	INNER JOIN payment p
	ON s.staff_id = p.staff_id
	GROUP BY s.store_id;
    
-- 7G - Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, ct.city, ctr.country FROM store s
	INNER JOIN address a
    ON s.address_id = a.address_id
    INNER JOIN city ct
    ON a.city_id = ct.city_id
    INNER JOIN country ctr
    ON ct.country_id = ctr.country_id;
    
-- 7H - List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name, SUM(p.amount) AS 'Gross Revenue' FROM category c
	INNER JOIN film_category fc
    ON c.category_id = fc.category_id
    INNER JOIN inventory i
    ON fc.film_id = i.film_id
    INNER JOIN rental r
    ON i.inventory_id = r.inventory_id
    INNER JOIN payment p
    ON r.rental_id = p.rental_id
    GROUP BY c.name
    ORDER BY 'Gross Revenue' DESC
    LIMIT 5; 
   
-- 8A - Top five genres by gross revenue. Use the solution from the problem above to create a view.
CREATE VIEW top_five_genres_by_revenue AS
	SELECT c.name, SUM(p.amount) AS 'Gross Revenue' FROM category c
		INNER JOIN film_category fc
		ON c.category_id = fc.category_id
		INNER JOIN inventory i
		ON fc.film_id = i.film_id
		INNER JOIN rental r
		ON i.inventory_id = r.inventory_id
		INNER JOIN payment p
		ON r.rental_id = p.rental_id
		GROUP BY c.name
		ORDER BY 'Gross Revenue' DESC
		LIMIT 5; 	

-- 8B - How would you display the view that you created in 8a?
SELECT*FROM top_five_genres_by_revenue;

-- 8C - You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres_by_revenue;


