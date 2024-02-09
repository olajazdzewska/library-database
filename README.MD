# Library database

## Description
 Database written in MSSQL, for which a potential client could be a school library. It stores data about students (Students and Cards tables), books (Books, Genres, Authors, Writings, Publishers tables) and interactions between students and books (Book_events and Fines tables). Fines records are automatically created by trigger, when book is overdue, lost or destroyed and store information about a suitable to the event fine. 

## Stack
 - MsSQL

## Instruction
 First run `init00.sql` file then `insert00.sql` file. In `queries.sql` file there are queries showing functionality of database. File `raport.docx` contin detailed description of the database (ERD, textual description and RDB schema).
