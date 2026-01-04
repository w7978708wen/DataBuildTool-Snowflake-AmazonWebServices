
<h2>Step 1. Role and user creation</h2>

In short, I created a "transform" role, a dbt user, granted permissions to the "transform" role, and assigned the dbt user to have this role. I also created the default warehouse here. 

Code available upon request.

<h2>Step 2. Created the stage to connect to AWS </h2>

I created the internal permission to access the data. I created a new user within my AWS Console and assigned it with "AmazonS3FullAccess" permission. 

I retrieved the user's credentials to create a stage in Snowflake. I chose the same database and schema used in the step 1's code snippet. 


<br>

<h2>Step 3. Load the data from AWS S3 Bucket to Snowflake</h2>

I created my first S3 bucket. Then, I uploaded the .CSV files to later use in Snowflake.

<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/Files%20upload.png?raw=true"></img>

<br>
Then, in Snowflake, I created an empty new table called "raw_movies" and assigned the data type of each column (movieID, title, genre). 


<br>

Next, I copied the content from my Amazon Web Service's S3 Bucket's <code>movie.csv</code> file onto my empty "raw_movies" table in Snowflake. In the file format line, I specified <code>SKIP=HEADER=1</code> because the value in every column’s row 1 is the column name. This step is a good place to check whether the connection (involving the AWS IAM credentials) was actually established. 

Then, I viewed the "raw_movie" table's output. Here is a quick look of the first few lines:

<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/loaded_movies_csv.png?raw=true"></img>

<br>

I repeated the same process for all other <code>.csv</code> files. 

<br>

I learned 2 major things: 

1.If your created table's column  name and data type don't entirely match those in the <code>.csv</code>file, then every observation will not be loaded (result in error). 

2.One minor issue occurred when loading <code>ratings.csv</code>: 3 out of 465,564 rows failed to load, likely due to formatting errors, in the source file. Since the dataset is external and the number of problematic rows is extremely small, it is acceptable to proceed.

<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/create%20stage%20and%20load%20data.sql"></img>
<br>

<a href="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/SQL%20files/create%20stage%20and%20load%20data.sql">Here </a> is the code (I combined steps 2 and 3 into the same file) .

<h2>Step 4. dbt project set-up and its connection to Snowflake</h2>
In VS Code, I created and activated the virtual environment, which stores the project's packages independently.


Next, I installed dbt-Snowflake within the virtual environment.

Then, I initialized the dbt project by giving credentials like my Snowflake Account Identifier value. I learned some trouble-shooting, like when I was not able to complete my profile.yml during the set-up because the terminal froze. So, I learned how to resume the set-up, doing steps like creating a profile.yml file from scratch in the correct folder and testing the authentication connection. 🎉

<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/dbt-snowflake%20connection.png?raw=true"></img>

<br>
I also installed extensions on VS Code like "Power User for dbt" and "dbt formatter".


<h2>Step 5. Model creation </h2>
Here, I want the data to go from the raw to staging.

Each dbt model is a SQL select statement which would transform my data. For each <code>.csv</code> file, I created a temporary table (view) in my data warehouse using VS Code, so I can directly reference to the view later. I also have the option to change the dbt materialization configuration, where I could change from getting view to table, etc. 

<br>

<a href="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/project/models/staging/src_models.sql"> Here </a> is the SQL file. 

<br>

This change is reflected in Snowflake so when I refresh the Database Explorer, the view appears. I like to preview the view to make sure the data transferred over.

<br>

<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/view%20created%201.png"></img>
                                                                                                                                   
<br>

<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/view%20created%202.png"></img>

<br>

Using the same method, I created a dbt model for each of the tables containing raw data ... to take this data to the staging step.

<br>

<h2>Step 6. Data warehouse: Fact and dimension table creation </h2>
In Snowflake, I also wrote some DROP statements to drop all the views made using dbt models from Snowflake's "raw" folder, which represents the raw schema. This is because views/tables created in the staging step should have a different schema than raw data. 

<br>
Also: Ideally, we should have a different schema for the raw version and for the development version (aka staging version). So in profile.yml, I change the schema from “raw" to “dev”. This means that every dimension table will have "dev" schema while every table that contains the raw data will have "raw" schema. 

<br>

In addition, I updated the dbt model configuration so that models are materialized as views by default at the project level, while models inside the fact (fct) and dim folders are materialized as tables.

As a result, in Step 5, all dbt models were created as views. In Step 6, the fact and dimension models changed to be materialized as tables by default, while other models continued to be created as views.

<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/dbt%20model%20configuration.png?raw=true"></img>

<br>

I wrote CTE using SQL to help with creating the fact and dimension tables. 

<h3>Dimension tables</h3>

Here is a preview of the first dimension table I created:
<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/preview%20dimension%20table.png?raw=true"></img>

Using a similar method, I create the remaining dimension tables by using the dbt model outputs. 

<br>

<h3>Fact tables</h3>

I created the first fact table <code>fct_g_score.sql</code> as a table, which is the default materialization I set in <code>dbt_profile.yml</code> . 

<br>

Then, I created the second fact table <code>fct_ratings.sql</code> as an incremental model to efficiently handle newly arriving fact data over time. This incremental model is designed to automatically appends only new records whose timestamps are more recent than the latest timestamp already loaded in the table. The configuration I specified in <code>fct_ratings.sql</code> overwrites the default configuration written in <code>dbt_profile.yml</code>. 


Then I retrieved the <code>stage_ratings.sql</code>, which was first created as a view in the staging folder. I want to simulate the situation where the table is conditioned to change when a new row of data comes in. So in <code>stage_ratings.sql</code>, I specified configuration in the file which would overwrite the default configuration I set in <code>dbt_profile.yml</code>. Even though it will still be inside the "Staging" folder, it will become a table instead of staying as a view. 

In Snowflake, here is a snippet of the table output before adding a new line of record. 
<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/src_ratings%20output%201.png?raw=true" width=900></img>


After adding a new line of record and re-opening the table, here is a snippet of the output:

<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/src_ratings%20output%202.png?raw=true" width=900></img>

Since the new row has a newer ratings timestamp than the existing record (for movie_id = 7151), the new row is appended to the table. 

<br>

In order for the new row in stage_ratings dimension table to reflect in fct_ratings fact table, I typed some new commands on VS Code’s terminal, which detects whether there is any new data or not for the incremental model. Later, in Snowflake, the fct_ratings table also has this new row. 
The src_ratings and fct_ratings table have the same-looking output. 

<br>
I also created an ephemeral model called <code>dim_movies_w_tags.sql</code>, where I can re-use the SQL logic, without creating a physical table/view in Snowflake. This type of model is beneficial for reducing storage costs and I/O costs leading to better query performance ... because it doesn't need to fetch data by reading intermediate tables/views.

<br>

I experimented calling the ephemeral model <code>dim_movies_w_tags.sql</code> by creating a SQL file called <code>ep_movie_w_tags.sql</code> with this code inside:

```sql
WITH fct_movie_w_tags AS (
    SELECT * FROM {{ ref('dim_movies_with_tags')}}
)

SELECT * FROM fct_movie_w_tags
```

<code>ep_movie_w_tags.sql</code> is only created for educational purposes to help myself understand the application of ephemeral models.
<br>

In Snowflake's Database Explorer, I can preview the <code>dim_movies_w_tags.sql</code> 's data through <code>ep_movie_w_tags.sql</code> .

<br>

<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/ephemeral%20model%20logic%20used.png?raw=true"></img>

<br>

In general, after creating each view/table, I prefer to run the dbt on the terminal and seeing it via Snowflake's Database Explorer to see if any errors need to be fixed.

The files containing the code are located across the <code>models</code> folder. Click <a href="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/tree/main/project/models">here</a> to view. 

<h2>Step 7. Turning CSV content into tables without uploading CSV files </h2>
I created a dbt seed by manually defining a small CSV dataset, which dbt materialized as a table in Snowflake. For small datasets, this is more convenient than uploading the CSV files from AWS S3 bucket and integrating them into Snowflake. 

<br>

Although a seed does not need to be wrapped in a model to work because a seed is basically a CSV file, it is good practice to do so for architecture and governance reasons. I create a dbt model called <code>mart_dates.sql</code> that references the earlier dbt seed <code>seed_dates.sql</code> created. This will convert the seed’s contents to a mart-level table that is in the staging step, which is the same step that all other dbt models should currently be in. 


Code viewable <a href="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/tree/main/project/seeds">here</a>. 

<h2>Step 8. Create snapshot and surrogate key in table </h2>
I create a snapshot of table <code>stage_ratings.sql</code> model to track historical changes to individual records over time when source data is updated.

I also learned how to create a surrogate key for the snapshot table used one of dbt's packages. The surrogate key is made because none of the values in each column is unique on their own. The surrogate key ,called "row_key", is derived from the combination of the "user_id", "movie_id", and "tag" columns from the <code>stage_ratings.sql</code> table 

<br>

On Snowflake, here is my snapshot table with the surrogate key column highlighted in blue:
<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/snapshot%20table.png?raw=true"></img>

Then I learned how to reference to the snapshot by writing a query in Snowflake, which reads snapshot history and orders rows by user_id to see how each record changes over time.

```sql
SELECT * FROM snapshots.snap_tags
ORDER BY user_id, dbt_valid_from DESC;
```
Here is a snippet of the query output 
<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/output%20of%20query%20which%20references%20snapshots.snap_tags.png?raw=true"></img>

I changed the tag's value for rows with user_id = 18. In the meantime, I changed the configuration of <code>stage_ratings.sql</code> from view to table, so the table could be referenced in the query. 

Then I took another dbt snapshot, and viewed the output of the snapshot table. There are now 2 rows - 1 row has the old tag value and the other row has the new tag value.

Here is a snippet of the output snapshot table:
<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/snapshot%202%20table.png?raw=true"></img>

View my code on Snowflake <a href="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/take%20snapshots.sql">here</a>.

<h2>Step 9. dbt testing </h2>
Before the data is moved forward, it is important to ensure that all test cases passed. I performed dbt tests to validate data quality by checking that columns meet defined constraints, such as having non-null values, accepted values, and/or valid relationships with other tables.

<br>

I can also choose to set a warning instead of an error if failure thresholds are met.

I also defined a macro to reuse test logic across all models in the project. For example, I used this macro to enforce that values must be non-null across all models.

<br>

<h2>Step 10. dbt documentation</h2>
I requested dbt documentation to be generated for my project, which is served locally as a website on my machine. There, I can view detailed information for each table, including its dependencies on other tables.

<br>

Here is a preview:

<br>

<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/dbt%20documentation.png?raw=true" height="400"></img>

<br>

<h2>Step 11. Analysis</h2>

I used Snowflake and dbt compiler to do data analysis that I believe will provide business value to my target client, a broadcasting company that wants to purchase some movies to air on their television channels. It would be good to identify some well-performing movies to maximize their ROI in the form of number of clients wanting to put commercials during the movie's break times.

This analysis on the historical movie ratings data is designed for a broadcasting company that wants to purchase movie licensing rights to air films on its television channel(s).

From a business perspective, the broadcaster’s goal is to:

a.Attract a large audience

b.Increase advertising demand during commercial breaks

c.Maximize return on investment (ROI) from movie licensing costs

To support these objectives, I used Snowflake and dbt compiler. I used audience ratings as a proxy for viewer engagement and popularity, which are key indicators for advertising value.


Question 1. Which are the 50 highest rated movies (sorted in descending rating and has a minimum rating count of 100)
<br>
Business need:
Highly rated movies with a large number of ratings are more likely to attract consistent viewership, so they should be played during prime-time broadcasting and would yield higher advertising revenue.
<br>
Here is a snippet of the output:
<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/output%20of%20top%2050%20highest%20rated%20movies%20analysis.png?raw=true"></img>

<br>

Question 2. Which are the highest-rated Comedy genre movies (sorted in descending rating and with minimum rating count of 100)?
<br>
Business need:
If the client is interested in purchasing movies from a specific genre, this analysis narrows down the results to support more targeted decision-making.
<br>
Here is a snippet of the output:
<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/output%20of%2050%20highest%20rated%20comedy%20movies%20analysis.png?raw=true"></img>

<br>

Question 3. Which movie genres receive the most ratings overall?
<br>
Business need:
Genres with higher rating volumes tend to indicate larger or more engaged audiences, which can influence the client's strategy in:
<br>
a.Which genres to prioritize during peak vs. non-peak hours
<br>
b.Whether to allocate more budget toward buying movies in high-engagement genres
<br>
Here is a snippet of the output:
<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/output%20of%20which%20genre%20of%20movies%20receive%20most%20ratings.png?raw=true"></img>

Note:
The genre field in this analysis is derived from appended genre tags in the source dataset. Movies with multiple genres (e.g., Comedy|Drama) are treated as separate genre classifications from single-genre movies (e.g., Comedy).

<br>

<h2>Citation (for using the CSV files):</h2>


<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/Citation.png?raw=true"></img>

