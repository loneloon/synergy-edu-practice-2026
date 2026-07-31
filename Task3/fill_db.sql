BEGIN;

--------------------------------------------------------------------
INSERT INTO "language" (id, name) VALUES
(1, 'English'),
(2, 'French'),
(3, 'Japanese'),
(4, 'Spanish'),
(5, 'Italian');

--------------------------------------------------------------------
INSERT INTO currency (id, name, rub_exch_rate) VALUES
(1, 'USD', 92.50),
(2, 'EUR', 101.80),
(3, 'JPY', 0.63),
(4, 'MXN', 5.45),
(5, 'CAD', 68.10);

--------------------------------------------------------------------
INSERT INTO country (id, name, currency, "language", safety_index) VALUES
(1, 'USA',     1, 1, 7.6),
(2, 'France',  2, 2, 7.8),
(3, 'Japan',   3, 3, 9.6),
(4, 'Mexico',  4, 4, 6.3),
(5, 'Canada',  5, 1, 9.2);

--------------------------------------------------------------------
INSERT INTO city (id, name, country) VALUES
-- USA
(1, 'New York',     1),
(2, 'Los Angeles',  1),
(3, 'Miami',        1),
(4, 'Las Vegas',    1),

-- France
(5, 'Paris',        2),
(6, 'Nice',         2),
(7, 'Lyon',         2),
(8, 'Cannes',       2),

-- Japan
(9,  'Tokyo',       3),
(10, 'Kyoto',       3),
(11, 'Osaka',       3),
(12, 'Sapporo',     3),

-- Mexico
(13, 'Cancun',      4),
(14, 'Mexico City', 4),
(15, 'Tulum',       4),
(16, 'Guadalajara', 4),

-- Canada
(17, 'Toronto',     5),
(18, 'Vancouver',   5),
(19, 'Montreal',    5),
(20, 'Calgary',     5);

--------------------------------------------------------------------
INSERT INTO hotel
(name, raiting, price, description, address, city)
VALUES
('Central Plaza',     4.8, 220, 'Luxury hotel in downtown area.',                    '12 Main St',          1),
('Hudson Suites',     4.5, 170, 'Modern hotel near Central Park.',                   '88 Hudson Ave',       1),
('Pacific Resort',    4.7, 260, 'Ocean view with rooftop pool.',                     '41 Ocean Dr',         2),
('Sunset Lodge',      4.2, 145, 'Comfortable stay close to beaches.',                '15 Sunset Blvd',      2),
('Palm Beach Inn',    4.4, 180, 'Family-friendly hotel with pool.',                  '7 Palm Ave',          3),
('Neon Palace',       4.6, 210, 'Casino hotel with entertainment.',                  '1 Strip Blvd',        4),
('Eiffel View',       4.9, 295, 'Elegant rooms overlooking the city.',              '9 Rue Victor',        5),
('Seaside Belle',     4.3, 185, 'Mediterranean style boutique hotel.',               '18 Beach Rd',         6),
('Lyon Comfort',      4.1, 130, 'Business hotel near station.',                      '25 Central Sq',       7),
('Riviera Grand',     4.8, 275, 'Premium hotel with private beach.',                 '3 Riviera Ave',       8),
('Sakura Stay',       4.9, 240, 'Traditional luxury with modern comfort.',           '10 Sakura St',        9),
('Kyoto Garden',      4.7, 210, 'Quiet ryokan-inspired hotel.',                      '44 Temple Rd',       10),
('Osaka Bay',         4.4, 175, 'Close to shopping and nightlife.',                  '5 Harbor St',        11),
('Snow Peak',         4.5, 190, 'Cozy winter resort.',                               '99 Mountain Rd',     12),
('Caribe Resort',     4.6, 215, 'Beachfront all-inclusive hotel.',                   '22 Coral Ave',       13),
('Historic Suites',   4.2, 155, 'Classic hotel in historic district.',               '6 Reforma Ave',      14),
('Maya Escape',       4.8, 260, 'Eco-resort near the coast.',                        '11 Jungle Rd',       15),
('Maple Grand',       4.7, 205, 'Upscale hotel in financial district.',              '101 King St',        17),
('Harbor Lights',     4.8, 235, 'Waterfront hotel with mountain views.',             '55 Harbor Rd',       18),
('Northern Comfort',  4.4, 170, 'Modern hotel with spacious rooms.',                 '8 River Ave',        19);

--------------------------------------------------------------------
INSERT INTO tour
(name, price, raiting, description, city)
VALUES
('City Highlights',   60, 4.7, 'Guided tour of famous landmarks.',                     1),
('Broadway Night',    95, 4.8, 'Evening show and city walk.',                           1),
('Hollywood Tour',    85, 4.6, 'Explore famous movie locations.',                       2),
('Beach Explorer',    45, 4.3, 'Relaxing coastal sightseeing.',                         3),
('Vegas Lights',      70, 4.5, 'Night tour of the Las Vegas Strip.',                    4),

('Paris Classic',     80, 4.9, 'Visit iconic monuments and museums.',                  5),
('French Riviera',    90, 4.7, 'Scenic coastal drive and beaches.',                    6),
('Wine Experience',   75, 4.5, 'Regional wine tasting adventure.',                     7),
('Film Festival',     65, 4.4, 'Walking tour of Cannes highlights.',                   8),

('Tokyo Lights',      85, 4.9, 'Explore modern Tokyo after sunset.',                   9),
('Temple Walk',       55, 4.8, 'Historic temples and gardens.',                       10),
('Food Adventure',    68, 4.7, 'Taste famous Osaka street food.',                     11),
('Snow Adventure',    95, 4.6, 'Winter activities outside the city.',                 12),

('Reef Snorkel',     110, 4.8, 'Snorkeling in crystal clear waters.',                 13),
('History Walk',      40, 4.3, 'Historic city center exploration.',                   14),
('Mayan Ruins',       98, 4.9, 'Ancient archaeological sites.',                       15),

('City Discovery',    55, 4.5, 'Visit major attractions and parks.',                  17),
('Mountain Escape',   90, 4.8, 'Day trip into nearby mountains.',                      18),
('Old Montreal',      50, 4.6, 'Walking tour through historic streets.',              19),
('Rocky Explorer',   120, 4.9, 'Nature excursion into the Rockies.',                  20);

COMMIT;
