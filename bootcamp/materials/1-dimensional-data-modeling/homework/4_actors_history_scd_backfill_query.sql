insert into actors_history_scd
with with_previous as (
select 
	actor,
	actorid,
	current_year,
	quality_class,
	is_active,
	LAG(quality_class, 1) over (partition by actor,actorid order by current_year) as previous_quality_class,
	LAG(is_active, 1) over (partition by actor,actorid order by current_year) as previous_is_active
	
from actors
where current_year <=2020
),

	with_indicators as (
select *,
		case 
			when quality_class <> quality_class then 1
			when is_active <> previous_is_active then 1
			else 0
		end as change_indicator
		
from with_previous
),

	with_streaks as (
select *,
		SUM (change_indicator)
			over (partition by actor,actorid order by current_year) as streak_identifier			
from with_indicators
)


	select actor,
			actorid,
			quality_class,
			is_active,
			MIN(current_year) as start_date,
			MAX (current_year) as end_date,
			2020 as current_year
	from with_streaks
	group by actor,actorid, streak_identifier, is_active, quality_class
	order by actor,actorid, streak_identifier
	