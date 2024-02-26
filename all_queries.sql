-- Using the ERD above, formulate queries to satisfy the following questions. Do not include NULL values.:
-- (5 pts) What are the last names and emails of all customer who made purchased in the store?
-- (5 pts) What are the names of each albums and the artist who created it?
-- (10 pts) What are the total number of unique customers for each state, ordered alphabetically by state?
-- (10 pts) Which states have more than 10 unique customers customers?
-- (10 pts) What are the names of the artists who made an album containing the substring "symphony" in the album title?
-- (15 pts) What are the names of all artists who performed MPEG (video or audio) tracks in either the "Brazilian Music" or the "Grunge" playlists?
-- (20 pts) How many artists published at least 10 MPEG tracks?
-- (25 pts) What is the total length of each playlist in hours? List the playlist id and name of only those playlists that are longer than 2 hours, along with the length in hours rounded to two decimals.
-- (25 pts) Creative addition: Define a new meaningful query using at least three tables, and some window function. Explain clearly what your query achieves, and what the results mean

-- (5 pts) What are the last names and emails of all customer who made purchased in the store?
SELECT 
  c.FirstName,
  c.LastName
FROM customers AS c
WHERE c.CustomerId IN (
  SELECT CustomerId
  FROM invoices
);

-- (5 pts) What are the names of each albums and the artist who created it?
SELECT 
  alb.Title AS "Album Name",
  a.name AS "Artist Name"
FROM albums AS alb
  JOIN artists AS a ON alb.ArtistId = a.ArtistId;

-- (10 pts) What are the total number of unique customers for each state, ordered alphabetically by state?
SELECT 
  State,
  COUNT(CustomerId)
FROM customers
WHERE State IS NOT NULL
GROUP BY State
ORDER BY State ASC;

-- (10 pts) Which states have more than 10 unique customers customers?
SELECT 
  State,
  COUNT(CustomerId)
FROM customers
WHERE State IS NOT NULL
GROUP BY State
HAVING COUNT(CustomerId) > 10;

-- (10 pts) What are the names of the artists who made an album containing the substring "symphony" in the album title?
SELECT 
  art.Name,
  alb.Title
FROM artists as art
  INNER JOIN albums as alb USING(ArtistId)
WHERE alb.Title LIKE '%symphony%';

-- (15 pts) What are the names of all artists who performed MPEG (video or audio) tracks in either the "Brazilian Music" or the "Grunge" playlists?
SELECT DISTINCT 
  ar.Name AS "Artist Name"
FROM artists AS ar
  JOIN albums AS al ON ar.ArtistId = al.ArtistId
  JOIN tracks AS tr ON tr.AlbumId = al.AlbumId
  JOIN playlist_track AS pl_tr ON tr.TrackId = pl_tr.TrackId
WHERE pl_tr.PlaylistId IN (11, 16)
  AND tr.MediaTypeId IN (1, 3);

-- (20 pts) How many artists published at least 10 MPEG tracks?
SELECT DISTINCT 
  ar.Name,
  COUNT(tr.TrackId) as "Number of Tracks"
FROM artists AS ar
  JOIN albums AS al ON ar.ArtistId = al.ArtistId
  JOIN tracks AS tr ON tr.AlbumId = al.AlbumId
WHERE tr.MediaTypeId IN (1, 3)
GROUP BY ar.Name
HAVING COUNT(tr.TrackId) >= 10;

-- (25 pts) What is the total length of each playlist in hours? List the playlist id and name of only those playlists that are longer than 2 hours, along with the length in hours rounded to two decimals.

-- total length of each playlist
SELECT 
  pl.Name,
  ROUND(SUM(tr.Milliseconds) / 3600000.00, 2) AS "Hours"
FROM playlists AS pl
  JOIN playlist_track AS pl_tr ON pl_tr.PlaylistId = pl.PlaylistId
  JOIN tracks AS tr ON pl_tr.TrackId = tr.TrackId
GROUP BY pl.Name;
-- more than 2 hours
SELECT 
  pl.PlaylistId,
  pl.Name,
  ROUND(SUM(tr.Milliseconds) / 3600000.00, 2) AS "Hours"
FROM playlists AS pl
  JOIN playlist_track AS pl_tr ON pl_tr.PlaylistId = pl.PlaylistId
  JOIN tracks AS tr ON pl_tr.TrackId = tr.TrackId
GROUP BY pl.Name
HAVING SUM(tr.Milliseconds) > 7200000;

-- (25 pts) Creative addition: Define a new meaningful query using at least three tables, and some window function. Explain clearly what your query achieves, and what the results mean

-- customers, favorite genre, and total money spent by that customer
SELECT 
  c.FirstName AS "First Name", 
  c.LastName AS "Last Name",
  (
    SELECT gr.Name
    FROM genres AS gr
    JOIN tracks AS tr ON tr.GenreId = gr.GenreId
    JOIN invoice_items AS inv_it ON inv_it.TrackId = tr.TrackId
    WHERE inv_it.InvoiceId = inv.InvoiceId
    GROUP BY gr.GenreId
    ORDER BY COUNT(tr.TrackId) DESC
    LIMIT 1
  ) AS "Favorite Genre",
  SUM(inv.Total) AS "Total Money Spent"
FROM customers AS c
  JOIN invoices AS inv ON inv.CustomerId = c.CustomerId
  JOIN invoice_items AS inv_it ON inv.InvoiceId = inv_it.InvoiceId
  JOIN tracks AS tr ON tr.TrackId = inv_it.TrackId
GROUP BY c.CustomerId
ORDER BY SUM(inv.Total) DESC;