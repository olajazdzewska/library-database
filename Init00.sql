DROP TABLE IF EXISTS Contain,  Fines,   What_kinds, Who_edited,  Written_by,  Book_events, Cards, Students, Writings, Copies, Books,  Publishers, Authors, Genres 


IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'Authors' AND xtype = 'U')
CREATE TABLE Authors 
(Author_id INT IDENTITY(0,1) PRIMARY KEY NOT NULL,
Name VARCHAR(100),
Surname VARCHAR(200)
);

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'Publishers' AND xtype = 'U')
CREATE TABLE Publishers 
(Publisher_id INT IDENTITY(0,1) PRIMARY KEY NOT NULL,
Release_date DATE,
Realese_number INT CHECK(Realese_number>0),
Publisher_name VARCHAR(200)
);

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'Books' AND xtype = 'U')
CREATE TABLE Books
(Book_id INT IDENTITY(0,1) PRIMARY KEY NOT NULL,
Title VARCHAR(200) UNIQUE, -- it is unique to show update on cascade
Is_set_text BIT DEFAULT '0' NOT NULL,
Publisher_id INT REFERENCES dbo.Publishers ON DELETE CASCADE ON UPDATE CASCADE
);

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'Copies' AND xtype = 'U')
CREATE TABLE Copies
(Copy_id INT IDENTITY(0,1) PRIMARY KEY NOT NULL,
Is_lend BIT DEFAULT '0' NOT NULL,
Condition VARCHAR(500),
Number INT NOT NULL CHECK(Number > 0),
Book_id INT REFERENCES dbo.Books ON DELETE CASCADE NOT NULL,
Title VARCHAR(200) REFERENCES dbo.Books(Title) ON UPDATE CASCADE --it is added here to show update on cascade
);


IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'Students' AND xtype = 'U')
CREATE TABLE Students
(Students_id INT IDENTITY(0,1) PRIMARY KEY NOT NULL,
Name VARCHAR(30) NOT NULL,
Surname VARCHAR(30) NOT NULL,
Grade VARCHAR(1) CHECK (Grade IN('a', 'b', 'c', 'd', 'e', 'f')),
Year INT CHECK(Year>0),
Is_teacher BIT DEFAULT '0' NOT NULL,
When_added DATE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'Cards' AND xtype = 'U')
CREATE TABLE Cards 
(Card_id INT IDENTITY(0,1) PRIMARY KEY NOT NULL,
Is_blocked BIT DEFAULT '0' NOT NULL,
Is_available BIT DEFAULT '1' NOT NULL,
Students_id INT REFERENCES dbo.Students ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'Book_events' AND xtype = 'U')
CREATE TABLE Book_events
(Event_id INT IDENTITY(0,1) PRIMARY KEY NOT NULL,
When_lend DATE DEFAULT CURRENT_TIMESTAMP NOT NULL,
Deadline DATE DEFAULT CURRENT_TIMESTAMP + 30,
Is_prolong BIT DEFAULT '0' NOT NULL,
Is_overdue BIT DEFAULT '0' NOT NULL,
When_returned DATE,
Is_lost BIT DEFAULT '0' NOT NULL,
Is_destroyed BIT DEFAULT '0' NOT NULL,
Copy_id INT REFERENCES dbo.Copies ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
Card_id INT REFERENCES dbo.Cards ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,

);



IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'Writings' AND xtype = 'U')
CREATE TABLE Writings
(Writing_id INT IDENTITY(0,1) PRIMARY KEY NOT NULL,
Title CHAR(200) NOT NULL
);

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'Written_by' AND xtype = 'U')
CREATE TABLE Written_by
(Writing_id INT REFERENCES dbo.Writings ON DELETE CASCADE ON UPDATE CASCADE,
Author_id INT REFERENCES dbo.Authors ON DELETE CASCADE ON UPDATE CASCADE,
PRIMARY KEY (Writing_id, Author_id)
);

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'Fines' AND xtype = 'U')
CREATE TABLE Fines
( Fine_key INT IDENTITY(0,1) PRIMARY KEY NOT NULL,
Fine_when_lost DECIMAL(5,2) DEFAULT '0' NOT NULL CHECK(Fine_when_lost>=0),
Fine_when_destroyed DECIMAL(5,2) DEFAULT '0' NOT NULL CHECK(Fine_when_destroyed>=0),
Is_paid BIT DEFAULT '0' NOT NULL,
Deadline DATE NOT NULL,
Fine_in_total DECIMAL(5,2) DEFAULT '0' NOT NULL CHECK(Fine_in_total>=0),
Fine_per_day_of_overdue DECIMAL(5,2) DEFAULT '0' NOT NULL CHECK(Fine_per_day_of_overdue>=0),
Event_id INT REFERENCES dbo.Book_events ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'Genres' AND xtype = 'U')
CREATE TABLE Genres
(Genre_id INT IDENTITY(0,1) PRIMARY KEY NOT NULL,
Name VARCHAR(30) NOT NULL
);

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'What_kinds' AND xtype = 'U')
CREATE TABLE What_kinds
(Book_id INT  REFERENCES dbo.Books ON DELETE CASCADE,
Genre_id INT  REFERENCES dbo.Genres ON DELETE CASCADE,
PRIMARY KEY(Book_id, Genre_id)
);

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'Who_edited' AND xtype = 'U')
CREATE TABLE Who_edited
(Book_id INT  REFERENCES Books ON DELETE CASCADE ON UPDATE CASCADE,
Author_id INT  REFERENCES Authors ON DELETE CASCADE ON UPDATE CASCADE,
PRIMARY KEY(Book_id, Author_id)
);

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'Contain' AND xtype = 'U')
CREATE TABLE Contain
(Writing_id INT  REFERENCES dbo.Writings ON DELETE CASCADE ON UPDATE CASCADE,
Book_id INT REFERENCES dbo.Books ON DELETE CASCADE ON UPDATE CASCADE,
PRIMARY KEY(Writing_id, Book_id)
);



DROP TRIGGER IF EXISTS trg_TotalFines, trg_InsertFines, trg_UpdateDeadline, trg_catchUpdate



SET NOCOUNT ON;
GO 

CREATE TRIGGER trg_UpdateDeadline ON Book_events
	AFTER UPDATE
AS
BEGIN

	DECLARE @Event_id INT
	DECLARE @Deadline DATE

	SELECT @Event_id = INSERTED.Event_id FROM INSERTED
	SELECT @Deadline = INSERTED.Deadline FROM INSERTED

	IF UPDATE(Is_prolong)
		SET @Deadline = DATEADD(DAY, 14, @Deadline)

	UPDATE Book_events
	SET Deadline = @Deadline
	WHERE Event_id = @Event_id
END;


SET NOCOUNT ON
GO

CREATE TRIGGER trg_InsertFines ON Book_events
	AFTER UPDATE
AS 
BEGIN	
	DECLARE @Event_id INT
	DECLARE @Deadline DATE
	DECLARE @lost_fine FLOAT(5)
	DECLARE @overdue_fine FLOAT(5)
	DECLARE @destroyed_fine FLOAT(5)

	SELECT @Deadline = INSERTED.Deadline
	FROM INSERTED
	SELECT @Event_id = INSERTED.Event_id
	FROM INSERTED
	SELECT @lost_fine = 0.0
	SELECT @overdue_fine = 0.0
	SELECT @destroyed_fine = 0.0

	IF UPDATE(Is_overdue) 
		SET @overdue_fine = 10

	IF UPDATE(Is_lost)
		SET @lost_fine = 15

	IF UPDATE(Is_destroyed)
		SET @destroyed_fine = 20

	IF EXISTS (SELECT 1  FROM Fines WHERE Event_id = @Event_id)
	BEGIN 
		UPDATE Fines
		SET Fine_when_lost=@lost_fine, Fine_when_destroyed=@destroyed_fine, Deadline=@Deadline, Fine_per_day_of_overdue=@overdue_fine--, Fine_in_total=@overdue_fine+@lost_fine+@destroyed_fine
		WHERE Event_id = @Event_id;
	END 
	ELSE 
	BEGIN 
		INSERT INTO Fines(Event_id, Fine_when_lost, Fine_when_destroyed, Deadline, Fine_per_day_of_overdue)
		VALUES (@Event_id, @lost_fine, @destroyed_fine, @Deadline, @overdue_fine)  
	END

END;

SET NOCOUNT ON
GO

CREATE TRIGGER trg_TotalFines ON Book_events
	AFTER UPDATE
AS 
BEGIN
	DECLARE @Event_id INT
	DECLARE @Days FLOAT
	SELECT @Days = 0.0
	DECLARE @Deadline DATE
	DECLARE @When_returned DATE
	DECLARE @Fine_key INT

	SELECT @Event_id = INSERTED.Event_id FROM INSERTED
	SELECT @Deadline = INSERTED.Deadline FROM INSERTED
	SELECT @When_returned = INSERTED.When_returned FROM INSERTED
	SELECT @Fine_key = Fines.Fine_key FROM Fines WHERE Event_id = @Event_id

	IF UPDATE(When_returned) 
		SET @Days = DATEDIFF(day, @Deadline, @When_returned)

		UPDATE Fines
		SET Fine_in_total =  @Days* Fine_per_day_of_overdue + Fine_when_destroyed + Fine_when_lost
		WHERE Fine_key = @Fine_key
END; 

SET NOCOUNT ON
GO

CREATE TRIGGER trg_catchUpdate
	ON Fines
	AFTER UPDATE
AS
BEGIN
	DECLARE @overdue FLOAT
	DECLARE @lost FLOAT
	DECLARE @destroyed FLOAT
	DECLARE @total FLOAT
	DECLARE @key INT
	DECLARE @event_id INT
	DECLARE @when_returned DATE

	SELECT @overdue = DELETED.Fine_per_day_of_overdue FROM DELETED
	SELECT @lost = DELETED.Fine_when_lost FROM DELETED
	SELECT @destroyed = DELETED.Fine_when_destroyed FROM DELETED
	SELECT @total = DELETED.Fine_in_total FROM DELETED
	SELECT @key = DELETED.Fine_key FROM DELETED
	SELECT @event_id = DELETED.Event_id FROM DELETED
	SELECT @when_returned = Book_events.When_returned FROM Book_events WHERE Event_id = @event_id

	IF @when_returned IS NOT NULL AND (UPDATE(Fine_per_day_of_overdue) OR UPDATE(Fine_when_lost) OR UPDATE(Fine_when_destroyed))
		UPDATE Fines
		SET Fine_per_day_of_overdue=@overdue, Fine_when_lost=@lost, Fine_when_destroyed=@destroyed, Fine_in_total=@total
		WHERE Fine_key = @key

END;

	



