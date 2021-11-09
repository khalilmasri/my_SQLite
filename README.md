# my_sqlite

SQLite is a C-language library and its the most used database engine in the world.

## Structure

1. Constructor It will be prototyped:

* `def initialize`

2. From Implement a `from` method which must be present on each request. From will take a parameter and it will be the name of the `table`. (technically a table_name is also a filename (.csv))

* `def from(table_name)`

3. Select Implement a `where` method which will take one argument a string OR an array of string. It will continue to build the request. During the run() you will collect on the result only the columns sent as parameters to select.

* `def select(column_name)`

4. Where Implement a `where` method which will take 2 arguments: column_name and value. It will continue to build the request. During the run() you will filter the result which match the value.

* `def where(column_name, criteria)`

5. Join Implement a `join` method which will load another filename_db and will join both database on a `on` column.

* `def join(column_on_db_a, filename_db_b, column_on_db_b)`

6. Order Implement an `order` method which will received two parameters, `order` (:asc or :desc) and column_name. It will sort depending on the order base on the column_name.

* `def order(order, column_name)`

7. Insert Implement a method to `insert` which will receive a `table name` (filename). It will continue to build the request.

* `def insert(table_name)`

8. Values Implement a method to `values` which will receive `data`. (a hash of data on format (`key => value`)). It will continue to build the request. During the run() you do the insert.

* `def values(data)`

9. Delete Implement a `delete` method. It set the request to `delete` on all `matching` row. It will continue to build the request. An delete request might be associated with a `where` request.

* `def delete`

10. Run Implement a run method and it will execute the request.

## How to use

### Request
For the request side I will be leaving comment blocks where you can uncomment or take a look on how to use the basic commands
To run the request after uncommenting
```rb 
ruby my_sqlite_request.rb
```
**IMPORTANT**
Please comment the `request.run` after finishing with request side **OR** client side won't work.
#
### Client

**Warning: be careful with syntaxes!**

To run the client you can
 ```rb 
 ruby my_sqlite_cli.rb
 ```
#
#### SELECT
**SELECT** command can accept either * or **value** from the header of the csv (name, year_start, year_end, position, height, weight, birth_date, college) **max of ONE field** after **SELECT**.

The * will print the whole csv in the terminal (be careful, you will get 4300+ lines, use at your own risk).
SELECT must be associated with **FROM** command and the name of the file EX: 

```rb
SELECT * FROM nba_player_data.csv
```

SELECT can accept also a **WHERE** followed by value from the header of the csv (name, year_start, year_end, position, height, weight, birth_date, college)

```rb 
SELECT name FROM nba_player_data.csv WHERE name ='Don Adams'
```
#
#### INSERT
**INSERT** command can insert **INTO** the **csv file** and then followed by the **VALUES** you want to add. EX:
```rb
INSERT INTO nba_player_lite1.csv VALUES (Don Adams, 1971, 1977, F,6-6, 210, November 27, 1947,Northwestern University)
```

#
#### UPDATE
**UPDATE** command will update a certain player data, **UPDATE** needs to be followed by **csv file** then **SET** the value **where** you want to change **max ONE value** followed by **=** and the **value** and **WHERE** followed by **where** and the **value**. EX:
```rb
UPDATE nba_player_data.csv SET position =G WHERE name ='Don Adams' 
```

#
###### DELETE
**DELETE** command will delete a certain row in the csv where you specified. Needs to be followed by **FROM** and the **csv file** and **WHERE**. EX:
```rb
DELETE FROM nba_player_data.csv WHERE name ='Don Adams' 
```
#
###### QUIT
**QUIT** to quit the client
```rb
QUIT
```


