/*
* @File: fn_getIn.sqf
* @Author: Samuel "Pasarus" Jones
*
* Copyright (C) Samuel "Pasarus" Jones  - All Rights Reserved - https://redraw-gaming.co.uk
* Unauthorized copying of this file, via any medium is strictly prohibited
* without the express permission of Samuel "Pasarus" Jones
*/

params [
  ["_unit", objNull, [objNull]],
  ["_position", "", [""]],
  ["_vehicle", objNull, [objNull]],
  ["_turret", [], [[]]]
];

//If not in a vehicle exit.
if(isNull _vehicle || isNull _unit) exitWith {};

//Fuel Consumption script start.
[_vehicle, _unit] spawn RR_fnc_actualFuel;