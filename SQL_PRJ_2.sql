-- The following questions  are based on 'IG_CLONE' database. 

-- Question1 We want to reward the user who has been around the longest, Find the 5 oldest users.
SELECT * FROM USERS;
SELECT USERNAME,CREATED_AT FROM USERS
ORDER BY CREATED_AT
LIMIT 5;

-- Question 2 To understand when to run the ad campaign, figure out the day of the week most users register on?
SELECT DAYNAME(CREATED_AT) DAYNAME, COUNT(DAYNAME(CREATED_AT)) AS NO_OF_DAYS 
FROM USERS
GROUP BY DAYNAME(CREATED_AT)
ORDER BY NO_OF_DAYS DESC
LIMIT 2;

SELECT * FROM (SELECT DAYNAME(CREATED_AT)AS DAYNAME, COUNT(DAYNAME(CREATED_AT)) AS NO_OF_DAYS,
DENSE_RANK() OVER (ORDER BY COUNT(DAYNAME(CREATED_AT)) DESC) AS RNK
FROM USERS
GROUP BY DAYNAME(CREATED_AT)) a
WHERE RNK = 1;	
	
-- Question 3 To target inactive users in an email ad campaign, find the users who have never posted a photo.
SELECT ID,USERNAME                                        -- USING SUBQUERIES
FROM USERS 
WHERE ID NOT IN (SELECT USER_ID FROM PHOTOS);    

SELECT USERS.ID ,USERNAME 
FROM USERS                      -- USING LEFT JOIN
LEFT JOIN PHOTOS
ON USERS.ID = PHOTOS.USER_ID
WHERE PHOTOS.ID IS NULL;					     

-- Question 4. Suppose you are running a contest to find out who got the most likes on a photo. Find out who won?
SELECT * 
FROM LIKES;

SELECT USERNAME,USERS.ID 
FROM USERS 
INNER JOIN (SELECT  ID ,USER_ID 
FROM PHOTOS INNER JOIN  (SELECT COUNT(USER_ID),PHOTO_ID 
FROM LIKES
GROUP BY PHOTO_ID 
ORDER BY COUNT(USER_ID) DESC LIMIT 1) AS S
ON PHOTOS.ID = S.PHOTO_ID ) AS SS
ON USERS.ID = SS.USER_ID;

-- Question 5. The investors want to know how many times the average user posts. 

SELECT SUM(CT)/(SELECT COUNT(DISTINCT USER_ID) USER_COUNT FROM PHOTOS) AS AVERAGE_POSTS 
FROM
(SELECT USER_ID,COUNT(ID) CT 
FROM PHOTOS
GROUP BY USER_ID ORDER BY COUNT(ID) DESC) AS S;

-- Question 6. A brand wants to know which hash tag to use on a post, and find the top 5 most used hash tags.
SELECT * 
FROM PHOTO_TAGS;

SELECT * 
FROM TAGS;

SELECT  TAG_NAME,COUNT(TAG_NAME) 
FROM PHOTO_TAGS PT
INNER JOIN TAGS T
ON T.ID = PT.TAG_ID
GROUP BY TAG_NAME
ORDER BY COUNT(TAG_NAME) DESC LIMIT 1;

-- Question 7. To find out if there are bots, find users who have liked every single photo on the site.
SELECT S.USER_ID,USERNAME 
FROM 
(SELECT USER_ID,COUNT(PHOTO_ID) AS CT 
FROM LIKES
GROUP BY USER_ID
)AS S
INNER JOIN USERS ON USERS.ID = S.USER_ID
WHERE CT = (SELECT COUNT(ID) FROM PHOTOS);

-- Question 8. To know who the celebrities are, find users who have never commented on a photo.

SELECT USERNAME,ID 
FROM USERS 
WHERE ID NOT IN
(SELECT USER_ID FROM COMMENTS);	

-- Question 9. Now it's time to find both of them together, find the users who have never commented on any photo or have commented on every photo.

SELECT USERNAME,ID ,(select count(photo_id) from comments where comments.user_id = users.id),CASE WHEN ID IN (SELECT ID  FROM USERS WHERE ID NOT IN
(SELECT USER_ID FROM COMMENTS)) THEN   "NOT COMMENTED ON ANY PHOTO  #CELEBRETIES"
WHEN ID IN (SELECT ID  FROM USERS U 
INNER JOIN
(SELECT USER_ID ,COUNT(PHOTO_ID) CT FROM COMMENTS
GROUP BY USER_ID ORDER BY CT DESC ) S
ON S.USER_ID = U.ID
WHERE CT = (SELECT COUNT(ID) FROM PHOTOS))  THEN "COMMENTED ON EVERY PHOTO  #BOT"
ELSE "COMMENTED ON FEW PHOTOS  #COMMON_USERS"
END AS COMMENT FROM USERS
ORDER BY COMMENT;

SELECT USERNAME ,ID  FROM USERS WHERE ID NOT IN
(SELECT USER_ID FROM COMMENTS);  

SELECT USERNAME ,ID FROM USERS U 
INNER JOIN
(SELECT USER_ID ,COUNT(PHOTO_ID) CT FROM COMMENTS
GROUP BY USER_ID )AS S
ON S.USER_ID = U.ID
WHERE CT = (SELECT COUNT(ID) FROM PHOTOS);
