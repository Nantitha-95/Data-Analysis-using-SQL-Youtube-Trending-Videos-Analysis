--The below code is written in postgresql.

--Add a new column Country to the all the tables

ALTER TABLE us
ADD COLUMN Country Text;

--Update all rows to set the Country Name for the new column for all the tables
UPDATE us
SET Country='United Sates';

--Combine all the tables using union all

create table combined_table
as
select video_id,country,publishedat,channelTitle,categoryid,trending_date,view_count,likes,
dislikes,comment_count
from br1
union all
select video_id,country,publishedat,channelTitle,categoryid,trending_date,view_count,likes,
dislikes,comment_count
from ca
union all
select video_id,country,publishedat,channelTitle,categoryid,trending_date,view_count,likes,
dislikes,comment_count
from de
union all
select video_id,country,publishedat,channelTitle,categoryid,trending_date,view_count,likes,
dislikes,comment_count
from fr
union all
select video_id,country,publishedat,channelTitle,categoryid,trending_date,view_count,likes,
dislikes,comment_count
from gb
union all
select video_id,country,publishedat,channelTitle,categoryid,trending_date,view_count,likes,
dislikes,comment_count
from ind
union all
select video_id,country,publishedat,channelTitle,categoryid,trending_date,view_count,likes,
dislikes,comment_count
from jp
union all
select video_id,country,publishedat,channelTitle,categoryid,trending_date,view_count,likes,
dislikes,comment_count
from kr
union all
select video_id,country,publishedat,channelTitle,categoryid,trending_date,view_count,likes,
dislikes,comment_count
from mx
union all
select video_id,country,publishedat,channelTitle,categoryid,trending_date,view_count,likes,
dislikes,comment_count
from ru
union all 
select video_id,country,publishedat,channelTitle,categoryid,trending_date,view_count,likes,
dislikes,comment_count 
from us

select * from combined_table

-- Start the cleaning process

--Change the dataypes of the columns

ALTER TABLE combined_table
ALTER COLUMN categoryid TYPE Integer USING categoryid::Integer,
ALTER COLUMN view_count TYPE Integer USING view_count::Integer,
ALTER COLUMN likes TYPE Integer USING likes::Integer,
ALTER COLUMN dislikes TYPE Integer USING dislikes::Integer,
ALTER COLUMN comment_count TYPE Integer USING comment_count::Integer,
ALTER COLUMN publishedat TYPE TIMESTAMP WITH TIME ZONE
USING publishedat::TIMESTAMP WITH TIME ZONE


--Selecting the columns with null values

select * from combined_table where video_id is null or
country is null or publishedat is null or channelTitle
is null or categoryid is null or
trending_date is null or view_count is null or likes is null 
or dislikes is null or
comment_count is null or
published_date is null or published_time is null or
trending_d is null or trending_time is null

select * from combined_table where channeltitle='null'

--Deleting the row where channelTitle is null

Delete from combined_table
where channeltitle is null


-- Check for any leading and trailing whitespace characters from a string and remove them with trim().

update combined_table set
video_id=trim(video_id),
channeltitle=trim(channeltitle),
country=trim(country)

-- Check for duplicate entries

select video_id,country,publishedat,channeltitle,categoryid,trending_date,
view_count,likes,dislikes,comment_count,
count(*) as counted
from combined_table
group by  video_id,country,publishedat,channeltitle,categoryid,trending_date,
view_count,likes,dislikes,comment_count
having count(*)>1

-- Remove duplicates by showing only unique values

select distinct * from combined_table

--create a table to store only distinct values

create table distinct_table
as select distinct * from combined_table


-- check for any errors in table

select * from distinct_table where channeltitle='#NAME?' or 
video_id='#NAME?'or categoryid<0 or view_count<0 or likes<0 or 
dislikes<0 or comment_count<0 or published_date IS NULL OR published_date::text !~ '^\d{4}-\d{2}-\d{2}$'
or trending_d IS NULL OR trending_d::text !~ '^\d{4}-\d{2}-\d{2}$'
or published_time IS NULL 
OR to_char(published_time, 'HH24:MI:SS') != published_time::text or
trending_time IS NULL 
OR to_char(trending_time, 'HH24:MI:SS') != trending_time::text

--select table containing channeltitle as #NAME?

select * from distinct_table where channeltitle='#NAME?'

--replacing #NAME? with "Unknown channel"

UPDATE distinct_table
SET channelTitle = 'Unknown channel'
WHERE country IN ('Mexico', 'France') AND channeltitle = '#NAME?';

-- Sort table based on view_count

select * from distinct_table
order by view_count desc

--trim() for title column in category_id table

update category_id
set title=trim(title)

--change datatype of id1 column of category id table

alter table category_id
ALTER COLUMN id1 TYPE Integer USING id1::Integer;

--inner join to get title of category id from category_id table

create table joined_table as
SELECT distinct_table.*, category_id.id1, category_id.title
FROM distinct_table
INNER JOIN category_id ON distinct_table.categoryid = category_id.id1;


--count of categoryid for each country

select country,categoryid,count(*) as c
from joined_table
group by country,categoryid
order by country

-- Add a new column to calculate time taken to trend
ALTER TABLE joined_table
ADD COLUMN time_taken_to_trend interval

--finding time taken to trend from published to trending

update joined_table
set time_taken_to_trend=  (trending_date::timestamp AT TIME ZONE 'UTC' - publishedat::timestamp AT TIME ZONE 'UTC') 

--Check whether time taken to trend is <0

select * from joined_table
where time_taken_to_trend < INTERVAL '0';


-- Swap publishedat & trending_date dates where time taken to trend is <0

UPDATE joined_table
SET publishedat = trending_date::timestamp AT TIME ZONE 'UTC',
    trending_date = publishedat::text::timestamp AT TIME ZONE 'UTC'    
WHERE time_taken_to_trend < INTERVAL '0';

--Check for duplicate rows

select video_id,country,channeltitle,categoryid,
view_count,likes,dislikes,comment_count,published_date,
count(*) as c
from joined_table
group by video_id,country,channeltitle,categoryid,
view_count,likes,dislikes,comment_count,published_date
having count(*)>1

--Delete duplicate rows

DELETE FROM joined_table
WHERE (video_id, country, channeltitle, categoryid, view_count, likes, dislikes, comment_count, publishedat) IN (
  SELECT video_id, country, channeltitle, categoryid, view_count, likes, dislikes, comment_count, publishedat
  FROM joined_table
  GROUP BY video_id, country, channeltitle, categoryid, view_count, likes, dislikes, comment_count, publishedat
  HAVING COUNT(*) > 1
)
AND ctid NOT IN (
  SELECT MIN(ctid)
  FROM joined_table
  GROUP BY video_id, country, channeltitle, categoryid, view_count, likes, dislikes, comment_count, publishedat
  HAVING COUNT(*) > 1
);

--Verify if duplicate rows are deleted
SELECT *
from joined_table
where video_id='TN2vT_jpW1o' and country='Great Britain'and
channeltitle='The Royal Family' and categoryid=22 and
view_count=0 and likes=0 and dislikes=0 and comment_count=0 and
publishedat='2022-09-19 05:58:02-07'

--Select channel title where the value is assigned as "null" and replace it with "Unknown channel"
select country,channeltitle from joined_table
where channeltitle='null'


UPDATE joined_table
SET channeltitle = 'Unknown channel'
WHERE channeltitle='null';








