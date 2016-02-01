Filename		Function					Comments
==================================================================================
dBm2V			Converting dBm to voltage
HystericCurrent		Getting currents from dc hysteresis 
FindIcIr		Finds Ic and Ir as a function of VG		Looks for min/max of derivative of V vs I
GetStatsFromJJSwitch	Gives avg counts per time bin of data from
			JJ_switch for a user input time interval
CombineJJSwitchData	Merges 2 outputs for JJ_switch into one struct	Be sure Vthresh, VG, Ib, and Ireset are the same 