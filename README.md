# 		 数据库引论期末project报告

​									15307130185 王鹏

### Prepare: 实验环境

ubuntu 15.10; mysql 5.6.31; python 2.7

实验所用到的sql建表语句和python代码均在github上。

###　Task1: 数据库设计

用python脚本去分析表中数据的函数依赖关系，得到：

```
//user.csv:
{ user_id } -> { age, sex, user_lv_cd, user_reg_tm }
//product.csv:
{ sku_id } -> { a1, a2, a3, cate, brand }
{ a1 } -> { cate }
{ a2 } -> { cate }
{ a3 } -> { cate }
{ brand } -> { a1, cate }
//action.csv:
{ user_id } -> { cate }
{ sku_id } -> { cate, brand }
{ time } -> { cate }
{ model_id } -> { cate }
{ type } -> { cate }
{ brand } -> { cate }
//comment.csv:
{ dt, sku_id } -> { comment_num, has_bad_comment, bad_comment_rate }
{ bad_comment_rate } -> { has_bad_comment }
//以上均为非平凡函数依赖
```

按照书上给的算法，将原表分解成3NF即可。

p.s. 就数据库设计的理念而言，函数依赖本应是逻辑上的、在数据库之前就存在的关系，所以我们不能通过数据分析来“得到”函数依赖关系。但是，本次项目要求中提到"分析各表源数据的函数依赖关系"，并且表中有的字段经过了脱敏处理，且有的字段我们并不知道其在实际场景中的含义(例如a1等)，所以仅仅通过生活常识来推断函数依赖是不全面的，因此我最终还是选择了用程序去分析数据中的函数依赖关系的方法。

分表结果：

```
user(user_id, age, sex, user_lv_cd, user_reg_tm)
	primary key: (user_id)
product_main(sku_id, brand, a2, a3)
	primary key: (sku_id)
product_brand(brand, a1)
	primary key: (brand)
brand_cate(brand, cate)
	primary key: (brand)
action_main(user_id, sku_id, date_time, model_id, type)
	primary key: (user_id, sku_id, date_time, model_id, type)
comment_main(dt, sku_id, comment_num, bad_comment_rate)
	primary key: (dt, sku_id)
comment_bad(bad_comment_rate, has_bad_comment)
	primary key: (bad_comment_rate)
```



### Task2: 查询优化分析

#### 单表操作

#### 1.查询表中所有字段

示例语句：

```mysql
select * from action_main;
```

分析：

- 这一条语句需要返回该表所有的结果，用explain语句分析后发现，此句没有加上任何优化，需要检查表中的所有行。
- 优化前实测耗时4.50 sec。

优化：

- 修改mysql配置，增大read_buffer_size和tmp_table_size等。

#### 2.查询表中指定字段

示例语句：

```mysql
select user_id from action_main;
```

分析：

- 与查询1一样，理论上需要检查表中所有行，不过由于返回的结果实际上是变小了，所以查询所用的时间也变小了。
- 优化前实测耗时2.25 sec。

优化：

- 修改mysql配置，增大read_buffer_size和tmp_table_size等。

#### 3.查询表中没有重复的字段(DISTINCT)的使用

示例语句：

```mysql
select distinct date_time from action_main;
```

分析：

- 同样地，需要检查表中的所有行。explain分析结果提到了"using temporary"，这意味着需要创建一个临时表来储存结果，这样子效率会很低。
- 优化前实测耗时23.07 sec。

优化：

- 由于需要创建临时表，我们可以增大tmp_table_size。

#### 4.条件查询各表主键的字段(单值查询或范围查询)

示例语句：

```mysql
select *
from product_main
where sku_id > 0 and sku_id < 170000;
```

分析：

- 这是一个典型的range查询的操作。


- 由于sku_id被定义为了主键，经过explain分析，这条语句已经被mysql提前优化过，总行数24187行，只需要检查12050行，并提示“Using index"，这意味着mysql已经对查询进行了索引优化。
- 优化前实测耗时0.02 sec。


优化：

- 由于自带索引加成，我们需要考虑实际应用场景来对其进行优化，例如减少输出的信息，不要把整行输出。
- 修改mysql配置，可以增大key_buffer_size，即索引块的缓冲区大小。


#### 5.条件查询各表中普通字段(单值查询或范围查询)

示例语句：

```mysql
select sku_id, date_time, model_id
from action_main
where model_id = 311;
```

分析：

- 由于model_id不是一个单独的主键，所以mysql没有给它加上独立的索引，经过explain分析，这条语句需要检查表中的几乎所有行(4942987)，效率很低。
- 优化前实测耗时1.98 sec。

优化：

- 给model_id加上独立的索引。

#### 6.一个表中多个字段条件查询(单值查询或范围查询)

示例语句：

```mysql
select * 
from product_main
where sku_id > 0 and sku_id < 170000 and brand = 545;
```

分析：

- 经过explain分析，这条语句需要检查12050行，这与场景4中的结果是一样的。sku_id被预先加上了索引，这样会有效率上的提高，但是对于brand=545这个条件就需要逐个枚举检查。
- 优化前实测耗时0.01 sec。

优化：

- 给brand字段加上索引。

#### 7.用 in 进行条件查询

示例语句：

```mysql
select * 
from product_main as M
where M.sku_id in (
	select A.sku_id
	from product_main as A, product_main as B
	where A.a2 = B.a2 and A.a3 = B.a3 and B.sku_id = 100097
);
```

分析：

- 这条语句有嵌套查询，内层中需要做连接操作。由于自带主键优化，B.sku_id=100097这个条件不需要检查所有行，但是得到B的结果之后还是需要对A检查所有的行，因此瓶颈部分在于对条件(A.a2 = B.a2 and A.a3 = B.a3)的筛选。
- 优化前实测耗时0.03 sec。

优化：

- 给a2和a3分别建立索引。

#### 8.一个表中 GROUP BY、ORDER BY、HAVING 联合条件查询

示例语句：

```mysql
select sku_id
from action_main
where date_time like '2016-03-01%'
group by sku_id
having count(*) > 100
order by sku_id;
```

分析：

- 这里的查询瓶颈首先在于对'2016-03-01'条件的筛选	，其次是group by和count(*)的条件。
- explain认为此查询需要检查5612177行，然而整张action_main表只有5121344行，我认为多出来的必要的检查来来自于对group by和count(*)条件的检查。另外对于'2016-03-01%'这个条件有很大的优化空间。
- explain显示次语句需要用到文件排序和临时表。


- 优化前实测耗时2.54 sec。

优化：

- 对date_time建立索引。


- 由于需要用到排序，我们可以修改mysql的配置，增大sort_buffer_size，提高排序的速度。
- 或者是直接对sku_id建立索引，这样可以避免order by带来的排序。

#### 复合查询：

#### 1.多表联合查询

示例语句：

```mysql
select brand, count(*) as cnt
from product_main, action_main
where product_main.sku_id = action_main.sku_id
group by brand;
```

分析：

- 如果不加任何的索引，笛卡尔积的存在会使得这条语句效率非常地低。
- 不过由于sku_id是product_main表的主键，因此效率会有一定的提高（由mysql自动优化）。
- group by用到了文件排序，导致效率的低下。
- 优化前实测耗时3.71 sec。

优化：

- 对action_main中的sku_id建立索引。
- 对brand建立索引，避免文件排序。
- 或者是增大sort_buffer_size的大小，提高排序速度。
- 或者将联合查询改成join。

#### 2.join 查询

示例语句：

```mysql
select * 
from product_main natural join product_brand;
```

分析：

- 一个经典的恢复原表的操作，join实际上还是类似于笛卡尔积加条件判断，因此在缺少索引的情况下，效率很低。
- explain结果显示我们需要将两张表都检查一遍，并且用到了join buffer。
- 优化前实测耗时0.03 sec。

优化：

- 对两张表的brand建立索引。
- 修改mysql配置，增大join_buffer_size。

#### 3.存在量词 (EXISTS) 查询

示例语句：

```mysql
select product_main.sku_id
from product_main
where product_main.brand = 622 and exists (select * from action_main where action_main.date_time like '2016-03-01%' and action_main.sku_id = product_main.sku_id);
```

分析：

- 这是个带有存在量词的嵌套子查询。
- 第一个瓶颈在于'product_main.brand = 622'，因为没有索引，需要遍历整张表来检查；
- 第二个瓶颈在于每次进入子查询的时候都要检查一遍'2016-03-01%'，这是个重复的操作，很耗时间。（更不用说是在没加索引的情况下）
- explain的结果：第一张表需要检查24100行，第二张表需要检查4942987行，几乎是全部遍历。
- 优化前实测耗时226.13 sec。

优化：

- 对brand, date_time和sku_id建立索引。

- 优化查询语句，可以尝试这几种方法(在没有使用索引且没有修改mysql配置的情况下实验)

  - 1.将action_main放在外层，product_main放在内层查询：

  ```mysql
  select distinct action_main.sku_id
  from action_main
  where action_main.date_time like '2016-03-01%' and exists (select * from product_main where product_main.brand = 622 and action_main.sku_id = product_main.sku_id);
  //实测耗时：2.79 sec
  ```

  - 2.采用联合查询而不是存在量词：

  ```mysql
  select distinct product_main.sku_id
  from product_main, action_main
  where product_main.brand = 622 and action_main.date_time like '2016-03-01%' and product_main.sku_id = action_main.sku_id;
  //实测耗时：2.57 sec
  ```

  - 3.采用join方法查询：

  ```mysql
  select distinct sku_id
  from product_main natural join action_main
  where brand = 622 and date_time like '2016-03-01%';
  //实测耗时：2.71 sec
  ```

- 修改mysql配置，增大tmp_table_size。

#### 4.嵌套子查询

示例语句：

```mysql
select brand, count(*) as cnt
from product_main
where product_main.sku_id in (
	select sku_id
	from comment_main
	where comment_main.bad_comment_rate > 0.02
	group by sku_id
	having count(*) > 2
)
group by brand;
```

分析：

- 这是个带有in的嵌套子查询。
- explain语句显示，这个查询用到了文件排序和临时子表，product_main表需要检查24100行，comment_main表需要检查95461行，几乎是检查整张表，这是缺少索引的结果。
- 优化前实测耗时 0.05 sec。

优化：

- 对bad_comment_rate、product_main.grand和comment_main.sku_id加上索引。
- 修改mysql配置，增大tmp_table_size和sort_buffer_size。

#### Task 3: 数据库设计改进

通过以上的示例分析，我采用了以下的优化数据库方案：

##### 1.建立索引

我最后所建立索引用到的具体语句见create_index.sql。

##### 2.修改mysql 配置：

具体修改如下：

```
read_buffer_size = 64M
tmp_table_size = 1024M
key_buffer_size = 64M
sort_buffer_size = 64M
join_buffer_size = 64M
```

##### 3.修改tables内部结构

- 对于确定不为空的字段，规定为not null
- 对于小数字，用smallint表示。

#### 实验结果

|        | 优化前耗时   | 优化后耗时 |
| ------ | ------- | ----- |
| 单表操作_1 | 4.50s   | 3.74s |
| 单表操作_2 | 2.25s   | 1.87s |
| 单表操作_3 | 23.07s  | 1.78s |
| 单表操作_4 | 0.02s   | 0.02s |
| 单表操作_5 | 1.98s   | 0.00s |
| 单表操作_6 | 0.01s   | 0.00s |
| 单表操作_7 | 0.03s   | 0.02s |
| 单表操作_8 | 2.54s   | 1.65s |
| 复合查询_1 | 3.71s   | 3.60s |
| 复合查询_2 | 0.03s   | 0.03s |
| 复合查询_3 | 226.13s | 0.01s |
| 复合查询_4 | 0.05s   | 0.03s |