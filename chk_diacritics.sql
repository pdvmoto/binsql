/***

chk_diacritics.sql.

test this script from various tools: sqlplus (no hope), sqldev, dbeaver, etc.. 


***/ 
Drop table test purge;  
Create table test ( LANGUAGE_NAME VARCHAR2(40 CHAR), WELCOME_TRANSLATION VARCHAR2(40 CHAR));  
insert into test values ('Modern Greek','Καλώς Ορίσατε');  
insert into test values ('Chinese - Cantonese','歡迎');  
insert into test values ('Chinese - Mandarin','歡迎光臨');  
insert into test values ('Bengali','স্বাগতম');  
insert into test values ('Arabic','أهلاً و سهلاً');  
insert into test values ('Georgian','კეთილი იყოს თქვენი');  
insert into test values ('Gujarati','પધારો');  
insert into test values ('Lao','ຍິນດີຕ້ອນຮັບ');  
insert into test values ('Persian - Farsi',' خوش آمدید');  
insert into test values ('Limburgish','Wilkóm');  
insert into test values ('Korean','환영합니다');  
insert into test values ('Japanese','ようこそ');  
insert into test values ('Russian','Добро пожаловать!');  
insert into test values ('Czech','Vítáme tĕ');  
insert into test values ('Polish','Witam Cię');  
commit;  
select * from test;  
