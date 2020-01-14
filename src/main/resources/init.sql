drop table IF EXISTS users CASCADE;
drop table IF EXISTS bookings CASCADE;
-- drop table IF EXISTS all_audit CASCADE;
-- drop sequence IF EXISTS counter CASCADE;

create TABLE users(
	user_id SERIAL UNIQUE PRIMARY KEY,
	user_surname varchar(50) NOT NULL,
	user_firstname varchar(50) NOT NULL,
	user_email varchar(100) NOT NULL UNIQUE,
	user_password text NOT NULL,
	user_phone varchar(15) NOT NULL,
	user_country varchar(150) NOT NULL,
	user_postal_code_and_city varchar(150) NOT NULL,
	user_rest_of_address varchar(150) NOT NULL,
    user_number_of_recent_visits integer,
    user_sum_of_all_recent_booked_nights integer,
    user_role varchar(10) DEFAULT 'REGULAR',
    CONSTRAINT user_surname_not_empty CHECK (user_surname <> ''),
	CONSTRAINT user_firstname_not_empty CHECK (user_firstname <> ''),
	CONSTRAINT user_email_not_empty CHECK (user_email <> ''),
	CONSTRAINT user_password_not_empty CHECK (user_password <> ''),
	CONSTRAINT user_phone_not_empty CHECK (user_phone <> ''),
	CONSTRAINT user_country_not_empty CHECK (user_country <> ''),
	CONSTRAINT user_postal_code_and_city_not_empty CHECK (user_postal_code_and_city <> ''),
	CONSTRAINT user_rest_of_address_not_empty CHECK (user_rest_of_address <> ''),
    CONSTRAINT user_role_not_empty CHECK (user_role <> '')
);

create TABLE bookings(
	user_id integer,
    booking_arrival_date date NOT NULL, -- yyyy-mm-dd
    booking_number_of_nights integer NOT NULL,
    booking_number_of_apartmans_needed integer NOT NULL,
    booking_total_number_of_guests integer NOT NULL,
    booking_number_of_children integer,
    booking_agelist_of_children integer[],
    booking_arrival_hour integer,
    booking_leaving_hour integer,
	FOREIGN KEY(user_id) REFERENCES users(user_id),
	CONSTRAINT booking_arrival_date_from_current_only CHECK (booking_arrival_date >= CURRENT_DATE),
	CONSTRAINT booking_number_of_apartmans_needed_limit CHECK (booking_number_of_apartmans_needed >= 1 AND booking_number_of_apartmans_needed <= 3),
	CONSTRAINT booking_number_of_guests_limit CHECK (booking_total_number_of_guests >= 1 AND booking_total_number_of_guests <= 12),
	CONSTRAINT booking_number_of_children_limit CHECK (booking_number_of_children BETWEEN 0 AND 10),
	CONSTRAINT booking_arrival_hour_limit CHECK (booking_arrival_hour BETWEEN 14 AND 23),
	CONSTRAINT booking_leaving_hour_limit CHECK (booking_leaving_hour BETWEEN 8 AND 10)
);
---------------------------------------------------------


-- Triggers for number_of_recent_visits
CREATE OR REPLACE FUNCTION process_users_recent_visits_increase()
    RETURNS trigger AS
$func$
BEGIN
    UPDATE users
    SET user_number_of_recent_visits = user_number_of_recent_visits + 1
    WHERE users.user_id = new.user_id;
END;
$func$
LANGUAGE 'plpgsql';

CREATE TRIGGER users_recent_visits_increase
    AFTER INSERT
    ON bookings
    FOR EACH ROW
EXECUTE PROCEDURE process_users_recent_visits_increase();
---------------------------------------------------------

CREATE OR REPLACE FUNCTION process_users_recent_visits_decrease()
    RETURNS trigger AS
$func$
BEGIN
    UPDATE users
    SET user_number_of_recent_visits = user_number_of_recent_visits - 1
    WHERE users.user_id = new.user_id;
END;
$func$
    LANGUAGE 'plpgsql';

CREATE TRIGGER users_recent_visits_decrease
    AFTER DELETE
    ON bookings
    FOR EACH ROW
EXECUTE PROCEDURE process_users_recent_visits_decrease();
---------------------------------------------------------


-- Triggers for number_of_recent_booked_nights
CREATE OR REPLACE FUNCTION process_users_recent_booked_nights_add()
    RETURNS trigger AS
$func$
BEGIN
    UPDATE users
    SET user_sum_of_all_recent_booked_nights = user_sum_of_all_recent_booked_nights + new.booking_number_of_nights
    WHERE users.user_id = new.user_id;
END;
$func$
    LANGUAGE 'plpgsql';

CREATE TRIGGER users_recent_booked_nights_add
    AFTER INSERT
    ON bookings
    FOR EACH ROW
EXECUTE PROCEDURE process_users_recent_booked_nights_add();
---------------------------------------------------------

CREATE OR REPLACE FUNCTION process_users_recent_booked_nights_subtract()
    RETURNS trigger AS
$func$
BEGIN
    UPDATE users
    SET user_sum_of_all_recent_booked_nights = user_sum_of_all_recent_booked_nights - new.booking_number_of_nights
    WHERE users.user_id = new.user_id;
END;
$func$
    LANGUAGE 'plpgsql';

CREATE TRIGGER users_recent_booked_nights_subtract
    AFTER DELETE
    ON bookings
    FOR EACH ROW
EXECUTE PROCEDURE process_users_recent_booked_nights_subtract();

---------------------------------------------------------
/*

create sequence counter AS integer INCREMENT BY 1 START 1;

create or replace function process_audit() RETURNS trigger AS '
    BEGIN
        IF (TG_OP = ''DELETE'') THEN
            INSERT INTO all_audit
                VALUES(nextval(''counter''),''DELETE'', TG_TABLE_NAME, OLD.user_id, now());
        ELSIF (TG_OP = ''UPDATE'') THEN
            INSERT INTO all_audit
                VALUES(nextval(''counter''), ''UPDATE'', TG_TABLE_NAME, OLD.user_id, now());
        ELSIF (TG_OP = ''INSERT'') THEN
            INSERT INTO all_audit
                VALUES(nextval(''counter''), ''INSERT'', TG_TABLE_NAME, NEW.user_id, now());
        END IF;
        RETURN NEW;
    END;
' LANGUAGE plpgsql;

create or replace function check_task_id() RETURNS trigger AS '
    BEGIN
        IF (TG_OP = ''INSERT'') THEN
            DECLARE
                id integer;
            BEGIN
                FOR id IN SELECT task_id FROM schedule_tasks WHERE schedule_id = NEW.schedule_id LOOP
                IF id = NEW.task_id THEN
                RAISE EXCEPTION ''Task already exists in schedule!'';
                END IF;
                END LOOP;
			END;
        END IF;
        RETURN NEW;
    END;
' LANGUAGE plpgsql;


create trigger users_audit_ins
    after insert on users
    for each row EXECUTE procedure process_audit();
create trigger users_audit_upd
    after update on users
    for each row EXECUTE procedure process_audit();
create trigger users_audit_del
    after delete on users
    for each row EXECUTE procedure process_audit();

create trigger schedule_task_check
    before insert on schedule_tasks
    for each row EXECUTE procedure check_task_id();


create or replace function check_schedule_coloumn() RETURNS trigger AS '
    BEGIN
        IF (TG_OP = ''INSERT'') THEN
            DECLARE
                rows integer;
            BEGIN
				SELECT schedule_duration INTO rows FROM schedules WHERE schedule_id = NEW.schedule_id;
                IF rows  < NEW.column_number THEN
                	RAISE EXCEPTION ''Task could not be added to schedule, because the row number is invalid '';
                END IF;
			END;
        END IF;
        RETURN NEW;
    END;
' LANGUAGE plpgsql;

create trigger check_schedule_coloumns
    before insert on schedule_tasks
    for each row EXECUTE procedure check_schedule_coloumn();

create or replace function check_schedule_coloumn() RETURNS trigger AS '
    BEGIN
        IF (TG_OP = ''INSERT'') THEN
            DECLARE
                task_start_var integer;
				task_end_var integer;
				task_start integer;
				task_end integer;
				col_num integer;
            BEGIN
				SELECT tasks.task_start, tasks.task_end INTO task_start, task_end FROM schedule_tasks JOIN tasks ON tasks.task_id = NEW.task_id;
                FOR col_num, task_start_var, task_end_var IN SELECT column_number, tasks.task_start, tasks.task_end FROM schedule_tasks JOIN tasks ON schedule_tasks.task_id = tasks.task_id WHERE schedule_id = NEW.schedule_id LOOP
	                IF task_start_var = task_start OR task_end_var = task_end AND col_num = NEW.column_number THEN
	                	RAISE EXCEPTION ''There is already a task in the choosen timeframe and day'';
	                END IF;

	                IF task_start_var < task_start AND task_start < task_end_var AND col_num = NEW.column_number THEN
	                	RAISE EXCEPTION ''There is already a task in the choosen timeframe and day'';
	                END IF;

					IF task_end_var > task_end AND task_end > task_start_var AND col_num = NEW.column_number THEN
	                	RAISE EXCEPTION ''There is already a task in the choosen timeframe and day'';
	                END IF;

                END LOOP;
			END;
        END IF;
        RETURN NEW;
    END;
' LANGUAGE plpgsql;


create trigger check_task_duplicate_inschedules
    before insert on schedule_tasks
    for each row EXECUTE procedure check_schedule_coloumn();
*/


-- Users
INSERT INTO users(user_surname, user_firstname, user_email, user_password, user_phone, user_country, user_postal_code_and_city, user_rest_of_address) VALUES('Próba', 'Imre', 'user1@email.com', '1000:f7a75b353bbcc8748e15d73a5bbf8d83:6352231353e2fa92fb254ab9f680ef269846fb16e7ff4bdcc1b4f315445e23c3606727b445f5d054641ac80c7f5e06b9b390689c1bd3bcf66654b174796d4348', '+36703214587', 'Hungary', '2654 Bábolna', 'Kossuth L. u. 5');

INSERT INTO users(user_surname, user_firstname, user_email, user_password, user_phone, user_country, user_postal_code_and_city, user_rest_of_address) VALUES
('Teszt', 'Elek', 'user2@email.com', '1000:c2aecee7ec5441e0b9be358a2179a2a3:78bebd7d48366740c704db62d1344620f3ae50fd029390b32890dd410d6ed2867ce74826d95627dbbc7dd720be79ed8091f2df534fee9773c96ca89ba680c747', '+36306985412', 'Hungary', '2489 Vác', 'Fő út 325');

INSERT INTO users(user_surname, user_firstname, user_email, user_password, user_phone, user_country, user_postal_code_and_city, user_rest_of_address, user_role) VALUES
('admin', 'admin', 'admin.admin.hu', '1000:5faf472fa87efaff161590ab1668669d:5f0bb5d45e8a9014a3335d4663aa1cec05c29bbfb29b9d8bae7f5a8a77c9ab4acaa56966a595aadf1d0480cc9b1a7f010a0eeafbc67d7fabf85de4924d80699e', '+36306985412', 'Hungary', '2489 Vác', 'Fő út 325', 'ADMIN');

-- Bookings
INSERT INTO bookings(user_id, booking_arrival_date, booking_number_of_nights, booking_number_of_apartmans_needed, booking_total_number_of_guests, booking_number_of_children, booking_agelist_of_children, booking_arrival_hour, booking_leaving_hour) VALUES(1, '2020-04-10', 7, 2, 6, 4, array[1, 3, 4, 6], 15, 10);

INSERT INTO bookings(user_id, booking_arrival_date, booking_number_of_nights, booking_number_of_apartmans_needed, booking_total_number_of_guests, booking_arrival_hour) VALUES(2, '2020-04-14', 4, 1, 2, 18);
