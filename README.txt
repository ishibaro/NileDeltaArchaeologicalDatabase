#####################################################################
Urban fluctuations in the north-central region of the Nile Delta: 4000 years of river and urban development in Egypt.
Israel Hinojosa Baliño (2022)  Durham University
README FILE - 
#####################################################################


#####################################################################
PART 0 - Folder contents
#####################################################################

-- README.txt 
** this file!

[THESIS] Divided in two volumes.
--- Hinojosa-Balino-PhDthesis-vol1.pdf 
***** Includes thesis, images, tables and main text, with references only for the first volume.
--- Hinojosa-Balino-PhDthesis-vol2.pdf 
***** It is the Appendix. It includes the metadata for the thesis (vol.1), as well as complimentary material.

-- DB_dataOnly.sql
-- DB_structureOnly.sql
-- DB_all.sql
** PostgreSQL Database files (see below under Complimentary material)

-- PHPwebpage.zip
** Zipped files containing the working version of the PHP webpage that allows you to add new entries easily (see Part 6 on this README file)

#####################################################################
Complimentary material
#####################################################################

#####################################################################
Setting up the PostgreSQL database and webpage files
#####################################################################
## Regardless of these README file, installation instructions are available for each platform or OS in each software's webpage. ##
## You can set up the database in almost any computer as long as it meets the hardware requirements. ##
## The default SQL is configured to work with an user called "postgres", which is also the superuser. This database was created
for reproducibility purposes. Should you require a new working environment with a specific username, you need to grant user privileges
to any other user but postgres. To find out more:

https://www.postgresql.org/docs/current/sql-alterdatabase.html#:~:text=To%20alter%20the%20owner%2C%20you,default%20tablespace%20of%20the%20database.
https://stackoverflow.com/questions/4313323/how-to-change-owner-of-postgresql-database
https://stackoverflow.com/questions/23933327/best-way-to-change-the-owner-of-a-postgresql-database-and-their-tables

#####################################################################
PART 1 - Installation of software and PostgreSQL Server
#####################################################################

To run this database locally, you need to install PostgreSQL and PostGIS. 

First, install PostgreSQL, from this webpage https://www.postgresql.org/

Then, although not necessary, you can install pgAdmin, which is a PostgreSQL Tools and database management program, open source and free https://www.pgadmin.org/
In this readme file, I will guide you through the process of setting up teh database using pgAdmin.

If you use the Interactive installer by EDB (https://www.enterprisedb.com/downloads/postgres-postgresql-downloads), pgAdmin is installed along the PostgreSQL version you choose.

During the installation, you will be asked to set up a superuser password, normally, this superuser is called "postgres". Choose any password.

Then select a port to run the PostgreSQL server, by default is 5432. Unless you know what you are doing, you can change the port here, but the default is ok.
For the rest, just continue the installation.

Immediately after the installation finishes, the window of Stack builder will appear and will allow you to install additional programs on top of your PostgreSQL installation.

Select your PostgreSQL server, click Next, and under Spatial Extensions, select one version of PostGIS.
Alternatively, you can install PostGIS using the links provided in this webpage https://postgis.net/install/ depending on your platform and OS.

Follow the instructions and install PostGIS without creating any Spatial database.

#######################################################
PART 2 - creating and importing the database
#######################################################

Once the installation is finished, open pgAdmin 4. You will be asked for the superuser password you created.

On the left hand side of the application, you will see the Servers explorer tree. Open it and select the server of your PostgreSQL installation (e.g. PostgreSQL 14).
Click the small arrow symbol (>) to open the server's content. You will see three elements: 1) Databases, 2) Login/Group Roles and 3) Tablespaces.

Right click on Databases and select Create, and then Database.

Choose a name for your database and be sure that the Owner is postgres.
You can add a comment. Then click Save. Once the Database is created, you need to import the SQL files included with the thesis.

First of all, we need to add the PostGIS extension to our database.
Click on > related to the recently created database and then right click on Extensions and then Create and select Extension...
Select PostGIS from the Name list or start typing PostGIS and select it. Then click Save.

Now, right click on the database's name and select Query tool. This will open a kind of notepad.
In this notepad you can run SQL queries. We will import our SQL query.
Click on the first icon, from Left to Right, which represents a Folder. Look up fro the SQL files included in this thesis. And select one of them.

Select DB_all.sql if you want to run the FULL database as it was when I uploaded it.

Select DB_structureOnly.sql if you would like to use teh Database as a template for your own database.
 
Select DB_dataOnly.sql if you just want to explore the datatables.

Once you select you SQL file, click on the symbol ► to Run the query.

You should not have errors. HOWEVER, the database includes some non-standard characters. When you select the file for the Query, a pop up windows will say:

[The file opened contains bidirectional Unicode characters which could be interpreted
differently than what is displayed. If this is unexpected it is recommended that you review
 the text in an application that can display hidden Unicode characters before proceeding.]

 You can ignore this.

#####################################################################
PART 3 - Visualising data in pgAdmin
#####################################################################

To see the database you need to refresh your database. To do this, right click on the database's name and select Refresh...

Once it is refreshed, you can see the newly created tables, triggers and views under

Schemas>Public

To see a specific table, click on the table and then click on the Icon "View Data" that appears on top of the Server's tree panel, the icon is similar to a grid.
Alternatively go to the menu Object> View/Edit data> All rows.

Notice that if you add only the data structure you won't be able to see anything but the headers!

#####################################################################
PART 4 - Adding data from an SQL file
#####################################################################

You can upload the data from DB_dataOnly.sql  if you succesfully ran the query to create the structure only.
If you right click on the database's name and select Query tool. Click on the first icon, from Left to Right, which represents a Folder.
Look up the SQL files included in this thesis and this time select DB_dataOnly.sql
Run this query, refresh your database and View it. NOW you should see the data.

#####################################################################
PART 5- Adding the database to QGIS
#####################################################################

You can easily add the data to QGIS. 

Open the data source manager Ctrl+L, or click on the corresponding icon, or go the menu Layer> Data Source Manager, and
click on PostgreSQL.
You can go directly to this part simply by selecting Layer> Add Layer> Add PostGIS Layers..., or simply Ctrl+Shift+D

In here, you might have database connections already. Ignore them and click the New button

Now type the follwing
Name: Whatever you want. It does not really matter. This is name for QGIS
Host: localhost
Port: 5432
Database: THIS IS THE NAME OF YOUR DATABASE as you name it in pgAdmin (e.g. eesdb)

Now, below you will find two tabs. Select the one that says Basic
Here,
Username: postgres
Password: YOUR PASSWORD (notice that this is the superuser password)

Click OK. If everything is OK, you should be able to see the database in the list of available connections or,
it should appear immediately after you add it. It will show only 4 tables. These tables are shown because these are the tables with geometry.

If you want to see ALL the tables, go down and select: Also list tables with no geometry
If you select this option, you will see a tree with three options to choose under Schema.
As you can see, now the interface changed as you see it on pgAdmin.
You might choose any table available but beware that most of them are the auxiliary files of the PostGIS database.
What you want is to display the tables under Public. Here you can see all the tables related exclusively to the database.

To add a table, you just need to double click on it. PostGIS databases can be exported,
manipulated and edited almost exactly as you would do it with a Shapefile, KML or Geopackage.

To see the sites with all temporalities, select medarcheomode.
To see only the sites select eessites.

You can perform queries and play with the geometry. The triggers will update the coordinates automatically,
not only with the location of the point. It will populate the fields easting, northings, latitude and longitude,
if you add a new site, or it will update the columns if you move the point or edit the coordinates manually.

Notice that medarchaeomode is a subset of the full database since not all the sites have temporal information.

#####################################################################
PART 6- PHP webpage
#####################################################################

I included the files used to generate the webpage that allows you to connect to the database and add new entries.
The webpage runs with Apache and PHP. To deploy the webpage locally, I used XAMPP,

"a free and open-source cross-platform web server solution stack package developed by Apache Friends, 
consisting mainly of the Apache HTTP Server, MariaDB database, and interpreters for scripts written
in the PHP and Perl programming languages.[3][4] Since most actual web server deployments use the same
components as XAMPP, it makes transitioning from a local test server to a live server possible."

To deploy the webpage on Internet, I used https://www.alwaysdata.com/, which also offers the possibility to deploy a PostgreSQL+PostGIS server

Since I don't own the right of the database information, I can't offer more details regarding deployment
or the URL of my own webpage. However, please stay tuned on my GitHub channel because it might be possible
in the future to have it running officially in the EES Delta Survey webpage
--EES Delta Survey
https://www.ees.ac.uk/delta-survey

--GitHub ishibaro
https://github.com/ishibaro

I don't add further information regarding this webpage but feel free to explore it. 

#####################################################################
PART 7- Comments
#####################################################################

If you have a question please send me a message via twitter @ishiba or via email to nimodo.nosepudosoloishiba@gmai.com