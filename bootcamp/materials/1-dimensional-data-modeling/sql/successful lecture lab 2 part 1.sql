

create table players_scd
(
	player_name text,
	scoring_class scoring_class,
	is_active BOO
	LEAN,
	start_season INTEGER,
	end_season INTEGER,
	current_season INTEGER,
	PRIMARY KEY (player_name, start_season)
);


select * from players_scd;


insert into players_scd	
	with with_previous as (
select 
	player_name,
	current_season,
	scoring_class,
	is_active,
	LAG(scoring_class, 1) over (partition by player_name order by current_season) as previous_scoring_class,
	LAG(is_active, 1) over (partition by player_name order by current_season) as previous_is_active
	
from players
where current_season <=2021
),

	with_indicators as (
select *,
		case 
			when scoring_class <> previous_scoring_class then 1
			when is_active <> previous_is_active then 1
			else 0
		end as change_indicator
		
from with_previous
),

	with_streaks as (
select *,
		SUM (change_indicator)
			over (partition by player_name order by current_season) as streak_identifier			
from with_indicators
)


	select player_name,
			scoring_class,
			is_active,
			MIN(current_season) as start_season,
			MAX (current_season) as end_season,
			2021 as current_season
	from with_streaks
	group by player_name, streak_identifier, is_active, scoring_class
	order by player_name, streak_identifier