/* DB views for viewing and debugging trip-level data e.g. in QGIS */

-- set your table names here
\set prefix						'ttc_'

\set stops_table				:prefix'stops'
\set stop_times_table		:prefix'stop_times'
\set directions_table		:prefix'directions'

\set stop_times_view			:prefix'stop_times_view'
\set direction_stops_view	:prefix'direction_stops_view'


-- Adds geometry to stop_times table

DROP VIEW IF EXISTS :stop_times_view;
CREATE OR REPLACE VIEW :stop_times_view AS 
SELECT 
	st.stop_uid,
	st.trip_id,
	st.stop_sequence,
	st.etime,
	s.stop_name,
	s.stop_code,
	s.report_time,
	s.the_geom
FROM :stop_times_table AS st
JOIN :stops_table AS s 
	ON s.uid = st.stop_uid;


-- Gives sets of stops with geometry from the directions table

DROP VIEW IF EXISTS :direction_stops_view;
CREATE OR REPLACE VIEW :direction_stops_view AS 
SELECT 
	row_number() OVER () AS uid,
	d.direction_id,
	a.stop AS stop_id,
	a.seq AS stop_sequence,
	s.uid AS stop_uid,
	s.stop_code,
	s.stop_name,
	s.the_geom,
	d.report_time
FROM :directions_table AS d, unnest(d.stops) WITH ORDINALITY a(stop, seq)
JOIN :stops_table AS s ON s.stop_id = a.stop;
