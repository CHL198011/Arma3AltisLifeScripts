/*
* @File: fn_destinationSelector.sqf
* @Author: Samuel "Pasarus" Jones
*
* Copyright (C) Samuel "Pasarus" Jones  - All Rights Reserved - https://redraw-gaming.co.uk
* Unauthorized copying of this file, via any medium is strictly prohibited
* without the express permission of Samuel "Pasarus" Jones
* 
* Random delivery selector for the delivery framework
*/

params [
  ["_missionType", "", [""]]
];

private _allowChecking = false;
private _randomNumber = 0;
private _numberOfLocations = 0;
private _destination = "";

if (_allowChecking) then {
	if (_missionType isEqualTo "") exitWith {};
};

_numberOfLocations = count ("true" configClasses (missionConfigFile >> "cfgDelivery" >> "deliveryLocations" >> format["%1Locations", _missionType]));
_randomNumber = round(random _numberOfLocations);
while {_randomNumber == 0} do {
	_randomNumber = round(random _numberOfLocations);
};
_destination = format ["%1_%2", _missionType, _randomNumber];

//Classname of the location in which you want to go to!
_destination