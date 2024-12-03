create type film_struct as (
							year INTEGER,
							film text,
							votes INTEGER,
							rating real,
							filmid TEXT)
							
create type quality_class AS
			enum('bad','average','good','star')

		
create table actors (
				actor text,
				actorid text,
				current_year INTEGER,
				films film_struct[],
				quality_class quality_class,
				is_active BOOLEAN,
				primary key(actorid, current_year)
						)