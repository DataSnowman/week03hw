DROP TABLE IF EXISTS twitter_raw_ext;

CREATE EXTERNAL TABLE IF NOT EXISTS twitter_raw_ext ( json_response STRING) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' STORED AS TEXTFILE LOCATION '${INPUT}';

DROP TABLE IF EXISTS twitter_temp;

create table twitter_temp
(
	id bigint,
	created_at string,
	created_at_date string,
	created_at_year string,
	created_at_month string,
	created_at_day string,
	created_at_time string,
	in_reply_to_user_id_str string,
	text string,
	contributors string,
	retweeted string,
	truncated string,
	coordinates string,
	source string,
	retweet_count int,
	url string,
	hashtags array<string>,
	user_mentions array<string>,
	first_hashtag string,
	first_user_mention string,
	screen_name string,
	name string,
	followers_count int,
	listed_count int,
	friends_count int,
	lang string,
	user_location string,
	time_zone string,
	profile_image_url string,
	json_response string
);


from twitter_raw_ext
insert overwrite table twitter_temp
select
	cast(get_json_object(json_response, '$.id_str') as bigint),
		
	get_json_object(json_response, '$.created_at'),
	concat(substr (get_json_object(json_response, '$.created_at'),1,10),' ',
		substr (get_json_object(json_response, '$.created_at'),27,4)),

	substr (get_json_object(json_response, '$.created_at'),27,4),
	
	case substr (get_json_object(json_response, '$.created_at'),5,3)
		when "Jan" then "01"
		when "Feb" then "02"
		when "Mar" then "03"
		when "Apr" then "04"
		when "May" then "05"
		when "Jun" then "06"
		when "Jul" then "07"
		when "Aug" then "08"
		when "Sep" then "09"
		when "Oct" then "10"
		when "Nov" then "11"
		when "Dec" then "12" end,

	substr (get_json_object(json_response, '$.created_at'),9,2),


	substr (get_json_object(json_response, '$.created_at'),12,8),

	get_json_object(json_response, '$.in_reply_to_user_id_str'),
	get_json_object(json_response, '$.text'),
	get_json_object(json_response, '$.contributors'),
	get_json_object(json_response, '$.retweeted'),
	get_json_object(json_response, '$.truncated'),
	get_json_object(json_response, '$.coordinates'),
	get_json_object(json_response, '$.source'),
	cast (get_json_object(json_response, '$.retweet_count') as int),
	get_json_object(json_response, '$.entities.display_url'),
	array(	
		trim(lower(get_json_object(json_response, '$.entities.hashtags[0].text'))),
		trim(lower(get_json_object(json_response, '$.entities.hashtags[1].text'))),
		trim(lower(get_json_object(json_response, '$.entities.hashtags[2].text'))),
		trim(lower(get_json_object(json_response, '$.entities.hashtags[3].text'))),
		trim(lower(get_json_object(json_response, '$.entities.hashtags[4].text')))),
	array(
		trim(lower(get_json_object(json_response, '$.entities.user_mentions[0].screen_name'))),
		trim(lower(get_json_object(json_response, '$.entities.user_mentions[1].screen_name'))),
		trim(lower(get_json_object(json_response, '$.entities.user_mentions[2].screen_name'))),
		trim(lower(get_json_object(json_response, '$.entities.user_mentions[3].screen_name'))),
		trim(lower(get_json_object(json_response, '$.entities.user_mentions[4].screen_name')))),
	trim(lower(get_json_object(json_response, '$.entities.hashtags[0].text'))),
	trim(lower(get_json_object(json_response, '$.entities.user_mentions[0].screen_name'))),
	get_json_object(json_response, '$.user.screen_name'),
	get_json_object(json_response, '$.user.name'),
	cast (get_json_object(json_response, '$.user.followers_count') as int),
	cast (get_json_object(json_response, '$.user.listed_count') as int),
	cast (get_json_object(json_response, '$.user.friends_count') as int),
	get_json_object(json_response, '$.user.lang'),
	get_json_object(json_response, '$.user.location'),
	get_json_object(json_response, '$.user.time_zone'),
	get_json_object(json_response, '$.user.profile_image_url'),
	json_response
where (length(json_response) > 500);

DROP TABLE IF EXISTS twitter_final;

create table twitter_final
(
	id bigint,
	created_at string,
	created_at_date string,
	created_at_year string,
	created_at_month string,
	created_at_day string,
	created_at_time string,
	in_reply_to_user_id_str string,
	contributors string,
	retweeted string,
	truncated string,
	coordinates string,
	source string,
	retweet_count int,
	url string,
	first_hashtag string,
	first_user_mention string,
	screen_name string,
	name string,
	followers_count int,
	listed_count int,
	friends_count int,
	lang string,
	user_location string,
	time_zone string,
	profile_image_url string
);


from twitter_temp
insert overwrite table twitter_final
select id,
	created_at,
	created_at_date,
	created_at_year,
	created_at_month,
	created_at_day,
	created_at_time,
	in_reply_to_user_id_str,
	contributors,
	retweeted,
	truncated,
	coordinates,
	source,
	retweet_count,
	url,
	first_hashtag,
	first_user_mention,
	screen_name,
	name,
	followers_count,
	listed_count,
	friends_count,
	lang,
	user_location,
	time_zone,
	profile_image_url;

DROP TABLE IF EXISTS tsvexport;

CREATE EXTERNAL TABLE tsvexport (
 	id bigint,
	created_at string,
	created_at_date string,
	created_at_year string,
	created_at_month string,
	created_at_day string,
	created_at_time string,
	retweet_count int,
	name string,
	followers_count int,
	listed_count int,
	friends_count int,
	lang string,
	user_location string,
	time_zone string
 )
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION '${OUTPUT}tsvexport/';

INSERT OVERWRITE TABLE tsvexport
SELECT
    	id,
	created_at,
	created_at_date,
	created_at_year,
	created_at_month,
	created_at_day,
	created_at_time,
	retweet_count,
	name,
	followers_count,
	listed_count,
	friends_count,
	lang,
	user_location,
	time_zone
FROM
twitter_final
where id is not null;

DROP TABLE IF EXISTS top20tsv;

CREATE EXTERNAL TABLE top20tsv (
	time_zone string,
	cnt bigint
	
 )
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION '${OUTPUT}top20/';

INSERT OVERWRITE TABLE top20tsv
SELECT
	time_zone,
	count(id) as cnt
FROM
twitter_final
WHERE id is not null
GROUP BY time_zone
ORDER BY cnt desc limit 22;
