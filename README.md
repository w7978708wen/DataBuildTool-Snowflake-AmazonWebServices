
<h2>Step 1. Role and user creation</h2>

In short, I created a "transform" role, a DBT user, granted permissions to the "transform" role, and assigned the DBT user to have this role. I also created the default warehouse here. 

<a href="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Role%20and%20user%20creation.sql">Here</a> is the code . 
<br>

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

2.One minor issue occurred when loading `ratings.csv`: 3 out of 465,564 rows failed to load, likely due to formatting errors, in the source file. Since the dataset is external and the number of problematic rows is extremely small, it is acceptable to proceed.

<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/create%20stage%20and%20load%20data.sql"></img>
<br>

<a href="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/SQL%20files/create%20stage%20and%20load%20data.sql">Here </a> is the code (I combined steps 2 and 3 into the same file) .

<h2>Step 4. DBT project set-up and its connection to Snowflake</h2>
In VS Code, I created and activated the virtual environment, which stores the project's packages independently.


Next, I installed dbt-Snowflake within the virtual environment.

Then, I initialized the dbt project by giving credentials like my Snowflake Account Identifier value. I learned some trouble-shooting, like when I was not able to complete my profile.yml during the set-up because the terminal froze. So, I learned how to resume the set-up, doing steps like creating a profile.yml file from scratch in the correct folder and testing the authentication connection. 🎉

<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/dbt-snowflake%20connection.png?raw=true"></img>

<br>
I also installed extensions on VS Code like "Power User for dbt" and "dbt formatter".


<h2>Step 5. Model creation </h2>
Each dbt model is a SQL select statement which would transform my data. For each .csv file, I created a temporary table (view) in my data warehouse using VS Code, so I can directly reference to the view later. 
<a href="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/project/models/staging/src_models.sql"> Here </a> is the SQL file. 

<br>

This change is reflected in Snowflake so when I refresh the left side bar, the view appears. I like to preview the view to make sure the data transferred over.

<br>

<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/view%20created%201.png"></img>
                                                                                                                                   
<br>

<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/view%20created%202.png"></img>

<br>

<h2>Citation (for using the .CSV files):</h2>

<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/Citation.png?raw=true"></img>

