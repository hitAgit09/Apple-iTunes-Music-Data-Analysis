-- =====================================================
-- 1️⃣ EMPLOYEE
-- =====================================================
CREATE TABLE employee (
    employee_id INT PRIMARY KEY,
    last_name VARCHAR(100),
    first_name VARCHAR(100),
    title VARCHAR(150),
    reports_to INT NULL,
    levels VARCHAR(50),
    birthdate TIMESTAMP,
    hire_date TIMESTAMP,
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    phone VARCHAR(50),
    fax VARCHAR(50),
    email VARCHAR(150),
    CONSTRAINT fk_employee_reports
        FOREIGN KEY (reports_to)
        REFERENCES employee(employee_id)
);

-- =====================================================
-- 2️⃣ CUSTOMER
-- =====================================================
CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    company VARCHAR(255),
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    phone VARCHAR(50),
    fax VARCHAR(50),
    email VARCHAR(150),
    support_rep_id INT,
    CONSTRAINT fk_customer_employee
        FOREIGN KEY (support_rep_id)
        REFERENCES employee(employee_id)
);

-- =====================================================
-- 3️⃣ ARTIST
-- =====================================================
CREATE TABLE artist (
    artist_id INT PRIMARY KEY,
    name VARCHAR(255)
);

-- =====================================================
-- 4️⃣ ALBUM
-- =====================================================
CREATE TABLE album (
    album_id INT PRIMARY KEY,
    title VARCHAR(255),
    artist_id INT,
    CONSTRAINT fk_album_artist
        FOREIGN KEY (artist_id)
        REFERENCES artist(artist_id)
);

-- =====================================================
-- 5️⃣ GENRE
-- =====================================================
CREATE TABLE genre (
    genre_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- =====================================================
-- 6️⃣ MEDIA_TYPE
-- =====================================================
CREATE TABLE media_type (
    media_type_id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- =====================================================
-- 7️⃣ TRACK
-- =====================================================
CREATE TABLE track (
    track_id INT PRIMARY KEY,
    name VARCHAR(255),
    album_id INT,
    media_type_id INT,
    genre_id INT,
    composer VARCHAR(255),
    milliseconds INT,
    bytes INT,
    unit_price NUMERIC(10,2),
    CONSTRAINT fk_track_album
        FOREIGN KEY (album_id)
        REFERENCES album(album_id),
    CONSTRAINT fk_track_media
        FOREIGN KEY (media_type_id)
        REFERENCES media_type(media_type_id),
    CONSTRAINT fk_track_genre
        FOREIGN KEY (genre_id)
        REFERENCES genre(genre_id)
);

-- =====================================================
-- 8️⃣ PLAYLIST
-- =====================================================
CREATE TABLE playlist (
    playlist_id INT PRIMARY KEY,
    name VARCHAR(255)
);

-- =====================================================
-- 9️⃣ PLAYLIST_TRACK
-- =====================================================
CREATE TABLE playlist_track (
    playlist_id INT,
    track_id INT,
    PRIMARY KEY (playlist_id, track_id),
    CONSTRAINT fk_playlisttrack_playlist
        FOREIGN KEY (playlist_id)
        REFERENCES playlist(playlist_id),
    CONSTRAINT fk_playlisttrack_track
        FOREIGN KEY (track_id)
        REFERENCES track(track_id)
);

-- =====================================================
-- 🔟 INVOICE
-- =====================================================
CREATE TABLE invoice (
    invoice_id INT PRIMARY KEY,
    customer_id INT,
    invoice_date TIMESTAMP,
    billing_address VARCHAR(255),
    billing_city VARCHAR(100),
    billing_state VARCHAR(100),
    billing_country VARCHAR(100),
    billing_postal_code VARCHAR(20),
    total NUMERIC(10,2),
    CONSTRAINT fk_invoice_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id)
);

-- =====================================================
-- 1️⃣1️⃣ INVOICE_LINE
-- =====================================================
CREATE TABLE invoice_line (
    invoice_line_id INT PRIMARY KEY,
    invoice_id INT,
    track_id INT,
    unit_price NUMERIC(10,2),
    quantity INT,
    CONSTRAINT fk_invoiceline_invoice
        FOREIGN KEY (invoice_id)
        REFERENCES invoice(invoice_id),
    CONSTRAINT fk_invoiceline_track
        FOREIGN KEY (track_id)
        REFERENCES track(track_id)
);

TRUNCATE TABLE invoice_line CASCADE;
TRUNCATE TABLE invoice CASCADE;
TRUNCATE TABLE playlist_track CASCADE;
TRUNCATE TABLE playlist CASCADE;
TRUNCATE TABLE track CASCADE;
TRUNCATE TABLE album CASCADE;
TRUNCATE TABLE artist CASCADE;
TRUNCATE TABLE media_type CASCADE;
TRUNCATE TABLE genre CASCADE;
TRUNCATE TABLE customer CASCADE;
TRUNCATE TABLE employee CASCADE;

SELECT COUNT(*) FROM employee;        -- 9
SELECT COUNT(*) FROM customer;        -- 59
SELECT COUNT(*) FROM artist;          -- 275
SELECT COUNT(*) FROM album;           -- 347
SELECT COUNT(*) FROM genre;           -- 3503
SELECT COUNT(*) FROM playlist_track;  -- 8715
SELECT COUNT(*) FROM invoice;         -- 614
SELECT COUNT(*) FROM invoice_line;    -- 4757

/* =========================================================
   Q1. Who is the senior most employee based on job title?
   Insight:
   The employee with the highest level represents senior leadership
   and is likely responsible for overseeing sales operations and strategy.
   ========================================================= */
SELECT first_name,
       last_name,
       title,
       levels
FROM employee
ORDER BY levels DESC
LIMIT 1;


/* =========================================================
   Q2. Which countries have the most Invoices?
   Insight:
   Countries with the highest invoice counts indicate strong
   customer activity and represent high-engagement markets.
   ========================================================= */
SELECT billing_country,
       COUNT(*) AS total_invoices
FROM invoice
GROUP BY billing_country
ORDER BY total_invoices DESC;


/* =========================================================
   Q3. What are top 3 values of total invoice?
   Insight:
   The highest invoice totals highlight premium purchases and
   high-spending customers who contribute significantly to revenue.
   ========================================================= */
SELECT invoice_id,
       total
FROM invoice
ORDER BY total DESC
LIMIT 3;


/* =========================================================
   Q4. Which city has the best customers?
   Insight:
   The city with the highest total revenue is the most profitable
   and ideal for targeted promotions or music festivals.
   ========================================================= */
SELECT billing_city,
       SUM(total) AS total_revenue
FROM invoice
GROUP BY billing_city
ORDER BY total_revenue DESC
LIMIT 1;


/* =========================================================
   Q5. Who is the best customer?
   Insight:
   The highest spending customer contributes the most revenue,
   indicating strong loyalty and purchasing power.
   ========================================================= */
SELECT c.customer_id,
       c.first_name,
       c.last_name,
       SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 1;


/* =========================================================
   Q6. Rock Music listeners ordered by email
   Insight:
   Rock genre has a strong listener base across regions,
   showing consistent purchasing behavior.
   ========================================================= */
SELECT DISTINCT c.email,
       c.first_name,
       c.last_name,
       g.name AS genre
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email;


/* =========================================================
   Q7. Top 10 artists who wrote most Rock music
   Insight:
   These artists dominate the Rock catalog and likely contribute
   heavily to Rock genre revenue.
   ========================================================= */
SELECT ar.name AS artist_name,
       COUNT(t.track_id) AS track_count
FROM artist ar
JOIN album al ON ar.artist_id = al.artist_id
JOIN track t ON al.album_id = t.album_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY ar.artist_id
ORDER BY track_count DESC
LIMIT 10;


/* =========================================================
   Q8. Tracks longer than average length
   Insight:
   Longer tracks may represent premium or extended versions
   appealing to dedicated listeners.
   ========================================================= */
SELECT name,
       milliseconds
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds) FROM track
)
ORDER BY milliseconds DESC;


/* =========================================================
   Q9. Amount spent by each customer on artists
   Insight:
   Customer spending varies by artist, reflecting personalized
   music preferences and targeted marketing opportunities.
   ========================================================= */
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       ar.name AS artist_name,
       SUM(il.unit_price * il.quantity) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
GROUP BY c.customer_id, ar.artist_id
ORDER BY total_spent DESC;


/* =========================================================
   Q10. Most popular Genre per country (handle ties)
   Insight:
   Each country has a dominant genre preference,
   showing regional taste differences in music consumption.
   ========================================================= */
WITH genre_sales AS (
    SELECT i.billing_country,
           g.name AS genre,
           COUNT(il.quantity) AS purchases
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY i.billing_country, g.name
),
ranked_genres AS (
    SELECT *,
           RANK() OVER (PARTITION BY billing_country ORDER BY purchases DESC) AS rnk
    FROM genre_sales
)
SELECT billing_country,
       genre,
       purchases
FROM ranked_genres
WHERE rnk = 1
ORDER BY billing_country;


/* =========================================================
   Q11. Top customer per country (handle ties)
   Insight:
   High-value customers drive revenue within each country.
   Multiple customers may share top position in some regions.
   ========================================================= */
WITH customer_totals AS (
    SELECT i.billing_country,
           c.customer_id,
           c.first_name || ' ' || c.last_name AS customer_name,
           SUM(i.total) AS total_spent
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY i.billing_country, c.customer_id
),
ranked_customers AS (
    SELECT *,
           RANK() OVER (PARTITION BY billing_country ORDER BY total_spent DESC) AS rnk
    FROM customer_totals
)
SELECT billing_country,
       customer_name,
       total_spent
FROM ranked_customers
WHERE rnk = 1
ORDER BY billing_country;


/* =========================================================
   Q12. Most popular artists (by revenue)
   Insight:
   Top revenue-generating artists are key contributors
   to overall music sales and profitability.
   ========================================================= */
SELECT ar.name,
       SUM(il.unit_price * il.quantity) AS total_revenue
FROM artist ar
JOIN album al ON ar.artist_id = al.artist_id
JOIN track t ON al.album_id = t.album_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY ar.artist_id
ORDER BY total_revenue DESC;


/* =========================================================
   Q13. Most popular song
   Insight:
   The song with highest purchases represents peak demand
   and strong customer engagement.
   ========================================================= */
SELECT t.name,
       SUM(il.quantity) AS total_purchases
FROM track t
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY t.track_id
ORDER BY total_purchases DESC
LIMIT 1;


/* =========================================================
   Q14. Average prices of different media types
   Insight:
   Media type pricing variations influence revenue strategy
   and product positioning.
   ========================================================= */
SELECT mt.name AS media_type,
       AVG(t.unit_price) AS average_price
FROM track t
JOIN media_type mt ON t.media_type_id = mt.media_type_id
GROUP BY mt.name
ORDER BY average_price DESC;


/* =========================================================
   Q15. Most popular countries for music purchases
   Insight:
   Countries with highest purchase volume represent
   strong and engaged music markets.
   ========================================================= */
SELECT i.billing_country,
       COUNT(il.invoice_line_id) AS total_purchases
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
GROUP BY i.billing_country
ORDER BY total_purchases DESC;

