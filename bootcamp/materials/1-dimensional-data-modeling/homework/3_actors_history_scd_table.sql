drop table actors_history_scd 

create table actors_history_scd
(
	actor text,
	actorid text,
	quality_class quality_class,
	is_active BOOLEAN,
	start_date INTEGER,
	end_date INTEGER,
	current_year INTEGER,
	PRIMARY KEY (actorid, start_date)
)
