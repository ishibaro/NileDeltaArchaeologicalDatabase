# NileDeltaArchaeologicalDatabase
Triggers, Queries, PHP interface and everything about a temporal database that I have used for my PhD project about urban fluctuations in the Nile Delta

The database comprises the following functions, triggers, views, tables and sequences:

6+ tables, 2+ views, 2 sequences, 4 triggers and 4 functions.

TABLES>
EESsite
LonPer
MedPer
ShortPer
Governors
Temporality

VIEWS>
MedArcheoMode
MedPeriodTime

SEQUENCES>
EESsite_ID_seq
Temporality_Id_seq

4 table triggers for EESSites:
t_ishiba_create_geom
t_ishiba_update_xy
t_ishiba_populatewith_geom
t_ishiba_exceptions_add

4 trigger functions:
f_ishiba_create_geom()
f_ishiba_update_xy()
f_ishiba_populatewith_geom()
f_ishiba_exceptions_add()



