-- Converting Unix timestamp into real time and finding the first purchase day by taking the minimum 
--difference between install time and event time (adjusted to Turkey time zone UTC+3)
CREATE TEMP TABLE first_day AS (
	SELECT user_id, MIN(real_event_time::DATE-real_install_time::DATE) as first_purchase_day
	FROM (
		SELECT user_id, 
	  	TO_CHAR(TIMESTAMP 'epoch' + event_timestamp * INTERVAL '1 second' + INTERVAL '3 hours','DD-MM-YYYY') 
	  		  as real_event_time,
	 	TO_CHAR(TIMESTAMP 'epoch' + install_timestamp * INTERVAL '1 second' + INTERVAL '3 hours', 'DD-MM-YYYY') 
			  as real_install_time,
	  		revenue
		FROM dataset) AS new
	GROUP BY user_id);

--Converting Unix timestamp into real time and finding the days that players made purchase by taking  
--difference between install time and event time with revenue included
CREATE TEMP TABLE whole AS (
	SELECT user_id, (real_event_time::DATE-real_install_time::DATE) as days, revenue
	FROM (
		SELECT user_id, 
	  	TO_CHAR(TIMESTAMP 'epoch' + event_timestamp * INTERVAL '1 second' + INTERVAL '3 hours','DD-MM-YYYY') 
	  		  as real_event_time,
	 	 TO_CHAR(TIMESTAMP 'epoch' + install_timestamp * INTERVAL '1 second' + INTERVAL '3 hours', 'DD-MM-YYYY') 
			  as real_install_time,
	  		revenue
	FROM dataset) AS new);

--Grouping sum of revenues generated each day by players' first purchase day
SELECT first_purchase_day, days, SUM(revenue)
	FROM whole 
LEFT JOIN first_day ON whole.user_id=first_day.user_id
GROUP BY 1,2
ORDER BY 1,2