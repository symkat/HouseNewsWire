CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE person (
    id                          serial          PRIMARY KEY,
    name                        text            not null,
    email                       citext          not null unique,
    is_enabled                  boolean         not null default true,
    created_at                  timestamptz     not null default current_timestamp
);

CREATE TABLE auth_password (
    person_id                   int             not null unique references person(id),
    password                    text            not null,
    salt                        text            not null,
    updated_at                  timestamptz     not null default current_timestamp,
    created_at                  timestamptz     not null default current_timestamp
);

CREATE TABLE message (
    id                          serial          PRIMARY KEY,
    author_id                   int             not null references person(id),
    content                     text            not null,
    created_at                  timestamptz     not null default current_timestamp
);

CREATE TABLE message_read (
    message_id                  int             not null references message(id),
    person_id                   int             not null references person(id),
    is_read                     boolean         not null default true,
    created_at                  timestamptz     not null default current_timestamp,
    PRIMARY KEY (message_id, person_id)    
);

