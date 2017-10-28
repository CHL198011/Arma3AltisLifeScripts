/*
* @File: fn_actualFuel.sqf
* @Author: Samuel "Pasarus" Jones
*
* Copyright (C) Samuel "Pasarus" Jones  - All Rights Reserved - https://redraw-gaming.co.uk
* Unauthorized copying of this file, via any medium is strictly prohibited
* without the express permission of Samuel "Pasarus" Jones
*/
params [
	["_vehicle", objNull, [objNull]],
	["_unit", objNull, [objNull]]
];

//--- bad params
if (isNull _vehicle || isNull _unit) exitWith {};
//--- no need to run
if !((driver _vehicle) isEqualTo _unit) exitWith {};

RR_inVehicle = true;

while {RR_inVehicle} do {
	_speed = speed _vehicle;
	if(!isNull objectParent _unit && ({effectiveCommander _vehicle == player}) && isEngineOn _vehicle) then {
		_speed = abs((speed _vehicle)) + 1; //Therefore there is a consumption at speed = 0.

		private _modifier = switch (true) do {
			case (_vehicle isKindOf "Air"): {220000 - (getMass _vehicle)};
			case (_vehicle isKindOf "Car"): {90000 - (getMass _vehicle)};
			case (_vehicle isKindOf "Boat" || _vehicle isKindOf "Submersible"): {(115000 - (getMass _vehicle))};
			default {0.01}; //Fuck you line 30 - Love Hontah.
		};
		
		private _consumption = _speed/_modifier;

		if(_consumption > 0.005) then {
			_consumption = 0.005;
		};

		_newFuel = (fuel _vehicle) - _consumption;
		_vehicle setFuel _newFuel;
	};
	sleep 3;
};
