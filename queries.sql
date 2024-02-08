
--student wants to borrow Lalka and mistrz i malgorzata
--Show copies of Lalka and check if they are available and check if they are lost
SELECT Books.Title, CONCAT(Authors.Name, ' ', Authors.Surname) AS Author, Copies.Number AS copy_number, Copies.Is_lend, isnull(Copies.Condition,'none') AS Condition, Book_events.Deadline, isnull(Book_events.Is_lost, '0') AS Is_lost
FROM Books
	INNER JOIN Who_edited
	ON Books.Book_id = Who_edited.Book_id 
	INNER JOIN Authors
	ON Who_edited.Author_id = Authors.Author_id
	INNER JOIN Copies
	ON Books.Book_id = Copies.Book_id
	LEFT JOIN Book_events
	ON Copies.Copy_id = Book_events.Copy_id
WHERE Books.Title IN ('Lalka', 'Mistrz i Malgorzata') --show only lalka because thats the book that student wants to borrow 
ORDER BY Is_lost, Deadline



--Show total fines per class in highschools

SELECT  Students.Class, SUM(Fines.Fine_in_total) AS Fine_per_class
FROM Fines
	RIGHT JOIN Book_events
	ON Fines.Event_id = Book_events.Event_id 
	JOIN Cards
	ON Book_events.Card_id = Cards.Card_id
	JOIN (SELECT Students_id, CONCAT(Students.Year,Students.Grade) AS Class--to group by class i create Class column 
		  FROM Students) Students
	ON Cards.Students_id = Students.Students_id
GROUP BY Students.Class
ORDER BY Fine_per_class DESC





--show top 5 readers of our library in 2024
SELECT TOP 5  
Students.Name, Students.Surname, COUNT(Book_events.Card_id) AS Borrow_counter
FROM Book_events 
	JOIN Cards 
	ON Book_events.Card_id = Cards.Card_id
	JOIN Students
	ON Cards.Students_id = Students.Students_id
WHERE Book_events.When_lend BETWEEN CONVERT(DATE, '2024.01.01') AND CONVERT(DATE, '2024.12.31')
GROUP BY Book_events.Card_id, Students.Name, Students.Surname
ORDER BY Borrow_Counter DESC



--show how many times books been destroyed
 
SELECT  Authors.Editor_Name, Authors.Editor_Surname, Books.Title, Copies.Number AS copy_number, Book_events.Destroy_counter
FROM Copies
	JOIN 
		(SELECT Copy_id, COUNT(Book_events.Copy_id) AS Destroy_counter 
		 FROM Book_events 
		 WHERE Book_events.Is_destroyed = '1'
		 GROUP BY Book_events.Copy_id) Book_events
	ON Copies.Copy_id = Book_events.Copy_id 
	JOIN Books
	ON Copies.Book_id = Books.Book_id
	JOIN Who_edited
	ON Books.Book_id = Who_edited.Book_id
	JOIN 
		(SELECT Author_id, Name AS Editor_Name, Surname AS Editor_Surname
		FROM Authors
		WHERE Author_id IN 
			(SELECT Author_id 
			FROM Who_edited)) Authors
	ON Who_edited.Author_id = Authors.Author_id
ORDER BY Book_events.Destroy_counter DESC






-- show books that are not returned and who borrowed them

DROP VIEW Lend_Books
Go

CREATE VIEW Lend_Books (Name, Surname, Card_number, Book, Copy_number, Author, Deadline, Class)
	AS SELECT Students.Name, Students.Surname, Cards.Card_id, Books.Title, Copies.Number, CONCAT(Authors.Name, ' ', Authors.Surname) AS Author, Book_events.Deadline, concat(Students.Year, Students.Grade) AS Class
	FROM Students, Cards, Books, Copies, Authors, Who_edited, Book_events
	WHERE Students.Students_id = Cards.Students_id 
	AND Cards.Card_id = Book_events.Card_id
	AND Book_events.Copy_id = Copies.Copy_id
	AND Copies.Book_id = Books.Book_id
	AND Books.Book_id = Who_edited.Book_id
	AND  Who_edited.Author_id = Authors.Author_id
	AND Book_events.When_returned IS NULL
	
	GO

SELECT * 
FROM Lend_Books
ORDER BY Deadline DESC



--create view with the whole history of all books borrowed and their fines


DROP VIEW Fines_history
GO


CREATE VIEW Fines_history (Name, Surname, Card_number, Book, Copy_number, Author, When_lend, When_returned, Is_prolong, 
                               Lost_fine, Destroyed_fine, Overdue_fine, Days_of_overdue, Fine_total, Is_paid)
	AS SELECT Students.Name, Students.Surname, Cards.Card_id, Books.Title, Copies.Number, CONCAT(Authors.Name, ' ', Authors.Surname) AS Author, 
			Book_events.When_lend, Book_events.When_returned, Book_events.Is_prolong, Fines.Fine_when_lost, Fines.Fine_when_destroyed, 
			Fines.Fine_per_day_of_overdue,  (SELECT DATEDIFF(day, Book_events.Deadline, Book_events.When_returned) AS Days_of_overdue FROM Book_events WHERE Book_events.Is_overdue = '1' AND Book_events.Event_id = Fines.Event_id), 
			Fines.Fine_in_total, Book_events.Is_prolong
	FROM Students, Cards, Books, Copies, Authors, Who_edited, Book_events, Fines
	WHERE Students.Students_id = Cards.Students_id 
	AND Cards.Card_id = Book_events.Card_id
	AND Book_events.Copy_id = Copies.Copy_id
	AND Copies.Book_id = Books.Book_id
	AND Books.Book_id = Who_edited.Book_id
	AND Who_edited.Author_id = Authors.Author_id
	AND Book_events.Event_id = Fines.Event_id

GO


-- to show fines that has not been paid

SELECT * FROM Fines_history WHERE Is_paid = 0

-- show fines of particular person

SELECT * FROM Fines_history WHERE Surname = 'Nowak'




--Show all the most important data concerning borrowings and possible fines regarding it
--it is useful for students to check their history of borrowing and chech if they have something to return or pay
SELECT Students.Name, Students.Surname, Cards.Card_id, Books.Title, Copies.Number, CONCAT(Authors.Name, ' ', Authors.Surname) AS Author, 
			Book_events.When_lend, Book_events.Deadline, Book_events.When_returned, Book_events.Is_prolong, Fines.Fine_when_lost, Fines.Fine_when_destroyed, 
			Fines.Fine_per_day_of_overdue, isnull(Days_of_overdue, 0) AS Days_of_overdue,
		   -- (SELECT DATEDIFF(day, Book_events.Deadline, Book_events.When_returned) FROM Book_events WHERE Book_events.Is_overdue = '1' AND Book_events.Card_id = Cards.Card_id) AS Days_of_overdue, 
			Fine_in_total, Book_events.Is_prolong
	FROM Students
	JOIN Cards
	ON Students.Students_id = Cards.Card_id
	JOIN (SELECT Event_id, Copy_id, Card_id, When_lend, Deadline, When_returned, Is_prolong,
				DATEDIFF(day, Book_events.Deadline, Book_events.When_returned) AS Days_of_overdue
		  FROM Book_events 
		  WHERE Book_events.Is_overdue = '1') Book_events
	ON Cards.Card_id = Book_events.Card_id
	JOIN Copies
	ON Book_events.Copy_id = Copies.Copy_id
	JOIN Books
	ON Copies.Book_id = Books.Book_id
	JOIN Who_edited
	ON Books.Book_id = Who_edited.Book_id
	JOIN Authors
	ON Who_edited.Author_id = Authors.Author_id
	LEFT JOIN Fines
	ON Book_events.Event_id = Fines.Event_id
WHERE Students.Surname = 'Nowak' AND Students.Name = 'Jan' 
ORDER BY Deadline DESC




--wyszukaj utwory kochanowskiego i sprawdz w jakich ksiazkach sa (pogrupuj ksiazkami)
SELECT Writings.Title, Writing_Author, Books.Title, Editor.Editor_Name, Editor.Editor_Surname
FROM Writings
	JOIN Written_by
	ON Writings.Writing_id = Written_by.Writing_id
	JOIN (SELECT Author_id, Concat(Name, ' ' ,Surname) AS Writing_Author
		FROM Authors
		WHERE Author_id IN 
			(SELECT Author_id 
			FROM Written_by)) Authors
	ON Written_by.Author_id = Authors.Author_id
	JOIN Contain
	ON Writings.Writing_id = Contain.Writing_id
	JOIN Books
	ON Contain.Book_id = Books.Book_id
	JOIN Who_edited
	ON Books.Book_id = Who_edited.Book_id
	JOIN (SELECT Author_id, Name AS Editor_Name, Surname AS Editor_Surname
		FROM Authors
		WHERE Author_id IN 
			(SELECT Author_id 
			FROM Who_edited)
		UNION
		SELECT Author_id, Name AS Editor_Name, Surname AS Editor_Surname
		FROM Authors
		WHERE Author_id IN 
			(SELECT Author_id 
			FROM Who_edited)) Editor
	ON Who_edited.Author_id = Editor.Author_id
WHERE Writing_Author LIKE ('%Koc%')


