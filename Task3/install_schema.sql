DROP TABLE IF EXISTS tour CASCADE;
DROP TABLE IF EXISTS hotel CASCADE;
DROP TABLE IF EXISTS city CASCADE;
DROP TABLE IF EXISTS country CASCADE;
DROP TABLE IF EXISTS currency CASCADE;
DROP TABLE IF EXISTS `language` CASCADE;

-- --------------------------------------------------------------------
CREATE TABLE `language` (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20) NOT NULL
);

-- --------------------------------------------------------------------
CREATE TABLE currency (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    rub_exch_rate DECIMAL
);

-- --------------------------------------------------------------------
CREATE TABLE country (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    currency BIGINT NOT NULL,
    `language` BIGINT NOT NULL,
    safety_index DECIMAL,

    CONSTRAINT fk_country_currency
        FOREIGN KEY (currency)
        REFERENCES currency(id),

    CONSTRAINT fk_country_language
        FOREIGN KEY (`language`)
        REFERENCES `language`(id)
);

-- --------------------------------------------------------------------
CREATE TABLE city (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    country BIGINT NOT null,

    CONSTRAINT fk_city_country
        FOREIGN KEY (country)
        REFERENCES country(id)
);

-- --------------------------------------------------------------------
CREATE TABLE hotel (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    raiting DECIMAL,
    price DECIMAL,
    description VARCHAR(200),
    address VARCHAR(80) NOT NULL,
    city BIGINT NOT null,

    CONSTRAINT fk_hotel_city
        FOREIGN KEY (city)
        REFERENCES city(id)
);

-- --------------------------------------------------------------------
CREATE TABLE tour (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    price DECIMAL,
    raiting DECIMAL,
    description VARCHAR(200),
    city BIGINT NOT null,

    CONSTRAINT fk_tour_city
        FOREIGN KEY (city)
        REFERENCES city(id)
);
