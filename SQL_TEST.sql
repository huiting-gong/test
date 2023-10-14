-- 1) Write a SQL query to retrieve the top 10 most borrowed books, along with the number of times each book has been borrowed.

select top 10 bb.book_id, bo.title as book_name, count(bb.borrow_id) as Times_to_borrow
from borrowed_books bb
left join books bo on bo.book_id = bb.book_id
group by bb.book_id, bo.title
order by count(bb.borrow_id) desc;

-- 2) Create a stored procedure that calculates the average number of days a book is borrowed before being returned. The procedure should take a book_id as input and return the average number of days.

create procedure average_num_days @book_id int 
as
declare @avg_no_day number
select book_id, count(borrow_id) as borrow_times, sum(return_date - borrow_date) as total_day
into #temp_borrow_tables
from borrowed_books
group by book_id;

select book_id, @avg_no_day = total_day/borrow_times
from #temp_borrow_tables;

end
return isnull(@avg_no_day, 0)

-- 3) Write a query to find the user who has borrowed the most books from the library.

select ub.user_id as user_borrow_most, max(ub.borrow_times) as max_times_borrow
from (
select user_id, count(borrow_id) as borrow_times
from borrowed_books 
group by user_id
) ub
group by ub.user_id

-- 4) Create an index on the publication_year column of the books table to improve query performance.

create clustered index ix_book_publication_yrs
on books(publication_year asc)


-- 5) Write a SQL query to find all books published in the year 2020 that have not been borrowed by any user.

select *
from books
where publication_year='2020'
and book_id not in (select book_id from borrowed_books)

-- 6) Design a SQL query that lists users who have borrowed books published by a specific author (e.g., "J.K. Rowling")

create procedure users_books_spec_author @author varchar(100)
as 
declare @users_list varchar(100)
select bb.book_id, @users_list = bb.user_id
from borrowed_books bb
inner join 
(select book_id
from books bs
where author = @author ) bs on bb.book_id = bs.book_id 
end
return @users_list


-- 7) Create a trigger that automatically updates the return_date in the borrowed_books table to the current date when a book is returned.
create trigger trg_update_date
on borrowed_books
after update
as 
  update borrowed_books
  set return_date = getdate()
  where borrow_id in (select distinct borrow_id from borrowed_books)
ends





1989 book a       19
2009 book a       10

9900 book b        5
9909 book b        6
9888 book b        3

book a     19/2
book b     14/3
