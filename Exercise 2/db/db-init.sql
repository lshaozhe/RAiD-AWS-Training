CREATE schema IF NOT EXISTS "Users";

CREATE table IF NOT EXISTS  "Users"."users" (
    id      INT             NOT NULL,
    name    VARCHAR(255)    NOT NULL,
    email   VARCHAR(255)    NOT NULL,
    PRIMARY KEY (id)
);