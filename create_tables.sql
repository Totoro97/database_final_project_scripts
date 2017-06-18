drop table if exists user, product, comment, action;
drop table if exists product_main, product_brand, brand_cate, action_main, action_brand, action_type, comment_main, comment_bad;

create table user (
	user_id int not null,
	age char(6) not null,
	sex smallint not null, 
	user_lv_cd smallint not null, 
	user_reg_tm date not null,
	primary key(user_id)
);

create table product (
	sku_id int not null,
	a1 smallint not null,
	a2 smallint not null,
	a3 smallint not null,
	cate smallint not null,
	brand smallint not null,
	primary key(sku_id)
);

create table comment (
	dt date not null,
	sku_id int not null,
	comment_num smallint not null,
	has_bad_comment boolean not null,
	bad_comment_rate float(4) not null
);

create table action (
	user_id int not null,
	sku_id int not null,
	date_time datetime not null,
	model_id smallint not null,
	type smallint not null,
	cate smallint not null,
	brand smallint not null
);

create table product_main (
	sku_id int not null,
	brand smallint not null,
	a2 smallint not null,
	a3 smallint not null,
	primary key(sku_id)
);

create table product_brand (
	brand smallint not null,
	a1 smallint not null,
	primary key(brand)
);

create table brand_cate (
	brand smallint not null,
	cate smallint not null,
	primary key(brand)
);

create table action_main (
	user_id int not null,
	sku_id int not null,
	date_time datetime not null,
	model_id smallint not null,
	type smallint not null,
	primary key(user_id, sku_id, date_time, model_id, type)
);

create table comment_main (
	dt date not null,
	sku_id int not null,
	comment_num smallint not null,
	bad_comment_rate float(4) not null,
	primary key(dt, sku_id)
);

create table comment_bad (
	bad_comment_rate float(4) not null,
	has_bad_comment boolean not null,
	primary key(bad_comment_rate)
);
