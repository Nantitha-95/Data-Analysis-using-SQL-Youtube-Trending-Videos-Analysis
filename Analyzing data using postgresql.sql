-- Analyzing data using postgresql

/*Identify top 10-performing channels for each
country based on metrics like view count,
likes, dislikes, and comment count. */

SELECT video_id,country,channeltitle,view_count
FROM (
  SELECT video_id,country, channeltitle, view_count, ROW_NUMBER() OVER (PARTITION BY country ORDER BY view_count DESC) AS rn
  FROM joined_table
) AS subquery
WHERE rn <= 10
ORDER BY country,view_count DESC

--Find which category is trending overall

select country,title,count(title) as total_title_count from
(SELECT country, title, view_count
FROM (
  SELECT country, title, view_count, ROW_NUMBER() OVER (PARTITION BY country ORDER BY view_count DESC) AS rn
  FROM joined_table
) AS subquery
WHERE rn <= 10
ORDER BY country, view_count DESC) as s
group by country,title
order by total_title_count desc


--Find the average time taken to trend overall for each category

SELECT
  title,
  (EXTRACT(DAY FROM AVG(time_taken_to_trend)) || ' days ' ||
  LPAD(EXTRACT(HOUR FROM AVG(time_taken_to_trend))::text, 2, '0') || ':' ||
  LPAD(EXTRACT(MINUTE FROM AVG(time_taken_to_trend))::text, 2, '0') || ':' ||
  LPAD(EXTRACT(SECOND FROM AVG(time_taken_to_trend))::text, 2, '0'))::interval AS avg_time_taken_to_trend
FROM joined_table
GROUP BY title
order by avg_time_taken_to_trend
--Create a table from joined_table and include columns required for analysis & sort them by their view_count from highest to lowest

create table youtube_dataset as
select country,publishedat,channeltitle,trending_date,view_count,
likes,dislikes,comment_count,title as category_title,time_taken_to_trend
from joined_table
order by country,view_count desc

-- The below data analysis is performed using postgresql.

--Which channel & its country has highest view_countoverall

select country,channeltitle,title,view_count
from joined_table
order by view_count desc, likes desc
limit 5

--Which channel & its country has highest likes overall*/
select country,channeltitle,title,likes
from joined_table
order by likes desc
limit 5

--Which channel & its country has highest dislikes overall

select country,channeltitle,title,dislikes
from joined_table
order by dislikes desc
limit 5

--which channel grouped by category has highest trending time

select country,channeltitle,title,view_count,likes,dislikes,time_taken_to_trend 
from joined_table
order by time_taken_to_trend asc
limit 50

--Find the total views for eaxh country

SELECT country, SUM(view_count) AS total_view_count
FROM joined_table
GROUP BY country
order by total_view_count desc
