/*
Database Connection Details:
hostname: lmu-dev-01.isba.co
username: lmu_dba
password: go_lions
database: tahoe_fuzzy_factory
port: 3306

Situation:
Tahoe Fuzzy Factory has been live for about 8 months. Your CEO is due to present company performance metrics to the board next week.
You'll be the one tasked with preparing relevant metrics to show the company's promising growth.

Objective:
Extract and analyze website traffic and performance data from the Tahoe Fuzzy Factory database to quantify the company's growth and
to tell the story of how you have been able to generate that growth.

As an analyst, the first part of your job is extracting and analyzing the requested data. The next part of your job is effectively 
communicating the story to your stakeholders.

Restrict to data before November 27, 2012, when the CEO made the email request.
*/

/*
Business Problem:

Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for the # of gsearch sessions and orders
so that we can showcase the growth there? Include the conversion rate.

Expected results:
session_year|session_month|sessions|orders|conversion_rate|
------------+-------------+--------+------+---------------+
        2012|            3|    1843|    59|           3.20|
        2012|            4|    3569|    93|           2.61|
        2012|            5|    3405|    96|           2.82|
        2012|            6|    3590|   121|           3.37|
        2012|            7|    3797|   145|           3.82|
        2012|            8|    4887|   184|           3.77|
        2012|            9|    4487|   186|           4.15|
        2012|           10|    5519|   237|           4.29|
        2012|           11|    8586|   360|           4.19|
*/
SELECT
	YEAR(ws.created_at) AS session_year,
	MONTH(ws.created_at) AS session_month,
	COUNT(ws.website_session_id) AS sessions,
	COUNT(o.order_id) AS orders, 
	FORMAT(( COUNT(o.order_id) / COUNT(ws.website_session_id) ),4)*100 AS conversion_rate
FROM website_sessions ws 
LEFT JOIN orders o 
	ON ws.website_session_id = o.website_session_id 
WHERE ws.utm_source = 'gsearch'
	AND ws.created_at <= '2012-11-27'
GROUP BY session_year, session_month;

/*
Insight:

Conversion rate increased through the year 2012 within gsearch. The above query 
clearly showcases the growth in converting website sessions into actual orders as 
shown by the conversion rate. We also notice that the more sessions, the higher conversion rate!
*/


/*
Business Problem:

It would be great to see a similar monthly trend for gsearch but this time splitting out nonbrand and brand campaigns separately.
I wonder if brand is picking up at all. If so, this is a good story to tell.

Expected results:
session_year|session_month|nonbrand_sessions|nonbrand_orders|brand_sessions|brand_orders|
------------+-------------+-----------------+---------------+--------------+------------+
        2012|            3|             1835|             59|             8|           0|
        2012|            4|             3505|             87|            64|           6|
        2012|            5|             3292|             90|           113|           6|
        2012|            6|             3449|            115|           141|           6|
        2012|            7|             3647|            135|           150|          10|
        2012|            8|             4683|            174|           204|          10|
        2012|            9|             4222|            170|           265|          16|
        2012|           10|             5186|            222|           333|          15|
        2012|           11|             8208|            343|           378|          17|
*/
SELECT
	YEAR(ws.created_at) AS session_year,
	MONTH(ws.created_at) AS session_month,
	COUNT(CASE WHEN ws.utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS nonbrand_sessions,
	COUNT(CASE WHEN ws.utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) AS nonbrand_orders,
	COUNT(CASE WHEN ws.utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END) AS brand_sessions,
	COUNT(CASE WHEN ws.utm_campaign = 'brand' THEN o.order_id ELSE NULL END) AS brand_orders
FROM website_sessions ws 
LEFT JOIN orders o 
	ON ws.website_session_id = o.website_session_id 
WHERE ws.utm_source = 'gsearch'
	AND ws.created_at <= '2012-11-27'
GROUP BY session_year, session_month;

/*
Insight:
Way more volume from users in non_brand sessions, resulting in more nonbrand_orders
compared to branded sessions and branded orders. 
*/


/*
Business Problem:

While we're on gsearch, could you dive into nonbrand and pull monthly sessions and orders split by device type?
I want to show the board we really know our traffic sources.

Expected results:
session_year|session_month|desktop_sessions|desktop_orders|mobile_sessions|mobile_orders|
------------+-------------+----------------+--------------+---------------+-------------+
        2012|            3|            1119|            49|            716|           10|
        2012|            4|            2135|            76|           1370|           11|
        2012|            5|            2271|            82|           1021|            8|
        2012|            6|            2678|           107|            771|            8|
        2012|            7|            2768|           121|            879|           14|
        2012|            8|            3519|           165|           1164|            9|
        2012|            9|            3169|           154|           1053|           16|
        2012|           10|            3929|           203|           1257|           19|
        2012|           11|            6233|           311|           1975|           32|
*/
SELECT
	YEAR(ws.created_at) AS session_year,
	MONTH(ws.created_at) AS session_month,
	COUNT(CASE WHEN ws.device_type = 'desktop' THEN ws.website_session_id ELSE NULL END) AS desktop_sessions,
	COUNT(CASE WHEN ws.device_type = 'desktop' THEN o.order_id ELSE NULL END) AS desktop_orders,
	COUNT(CASE WHEN ws.device_type = 'mobile' THEN ws.website_session_id ELSE NULL END) AS mobile_sessions,
	COUNT(CASE WHEN ws.device_type = 'mobile' THEN o.order_id ELSE NULL END) AS mobile_orders
FROM website_sessions ws 
LEFT JOIN orders o 
	ON ws.website_session_id = o.website_session_id 
WHERE ws.utm_source = 'gsearch'
	AND ws.utm_campaign = 'nonbrand'
	AND ws.created_at <= '2012-11-27'
GROUP BY session_year, session_month;

/*
Insights: 

In gsearch nonbranded sessions, sessions on desktop is significantly larger than sessions via mobiel devices
,leading to more desktop orders compared to mobile orders.
*/


/*
Business Problem:

I'm worried that one of our more pessimistic board members may be concerned about the large % of traffic from gsearch.
Can you pull monthly trends for gsearch, alongside monthly trends for each of our other channels?

Hint: CASE can have an AND operator to check against multiple conditions

Expected results:
session_year|session_month|gsearch_paid_sessions|bsearch_paid_sessions|organic_search_sessions|direct_type_in_sessions|
------------+-------------+---------------------+---------------------+-----------------------+-----------------------+
        2012|            3|                 1843|                    2|                      8|                      9|
        2012|            4|                 3569|                   11|                     76|                     71|
        2012|            5|                 3405|                   25|                    148|                    150|
        2012|            6|                 3590|                   25|                    194|                    169|
        2012|            7|                 3797|                   44|                    206|                    188|
        2012|            8|                 4887|                  696|                    265|                    250|
        2012|            9|                 4487|                 1438|                    332|                    284|
        2012|           10|                 5519|                 1770|                    427|                    442|
        2012|           11|                 8586|                 2752|                    525|                    475|
*/

-- find the various utm sources and referers to see the traffic we're getting
SELECT 
	DISTINCT
		utm_source,
		utm_campaign,
		http_referer
FROM website_sessions ws 
WHERE created_at < '2012-11-27';

SELECT 
	YEAR(ws.created_at) AS session_year,
	MONTH(ws.created_at) AS session_month,
	COUNT(CASE WHEN ws.utm_source = 'gsearch' THEN ws.website_session_id ELSE NULL END) AS gsearch_paid_sessions,
	COUNT(CASE WHEN ws.utm_source = 'bsearch' THEN ws.website_session_id ELSE NULL END) AS bsearch_paid_sessions,
	COUNT(CASE WHEN ws.utm_source IS NULL AND ws.http_referer IS NOT NULL THEN ws.website_session_id ELSE NULL END) AS organic_search_sessions,
	COUNT(CASE WHEN ws.utm_source IS NULL AND ws.http_referer IS NULL THEN ws.website_session_id ELSE NULL END) AS direct_type_in_sessions
FROM website_sessions ws 
LEFT JOIN orders o 
	ON ws.website_session_id = o.website_session_id 
WHERE ws.created_at < '2012-11-27'
GROUP BY session_year, session_month;
/*
utm_source|utm_campaign|http_referer           |
----------+------------+-----------------------+
gsearch   |nonbrand    |https://www.gsearch.com| gsearch_paid_session
NULL      |NULL        |NULL                   | direct_type_in_session
gsearch   |brand       |https://www.gsearch.com| gsearch_paid_session
NULL      |NULL        |https://www.gsearch.com| organic_search_session
bsearch   |brand       |https://www.bsearch.com| bsearch_paid_session
NULL      |NULL        |https://www.bsearch.com| organic_search_session
bsearch   |nonbrand    |https://www.bsearch.com| bsearch_paid_session
 */


/*
Insight:

Though the concerns are legitimate being that the majority of sessions belong to gsearch paid sessions,  
we are seeing per month an positive incline in bsearch, organic search, and direct type in sessions. 
*/

/*
Business Problem:

I'd like to tell the story of our website performance over the course of the first 8 months. 
Could you pull session to order conversion rates by month?

Expected results:
session_year|session_month|sessions|orders|conversion_rate|
------------+-------------+--------+------+---------------+
        2012|            3|    1862|    59|           3.17|
        2012|            4|    3727|   100|           2.68|
        2012|            5|    3728|   107|           2.87|
        2012|            6|    3978|   140|           3.52|
        2012|            7|    4235|   169|           3.99|
        2012|            8|    6098|   228|           3.74|
        2012|            9|    6541|   285|           4.36|
        2012|           10|    8158|   368|           4.51|
        2012|           11|   12338|   547|           4.43|
*/
SELECT 
	YEAR(ws.created_at) AS session_year,
	MONTH(ws.created_at) AS session_month,
	COUNT(ws.website_session_id) AS sessions,
	COUNT(o.order_id) AS orders,
	ROUND(100*( COUNT(o.order_id) / COUNT(ws.website_session_id) ),2) AS conversion_rate
FROM website_sessions ws 
LEFT JOIN orders o 
	ON ws.website_session_id = o.website_session_id 
WHERE ws.created_at < '2012-11-27'
GROUP BY session_year, session_month;


/*
Insight:

Over the 8 months, conversion rate from sessions to orders has increased. This could also be explained by the increase in session volume. 
Sessions increased over the timespan, so did orders, consequently so did the conversion rate. 
*/


/*
Business Problem:

For the landing page test, it would be great to show a full conversion funnel from each of the two landing pages 
(/home, /lander-1) to orders. Use the time period when the test was running (Jun 19 - Jul 28).

Expected results:
landing_page_version_seen|lander_ctr|products_ctr|mrfuzzy_ctr|cart_ctr|shipping_ctr|billing_ctr|
-------------------------+----------+------------+-----------+--------+------------+-----------+
homepage                 |     46.82|       71.00|      42.84|   67.29|       85.76|      46.56|
custom_lander            |     46.79|       71.34|      44.99|   66.47|       85.22|      47.96|
*/
-- firts join 2 tables, get the sessions and the pageview urls, if they r specific ones, 1, else 0.
WITH funnel AS (
SELECT
	ws.website_session_id ,
	CASE WHEN wp.pageview_url = '/home' THEN 1 ELSE 0 END AS home_page,
	CASE WHEN wp.pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander_page,
	CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
	CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
	CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
	CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
	CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_page
FROM website_pageviews wp 
JOIN website_sessions ws 
	ON wp.website_session_id = ws.website_session_id 
WHERE ws.created_at BETWEEN '2012-06-19' AND '2012-07-28'
),
funnel2 AS (
SELECT 
	f.website_session_id,
	MAX(home_page) AS saw_homepage,
	MAX(lander_page) AS saw_lander_page,
	MAX(products_page) AS saw_products_page,
	MAX(mrfuzzy_page) AS saw_mrfuzzy_page,
	MAX(cart_page) AS saw_cart_page,
	MAX(shipping_page) AS saw_shipping_page,
	MAX(billing_page) AS saw_billing_page,
	MAX(thank_you_page) AS saw_thank_you_page
FROM funnel f
GROUP BY f.website_session_id
)
SELECT 
	CASE 
		WHEN saw_homepage = 1 THEN 'homepage'
		WHEN saw_lander_page = 1 THEN 'custom_lander'
	ELSE NULL
	END AS landing_page_version_seen,
	FORMAT(COUNT(CASE WHEN saw_products_page = 1 THEN website_session_id ELSE NULL END) / COUNT(website_session_id), 4)*100 AS lander_ctr,
	FORMAT(COUNT(CASE WHEN saw_mrfuzzy_page = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN saw_products_page = 1 THEN website_session_id ELSE NULL END),4)*100 AS products_ctr,
	FORMAT(COUNT(CASE WHEN saw_cart_page = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN saw_mrfuzzy_page = 1 THEN website_session_id ELSE NULL END),4)*100 AS mrfuzzy_ctr,
	FORMAT(COUNT(CASE WHEN saw_shipping_page = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN saw_cart_page = 1 THEN website_session_id ELSE NULL END),4)*100 AS cart_ctr,
	FORMAT(COUNT(CASE WHEN saw_billing_page = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN saw_shipping_page = 1 THEN website_session_id ELSE NULL END),4)*100 AS shipping_ctr,
	FORMAT(COUNT(CASE WHEN saw_thank_you_page = 1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN saw_billing_page = 1 THEN website_session_id ELSE NULL END),4)*100 AS billing_ctr
FROM funnel2
GROUP BY landing_page_version_seen;


/*
Insight:

ABOUT 85-86% of our users on homepage and custom lander get to shipping page, but only about 47 to 48% of our users end up getting to billing page and buying. 
THere seems to a problem that is stopping users from executing their orders after seeing the shipping information, we ought to look into this. 
*/


/*
Business Problem:

I'd love for you to quantify the impact of our billing page A/B test. Please analyze the lift generated from the test
(Sep 10 - Nov 10) in terms of revenue per billing page session. Manually calculate the revenue per billing page session
difference between the old and new billing page versions. 

Expected results:
billing_version_seen|sessions|revenue_per_billing_page_seen|
--------------------+--------+-----------------------------+
/billing            |     657|                        22.90|
/billing-2          |     653|                        31.39|
*/
WITH cte AS (
	SELECT 
		wp.website_session_id ,
		wp.pageview_url,
		o.price_usd 
	FROM website_pageviews wp 
	LEFT JOIN orders o 
		ON wp.website_session_id = o.website_session_id 
	WHERE wp.created_at BETWEEN '2012-09-10' AND '2012-11-10'
		AND wp.pageview_url IN ('/billing','/billing-2')
)
SELECT 
	cte.pageview_url AS billing_version_seen,
	ROUND(COUNT(cte.website_session_id),2) AS sessions,
	ROUND(SUM(cte.price_usd) / COUNT(cte.pageview_url),2) AS revenue_per_billing_page
FROM cte
GROUP BY cte.pageview_url;
-- Another way without CTE
SELECT 
	wp.pageview_url AS billing_verison_seen,
	ROUND(COUNT(wp.website_session_id),2) AS sessions,
	ROUND(SUM(o.price_usd) / COUNT(wp.pageview_url),2) AS revenue_per_billing_page_seen 
FROM website_pageviews wp 
LEFT JOIN orders o 
	ON wp.website_session_id = o.website_session_id 
WHERE wp.created_at BETWEEN '2012-09-10' AND '2012-11-;10'
	AND wp.pageview_url IN ('/billing','/billing-2')
GROUP BY wp.pageview_url;

/*
Insight:

billing-2 generates more revenue per billing page seen than regular billing!
 */


/*
Business Problem:

Pull the number of billing page sessions (sessions that saw '/billing' or '/billing-2') for the past month and multiply that value
by the lift generated from the test (Sep 10 - Nov 10) to understand the monthly impact. 
You manually calculated the lift by taking the revenue per billing page session difference between /billing and /billing-2. (31.39-22.9)
You can hard code the revenue lift per billing session into the query.

Expected results:
past_month_billing_sessions|billing_test_value|
---------------------------+------------------+
                       1161|           9856.89|
*/
SELECT
	COUNT(wp.website_session_id) AS billing_page_sessions_last_month,
	COUNT(wp.website_session_id) * (31.39-22.9) AS billing_test_value
FROM website_pageviews wp 
WHERE wp.pageview_url IN ('/billing','/billing-2')	
	AND wp.created_at BETWEEN '2012-10-27' AND '2012-11-27';
	

/*
Insight:

taking the difference in revenue per billing page seen between billing and billing 2, we multiplied it to the number of sessions in the 
past month including billing and billing2. This means that the past month, each billing session(including billing and billing2) can be attributed by $8.49 dollars per session in lift generated. 
 */



