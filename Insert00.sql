INSERT INTO Students (Name, Surname, Grade, Is_teacher, Year)   
VALUES ('Jan', 'Nowak', 'd', 0, 4),
('Grzegorz', 'Spolka', 'b', 0, 3),
('Alicja', 'Mesjasz', 'd', 0, 2),
('Julia', 'Mesjasz', 'a', 0, 1),
('Daniel', 'Worek', 'b', 0, 2),
('Kamil', 'Kulas', 'c', 0, 3),
('Wiktoria', 'Niemiec', 'a', 0, 1),
('Julia', 'Knot', 'd', 0, 2),
('Robert', 'Deniro', 'a', 0, 1),
('Piotr', 'Walc', 'd', 0, 4),
('Malgorzata', 'Krolik', NULL, 1, NULL);


INSERT INTO Cards (Is_blocked, Is_available, Students_id)
VALUES (0, 0, 0),
(0, 1, 1),
(1, 1, 2),
(0, 1, 2),
(0, 1, 3),
(0, 1, 4),
(0, 1, 6),
(0, 1, 7),
(1, 1, 8),
(0, 1, 9);


INSERT INTO Publishers(Release_date, Realese_number, Publisher_name)
VALUES (CONVERT(DATETIME, '1999.06.05'), 2, 'Czarne'),
(CONVERT(DATETIME, '1988.07.25'), 2, 'Czarne'),
(CONVERT(DATETIME, '1973.12.09'), 1, 'Tanie Lektury'),
(CONVERT(DATETIME, '2008.06.05'), 6, 'Tanie Lektury'),
(CONVERT(DATETIME, '2018.08.17'), 4, 'Tanie Lektury'),
(CONVERT(DATETIME, '2003.04.21'), 1, 'Znak'),
(CONVERT(DATETIME, '2020.06.05'), 2, 'Znak'),
(CONVERT(DATETIME, '1998.02.15'), 8, 'Znak'),
(CONVERT(DATETIME, '2016.08.30'), 3, 'Znak'),
(CONVERT(DATETIME , '1992.11.05'), 1, 'Czarne'),
(NULL, NULL, 'not_added'); 


INSERT INTO Books (Title, Is_set_text, Publisher_id)
VALUES ('Lalka', 1, 10),
('Mistrz i Malgorzata', 1, 2),
('Chlopi',1,8),
('Dziela Kochanowskiego',0,1),
('Dziela Mickiewicza',0,3),
('Antygona',1,9),
('Koran',0,7),
('Ferdydurke',1,5),
('1984',0,4),
('Proces',0,6),
('Basnie braci Grimm', 0, 6);


INSERT INTO Authors (Name, Surname)
VALUES ('Boleslaw', 'Prus'),
('Michail','Bulhakow'),
('Wladyslaw','Reymont'),
('Karol','Szczurek'),
('Jaroslaw','Kaczka'),
('Sofokles',NULL),
('Witold','Gombrowicz'),
('George','Orwell'),
('Franz','Kafka'),
('Jan','Kochanowski'),
('Adam', 'Mickiewicz'),
('Wilhelm', 'Grimm'),
('Jacob', 'Grimm');



INSERT INTO Who_edited(Book_id, Author_id)
VALUES (0, 0),
(1,1),
(2,2),
(3,3),
(3,4),
(5,3),
(6,4),
(7,6),
(8,7),
(9,8),
(10,11),
(10,12);


INSERT INTO Writings (Title)
VALUES ('Tren I'),
('Tren II'),
('Tren V'),
('Na Zdrowie'),
('Nic dwa razy'),
('Czego chcesz od nas, Panie'),
('Romans'),
('Lilije'),
('Rybka'),
('Tren VI'),
('Tren XI'),
('Tren X'),
('Jas i Malgosia');


INSERT INTO Genres (Name)
VALUES ('Romans'),
('Sci-fi'),
('Przygoda'),
('Naukowe'),
('Obyczjowe'),
('Poezja'),
('Dramat'),
('Horror'),
('Kryminal'),
('Dystopia'),
('Dla dzieci');


INSERT INTO Contain (Writing_id, Book_id)
VALUES (0, 3),
(1, 3),
(2,3),
(3,3),
(5,3),
(6,4),
(7,4),
(8,3),
(9,3),
(10,3),
(11,3),
(12,10);

INSERT INTO Written_by  (Writing_id, Author_id)
VALUES (0,9),
(1,9),
(2,9),
(4,9),
(5,10),
(6,10),
(7,10),
(8,9),
(9,9),
(10,9),
(11,11),
(11,12);


INSERT INTO What_kinds (Book_id, Genre_id)
VALUES (0,2),
(1,6),
(2,6),
(3,4),
(4,4),
(5,8),
(6,7),
(7,5),
(8,9),
(10,3);


INSERT INTO Copies(Is_lend, Condition, Number, Book_id, Title)
VALUES (1,'1st page is missing', 1, 0, 'Lalka'),
(0, NULL , 2, 0, 'Lalka'),
(0, 'Cover ripped', 1, 1, 'Mistrz i Malgorzata'),
(1, NULL, 2, 1, 'Mistrz i Malgorzata'),
(1, '3rd page ripped', 1, 2, 'Chlopi'),
(0, 'Cover ripped', 1, 3, 'Dziela Kochanowskiego'),
(1, NULL , 1, 4, 'Dziela Mickiewicza'),
(1, 'Cover stained', 2, 4, 'Dziela Mickiewicza'),
(0, NULL, 3, 4, 'Dziela Mickiewicza'),
(1, '5th page is missing', 1, 5, 'Antygona'),
(1, 'stain on page 40', 1, 6, 'Koran'),
(1, NULL, 2, 6, 'Koran'),
(1, 'Cover creased', 1, 7, 'Ferdydurke'),
(1, '23rd page ripped', 1, 8, '1984'),
(1, NULL, 2, 8, '1984'),
(0, '70-80 pages creased', 1, 9, 'Proces'),
(0, 'Cover ripped', 2, 9,'Proces'),
(0, 'cover stained', 3, 9, 'Proces'),
(0, NULL, 4, 9, 'Proces'),
(0, NULL, 1, 10, 'Basnie braci Grimm');


INSERT INTO Book_events (When_returned, Copy_id, Card_id)
VALUES (NULL, 0, 2),
(CONVERT(DATE, '2024.01.20'), 3,5),
( NULL, 4, 5),
(CONVERT(DATE, '2023.12.19'), 5, 2),
( NULL, 6, 3),
( NULL, 7, 4),
( NULL, 12, 2),
( NULL, 9, 5),
( NULL, 10, 6),
( NULL, 11, 7),
( CONVERT(DATE, '2024.02.01'), 13, 2),
( NULL, 14, 0),
( NULL, 15, 0);

INSERT INTO Book_events (When_lend, When_returned, Copy_id, Card_id)
VALUES (CONVERT(DATE, '2024.02.02'), CONVERT(DATE, '2024.02.10'), 13, 2)

UPDATE Book_events
SET Is_lost = 1
WHERE Event_id = 2;-- AND Event_id = 5;

UPDATE Book_events
SET Is_overdue = 1, Is_lost = 1
WHERE Event_id = 12; -- AND Event_id = 5; -- AND Event_id = 4;

UPDATE Book_events
SET Is_overdue = 1, Is_lost = 1
WHERE Event_id = 5;

UPDATE Book_events
SET Is_destroyed = 1
WHERE Event_id = 10; -- AND Event_id = 4;  -- AND Event_id = 6;

UPDATE Book_events
SET Is_destroyed = 1
WHERE Event_id = 4;


UPDATE Book_events
SET Is_destroyed = 1
WHERE Event_id = 13;


select * from Fines

UPDATE Book_events
SET Is_overdue = 1
WHERE Event_id = 11;

UPDATE Book_events
SET When_returned = CONVERT(DATE, '2024.04.01')
WHERE Event_id = 11;

UPDATE Book_events
SET Is_overdue = 1, Is_destroyed=1
WHERE Event_id = 8; -- AND Event_id = 4;

UPDATE Book_events
SET Is_overdue = 1, Is_destroyed=1
WHERE Event_id = 4;


UPDATE Book_events
SET When_returned = CONVERT(DATE, '2024.02.01')
WHERE Event_id = 12;

SELECT * FROM Fines
 
