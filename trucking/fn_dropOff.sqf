/*
* @File: fn_dropOff.sqf
* @Author: Samuel "Pasarus" Jones
*
* Copyright (C) Samuel "Pasarus" Jones  - All Rights Reserved - https://redraw-gaming.co.uk
* Unauthorized copying of this file, via any medium is strictly prohibited
* without the express permission of Samuel "Pasarus" Jones
* 
* The drop off part of deliveries
*/

//For an addactions like:
//this addaction ["Drop off the delivery!", "RR_fnc_dropOff", ["fuel_1","fuel"], 1, false, false, "", "true", 5];

private _dropOffLocation = (_this select 3) select 0;
private _missionType = (_this select 3) select 1;

if !(playerside isEqualTo civilian) exitWith {};
if (_dropOffLocation isEqualTo "") exitWith {};
if !(isNull objectParent player) exitWith {["Delivery Error", "You are inside of a vehicle", "danger"] call RR_fnc_notify;};
if !(player getVariable ["truckDeliveryMission", false]) exitWith {["No delivery mission!", "You are not currently doing a delivery mission!", "default"] call RR_fnc_notify;};

//Check for if this is the right shop!
private _numberOfLocations = count ("true" configClasses (missionConfigFile >> "cfgDelivery" >> "deliveryLocations" >> (format["%1Locations", _missionType])));
private _isLocation = false;
for [{_i = 0}, {_i < _numberOfLocations}, {_i=_i+1}] do {
	if (_dropOffLocation isEqualTo (getText (missionConfigFile >> "cfgDelivery" >> "deliveryLocations" >> (format["%1Locations", _missionType]) >> (format["%1_%2", _missionType, _i]) >> "marker"))) then {
		_isLocation = true;
	};
};
if !(_isLocation) exitWith {["Your at the wrong location!", (format ["Try heading to %1", (getText (missionConfigFile >> "cfgDelivery" >> "deliveryLocations" >> (player getVariable ["truckDeliveryLocation", ""]) >> "name"))]), "default"] call RR_fnc_notify;};

//Check if the truck is a delivery truck!
private _nearestTruck = (nearestObjects [(getMarkerPos (getText (missionConfigFile >> "cfgDelivery" >> "deliveryLocations" >> format["%1Locations",_missionType] >> (player getVariable ["truckDeliveryLocation", "fuel_1"]) >> "marker"))), ["AllVehicles"], 20]) select 0;
if !([_missionType,(player getVariable "truckDeliverySize"),(getMarkerPos _dropOffLocation)] call RR_fnc_truckChecks) exitWith {["There is no valid truck nearby!", "Try bringing it closer to the fuel pumps!", "default"] call RR_fnc_notify;};

//Insert a timer at some point so it is not instant if mission type is fuel.

player setVariable ["truckDeliveryDelivered", true];

["Shipment successfully delivered!","Head back to the depot and you can get your payment!","success"] call RR_fnc_notify;

//Handle the markers
deleteMarkerLocal "Delivery Name";

private _markerPos = getMarkerPos format["%1_garage_1",_missionType];
private _markerInputArray = [_markerPos select 0, _markerPos select 1];

private _markerstr = createMarkerLocal ["Delivery Name",_markerInputArray];
_markerstr setMarkerShapeLocal "ICON";
_markerstr setMarkerTypeLocal "hd_objective";
_markerstr setMarkerColorLocal "ColorWhite";
_markerstr setMarkerTextLocal "Your delivery destination!";