insert into product_main(sku_id, brand, a2, a3)
select distinct sku_id, brand, a2, a3
from product;

insert into product_brand(brand, a1)
select distinct brand, a1
from product;

insert into brand_cate(brand, cate)
select distinct brand, cate
from product;

insert into comment_main(dt, sku_id, comment_num, bad_comment_rate)
select distinct dt, sku_id, comment_num, bad_comment_rate
from comment;

insert into comment_bad(bad_comment_rate, has_bad_comment)
select distinct bad_comment_rate, has_bad_comment
from comment;

insert into action_main(user_id, sku_id, date_time, model_id, type)
select distinct user_id, sku_id, date_time, model_id, type
from action;
