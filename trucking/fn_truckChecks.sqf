/*
* @File: fn_truckChecks.sqf
* @Author: Samuel "Pasarus" Jones
*
* Copyright (C) Samuel "Pasarus" Jones  - All Rights Reserved - https://redraw-gaming.co.uk
* Unauthorized copying of this file, via any medium is strictly prohibited
* without the express permission of Samuel "Pasarus" Jones
*
* What does it do? it checks the config and depending on the parameters input will return either true or false, for whether the truck required to do the mission is present.
* Yes I know its broken (not I actually don't but it probably is anyways).
*/

params [
  ["_missionType", ""],
  ["_vehicleSize", ""],
  ["_checkFrom", ""]
];

if (_missionType isEqualTo "" || _vehicleSize isEqualTo "" || _checkFrom isEqualTo "") exitWith {};

private _vehiclesToCheck = getArray (missionConfigFile >> "cfgDelivery" >> "deliveryTypes" >> (format["%1", _missionType]) >> (format["vehicles%1", _vehicleSize]));

private _nearestTruck = (nearestObjects [_checkFrom, ["AllVehicles"], 20]) select 0;

private _isTrue = false;

{
  if(typeOf _nearestTruck == _x) exitWith {_isTrue = true};
} forEach _vehiclesToCheck;

_isTrue

//typeOf ((nearestObjects [(getMarkerPos "fuel_16"), ["AllVehicles"], 20]) select 0) == "C_Van_01_fuel_F"