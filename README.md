
<h2>Step 1. Role and User Creation</h2>

In short, I created a "transform" role, a DBT user, granted permissions to the "transform" role, and assigned the DBT user to have this role. I also created the default warehouse here. 

Here is the <a href="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Role%20and%20user%20creation.sql">code </a>. 
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

Next, I copied the content from my Amazon Web Service's S3 Bucket's <code>movie.csv</code> file onto my empty "raw_movies" table in Snowflake. This step is a good place to check whether the connection (involving the AWS IAM credentials) was actually established. 

Then, I viewed the "raw_movie" table's output. Here is a quick look of the first few lines:

<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/loaded_movies_csv.png?raw=true"></img>

<br>

<h2>Citation (for using the .CSV files):</h2>

<img src="https://github.com/w7978708wen/DataBuildTool-Snowflake-AmazonWebServices/blob/main/Screenshots/Citation.png?raw=true"></img>

