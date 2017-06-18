load data infile '/home/totoro/DataBase/final-project/data/user.csv'
into table user
fields terminated by ','  optionally enclosed by '"' escaped by '"'   
lines terminated by '\n'
ignore 1 rows;

load data infile '/home/totoro/DataBase/final-project/data/product.csv'
into table product
fields terminated by ','  optionally enclosed by '"' escaped by '"'   
lines terminated by '\n'
ignore 1 rows;

load data infile '/home/totoro/DataBase/final-project/data/comment.csv'
into table comment
fields terminated by ','  optionally enclosed by '"' escaped by '"'   
lines terminated by '\n'
ignore 1 rows;

load data infile '/home/totoro/DataBase/final-project/data/action.csv'
into table action
fields terminated by ','  optionally enclosed by '"' escaped by '"'   
lines terminated by '\n'
ignore 1 rows;
