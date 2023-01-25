use sakila;
-- 1.How many copies of the film Hunchback Impossible exist in the inventory system?
select film_id, title from film
where title = "HUNCHBACK IMPOSSIBLE"; -- 439
select film_id, count(film_id) as number_of_copies from inventory
where film_id = 439;

-- The solution with joins
select f.title, i.film_id, count(i.film_id) as number_of_copies from inventory as i
join film as f on i.film_id = f.film_id
where i.film_id = 439;

-- 2.List all films whose length is longer than the average of all the films.
select film_id, title, length from film
where length > (select avg(length) from film)
order by length desc;

-- 3.Use subqueries to display all actors who appear in the film Alone Trip.
select * from actor;
select * from film;

select actor_id, first_name, last_name from actor
where actor_id in (select actor_id from film_actor
					where film_id = (select film_id from film
                    where title = 'ALONE TRIP'));

/*4.Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films.*/
select * from film;
select * from film_category;
select * from category;

select film_id from film_category
where category_id = 8;
select category_id from category
where name = 'Family';
-- Final result:
select film_id, title from film
where film_id in (select film_id from film_category
				where category_id = (select category_id from category
									where name = 'Family'));
                                    
/*5.Get name and email from customers from Canada using subqueries. Do the same with joins. 
Note that to create a join, you will have to identify the correct tables with their primary keys
and foreign keys, that will help you get the relevant information.*/
select * from customer; -- customer_id, first_name, last_name, email, address_id
select * from address; -- address_id, city_id
select * from city; -- city_id, city, country_id
select * from country; -- country_id, country

-- Result using subqueries
select first_name, last_name, email from customer
where address_id in (select address_id from address
					where city_id in (select city_id from city
									where country_id = (select country_id from country
														where country = 'Canada')));

-- Result using joins:
select cu.first_name, cu.last_name, cu.email, c.country from customer as cu
join address as a on cu.address_id = a.address_id
join city as ci on a.city_id = ci.city_id
join country as c on ci.country_id = c.country_id
where c.country = 'Canada'; 					

/*6.Which are films starred by the most prolific actor? Most prolific actor is defined as
the actor that has acted in the most number of films. First you will have to find 
the most prolific actor and then use that actor_id to find the different films that he/she starred.*/

select * from film; -- film_id, title
select * from film_actor; -- actor_id, film_id
select * from actor; -- actor_id, first_name, last_name
-- To check who is the most prolific actor
select actor_id, count(actor_id) as total_films from film_actor
group by actor_id
order by total_films desc limit 1;

-- The final query:
select a.first_name, a.last_name, f.title from film as f
join film_actor as fa on f.film_id = fa.film_id
join actor as a on fa.actor_id = a.actor_id
where fa.actor_id = (select actor_id from film_actor
                     group by actor_id
                     order by count(actor_id) desc limit 1);


/*7.Films rented by most profitable customer. You can use the customer table
and payment table to find the most profitable customer ie the customer that 
has made the largest sum of payments*/
select * from film; -- film_id, title
select * from inventory; -- inventory_id, film_id
select * from rental; -- customer_id, inventory_id
select * from customer; -- customer_id, first_name, last_name
select * from payment; -- customer_id, amount

select customer_id, sum(amount) as total_profit from payment
group by customer_id
order by total_profit desc limit 1;

select f.title, c.first_name, c.last_name, p.total_profit from film as f
join inventory as i on f.film_id = i.film_id
join rental as r on i.inventory_id = r.inventory_id
join customer as c on r.customer_id = c.customer_id
join (select customer_id, sum(amount) as total_profit from payment
	  group by customer_id
	  order by total_profit desc limit 1) as p on c.customer_id = p.customer_id;

-- 8.Customers who spent more than the average payments.
select * from customer; -- customer_id, first_name, last_name
select * from payment; -- customer_id, amount

select c.customer_id, c.first_name, c.last_name, sum(p.amount) as total_spent
from customer as c join payment as p on c.customer_id = p.customer_id
group by customer_id
having total_spent > (select avg(amount) from payment)
order by total_spent desc;
