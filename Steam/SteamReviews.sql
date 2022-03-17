-- UNFORTUNATELY TIMESTAMPS AND AUTHOR STEAM_ID CAN'T BE USED DUE TO BYTE LIMITS ON INTEGERS

-- LETS START BY CHANGING COLUMNS WITH AUTHOR FROM HAVING A ' ' TO A '_' IN OBJECT EXPLORER
-- AND CHANGING STEAM_REVIEWS TO STEAM_RAW
USE SteamPortfolio;

EXEC sp_rename 'steam_reviews', 'steam_raw';

-- FROM HERE LETS ORGANIZE THE DATA TO SEPERATE THE RAW FROM OUR WORK

-- LETS ALSO FILTER OUT NON-ENGLISH CHARACTERS

SELECT DISTINCT app_id, app_name
INTO games
FROM steam_raw
WHERE LANGUAGE LIKE 'English'; -- THIS WILL PROBABLY REQUIRE THE MOST CLEANUP

SELECT review_id, language, review
INTO reviews
FROM steam_raw
WHERE LANGUAGE LIKE 'English';

SELECT "index", author_num_reviews
INTO authors
FROM steam_raw
WHERE LANGUAGE LIKE 'English';

SELECT review_id, app_id, votes_helpful, votes_funny, comment_count,
recommended, steam_purchase, received_for_free, written_during_early_access
INTO review_details
FROM steam_raw
WHERE LANGUAGE LIKE 'English';

SELECT review_id, "index", author_playtime_forever, author_playtime_last_two_weeks, author_playtime_at_review
INTO review_author_details
FROM steam_raw
WHERE LANGUAGE LIKE 'English';

ALTER TABLE games
ALTER COLUMN app_id BIGINT NOT NULL;

ALTER TABLE reviews
ALTER COLUMN review_id BIGINT NOT NULL;

ALTER TABLE authors
ALTER COLUMN "index" BIGINT NOT NULL;

ALTER TABLE review_details
ALTER COLUMN app_id BIGINT NOT NULL;

ALTER TABLE review_details
ALTER COLUMN review_id BIGINT NOT NULL;

ALTER TABLE review_author_details
ALTER COLUMN review_id BIGINT NOT NULL;

ALTER TABLE review_author_details
ALTER COLUMN "index" BIGINT NOT NULL;

ALTER TABLE games
ADD PRIMARY KEY(app_id);

ALTER TABLE reviews
ADD PRIMARY KEY(review_id);

ALTER TABLE authors
ADD PRIMARY KEY("index");

ALTER TABLE review_details
ADD FOREIGN KEY(review_id) REFERENCES reviews(review_id);

ALTER TABLE review_details
ADD FOREIGN KEY(app_id) REFERENCES games(app_id);

ALTER TABLE review_author_details
ADD FOREIGN KEY(review_id) REFERENCES reviews(review_id);

ALTER TABLE review_author_details
ADD FOREIGN KEY("index") REFERENCES authors("index");

-- LETS STARTS SOME EDA

SELECT * FROM authors;

SELECT * FROM games; -- DEFINITELY FOUND SOME ISSUES
-- LETS ISOLATE IT

SELECT * FROM games
WHERE "app_name" LIKE '%[^a-z 0-9 -:]%';
-- HERE THEY ARE, UNFORTUNATELY THIS REQUIRES INDIVIDUAL DATA ENTRY

UPDATE games
SET "app_name" = 'South Park: The Stick of Truth'
WHERE app_id = 213670; -- TM TYPESCRIPT ERROR

UPDATE games
SET "app_name" = 'Dragon Cliff'
WHERE app_id = 758190; -- UNKNOWN ERROR

UPDATE games
SET "app_name" = 'Sekiro Shadows Die Twice'
WHERE app_id = 814380; -- TM TYPESCRIPT ERROR

UPDATE games
SET "app_name" = 'Hitman 2'
WHERE app_id = 863550; -- TM TYPESCRIPT ERROR

UPDATE games
SET "app_name" = 'Kingdom Heroes 8'
WHERE app_id = 875210; -- TRANSLATION ERROR

-- LETS RECHECK
SELECT * FROM games;
-- LOOKS MUCH BETTER, LETS CONTINUE EDA

SELECT * FROM reviews;
-- SAME DIFFERENCE WHEN IT COMES TO NONSTANDARD TEXT WITHIN THE REVIEWS THEMSELVES
-- DATA CLEANING IS TOUGH HERE SINCE IT WOULD NULL A LOT OF REVIEWS UNNECASSARILY

-- LETS SEARCH FOR EMPTY REVIEWS
SELECT * FROM reviews
WHERE review LIKE '';
-- THERES QUIET A FEW, LETS NULL THESE

UPDATE reviews
SET review = NULL
WHERE review = '';

SELECT * FROM reviews
WHERE review LIKE '';
-- MUCH BETTER

SELECT * FROM review_details;
-- EDA LOOKS FINE ALTHOUGH IM STILL TROUBLED BY THE LACK OF A FUNCTIONING AUTHOR_ID AND 
-- MY INABILITY TO FILTER OUT REVIEWS WITH NON-STANDARD CHARACTERS

-- LETS RUN SOME INTERESTING QUERIES TO FOR VISULIZATION LATER