/* CREATE INDEX index_name ON table_name (column_list) */

create index index_model_id on action_main (model_id);

create index index_brand on product_main (brand);

create index index_a2 on product_main (a2);

create index index_a3 on product_main (a3);

create index index_date_time on action_main (date_time);

create index index_sku_id on action_main (sku_id);

create index index_sku_id on comment_main (sku_id);

create index index_bad_comment_rate on comment_main (bad_comment_rate);


