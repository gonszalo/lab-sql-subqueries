use sakila;
-- How many copies of the film Hunchback Impossible exist in the inventory system?
select f.title as Film, count(i.inventory_id) as 'Inventory Count'
	from film as f
	join inventory as i
	on f.film_id = i.film_id
	where f.title = 'Hunchback Impossible'
	group by f.film_id;

-- List all films whose length is longer than the average of all the films.

SELECT title,
       length,
       categoryName
FROM ( SELECT CASE
                  WHEN film_category.category_id = @currentCategory THEN
                      @currentRecord := @currentRecord + 1
                  ELSE
                      @currentRecord := 1 AND
                      @currentCategory := film_category.category_id
              END AS recordNumber,
              film.title AS title,
              film.length AS length,
              categoryName AS categoryName
       FROM film
       JOIN film_category ON film.film_id = film_category.film_id
       JOIN ( SELECT film_category.category_id AS category_id,
                     category.name AS categoryName,
                     AVG( film.length ) AS categoryAvgLength
              FROM film
              JOIN film_category ON film.film_id = film_category.film_id
              JOIN category ON category.category_id = film_category.category_id
              GROUP BY film_category.category_id,
                       category.name
            ) AS categoryAvgLengthFinder ON film_category.category_id = categoryAvgLengthFinder.category_id,
            (
                SELECT @currentCategory := 0 AS currentCategory
            ) AS currentValuesInitialiser
       WHERE film.length > categoryAvgLength
       ORDER BY film_category.category_id,
                film.length
     ) AS allLarger;
     
    -- Use subqueries to display all actors who appear in the film Alone Trip. 
     
SELECT last_name, first_name
FROM actor
WHERE actor_id in
	(SELECT actor_id FROM film_actor
	WHERE film_id in 
		(SELECT film_id FROM film
		WHERE title = "Alone Trip"));
  
  -- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title, category
FROM film_list
WHERE category = 'Family';

 

-- Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
SELECT country, last_name, first_name, email
FROM country c
LEFT JOIN customer cu
ON c.country_id = cu.customer_id
WHERE country = 'Canada';

-- Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

select actor.actor_id, actor.first_name, actor.last_name,
       count(actor_id) as film_count
from actor join film_actor using (actor_id)
group by actor_id
order by film_count desc
limit 1;

-- Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

SELECT
film.title, 
a.rental_count*film.rental_rate AS gross_revenue
FROM film
INNER JOIN
(SELECT
COUNT(film.title) AS rental_count,
film.title
FROM payment
LEFT JOIN rental ON (payment.rental_id=rental.rental_id)
LEFT JOIN inventory ON (rental.inventory_id=inventory.inventory_id)
LEFT JOIN film ON (inventory.film_id=film.film_id)
GROUP BY film.title
ORDER BY rental_count DESC) AS a ON (film.title=a.title)
ORDER BY gross_revenue DESC;

SELECT
film.title,
SUM(amount) AS gross_revenue
FROM payment
LEFT JOIN rental ON (payment.rental_id=rental.rental_id)
LEFT JOIN inventory ON (rental.inventory_id=inventory.inventory_id)
LEFT JOIN film ON (inventory.film_id=film.film_id)
GROUP BY film.title
ORDER BY gross_revenue DESC;





