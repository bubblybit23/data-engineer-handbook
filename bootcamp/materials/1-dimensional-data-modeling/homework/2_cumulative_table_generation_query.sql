insert into actors

with years as(
	select *	
	from GENERATE_SERIES(1970,2021) as current_year		
),

	first_appearances as(
			select actor,actorid, MIN(year) as first_appear
			from actor_films af
			group by actor, actorid
),
	actors_and_years as (
			select *
			from first_appearances fa
			join years y
				on fa.first_appear <= y.current_year
),


	windowed as (
	
   SELECT DISTINCT
        aay.actor, aay.actorid, aay.current_year
        , af.year
        , ARRAY_REMOVE(
            ARRAY_AGG(
                CASE
                    WHEN af.year IS NOT NULL
                    THEN
                     ROW(
                         af.year,
                        af.film,
                        af.votes,
                        af.rating,
                        af.filmid)::film_struct
                END
                )
            OVER (PARTITION BY aay.actor, aay.actorid ORDER BY COALESCE(aay.current_year, af.year)),
           NULL
        )  AS films
        , AVG(rating) OVER (PARTITION BY aay.actor, aay.actorid ORDER BY COALESCE(aay.current_year, af.year)) AS avg_rating
    FROM actors_and_years aay
    LEFT JOIN actor_films af
        ON aay.actor = af.actor
        AND aay.actorid = af.actorid
        AND aay.current_year = af.year
)

select 
	actor, actorid, current_year,films,
	case 
		WHEN avg_rating > 8 THEN 'star'
        WHEN avg_rating > 7 THEN 'good'
        WHEN avg_rating > 6 THEN 'average'
        ELSE 'bad'
    END::quality_class AS quality_class,
    (films[CARDINALITY(films)]::film_struct).year = current_year AS is_active
    
from windowed w


