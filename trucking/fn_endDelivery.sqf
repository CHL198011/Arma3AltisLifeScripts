/*
* @File: fn_endDelivery.sqf
* @Author: Samuel "Pasarus" Jones
*
* Copyright (C) Samuel "Pasarus" Jones  - All Rights Reserved - https://redraw-gaming.co.uk
* Unauthorized copying of this file, via any medium is strictly prohibited
* without the express permission of Samuel "Pasarus" Jones
*
* This is the last bit to be done in a delivery mission the whole GIMME MY MONEY! section and GIVE ME BACK MY CLOTHES YOU C*NT!.
*/

private _missionType = (_this select 3) select 0;
private _vehicleSpawnMarker = (_this select 3) select 1;


if (_missionType isEqualTo "") exitWith {};

//Check if on a delivery
if !(player getVariable ["truckDeliveryMission", false]) exitWith {["No delivery mission!", "You are not currently doing a delivery mission!", "danger"] call RR_fnc_notify;};

//Check if you have dropped off the actual stuff!
if !(player getVariable ["truckDeliveryDelivered", false]) exitWith {["Not delivered the goods!", "Try heading to the place marked on your map!", "danger"] call RR_fnc_notify;};

//Check if the truck is a delivery truck!
if !([_missionType,(player getVariable "truckDeliverySize"), getMarkerPos _vehicleSpawnMarker] call RR_fnc_truckChecks) exitWith {["There is no valid truck nearby!", "Try bringing it closer to the shop!", "default"] call RR_fnc_notify;};

//Check if the nearest truck is the players truck!
private _nearestTruck = (nearestObjects [(getMarkerPos format["%1_garage_1", _missionType]), ["AllVehicles"], 20]) select 0;
if !((((_nearestTruck getVariable "vehicle_info_owners") select 1) select 0) isEqualTo (getPlayerUID player)) exitWith {["The nearest truck is not your truck!", "Try bringing your own truck this time!", "danger"] call RR_fnc_notify;};


//Give the player the money
private _income = (player getVariable ["truckDeliveryIncome", 0]);
life_atmBank = life_atmBank + _income;
["You have completed your delivery mission!", format["Your bank account has been credited with £%1", _income], "success"] call RR_fnc_notify;

//Delete the truck
{detach _x; deleteVehicle _x} forEach attachedObjects _nearestTruck;
deleteVehicle _nearestTruck;

//Get all player gear set Variables!
private _newClothes = player getVariable ["truckOldClothes", nil];
private _newUniformItems = player getVariable ["truckOldUniformItems", nil];
private _newBackpack = player getVariable ["truckOldBackpack", nil];
private _newVest = player getVariable ["truckOldVest", nil];
private _newVestItems = player getVariable ["truckOldVestItems", nil];
private _newBackpackItems = player getVariable ["truckOldBackpackItems", nil];
private _newWeapon = player getVariable ["truckOldWeapon", nil];
private _newWeaponItems = player getVariable ["truckOldWeaponItems", nil];
private _newWeaponMagazine = player getVariable ["truckOldWeaponMagazine", nil];

//Add a way for checking for new items in the uniform to readd to the clothing a long with the old stuff.

//Strip delivery equipment.
removeBackpack player;
removeUniform player;

//Give back old Gear
if !(isNil "_newClothes") then {
    player addUniform _newClothes;
};

if !(isNil "_newUniformItems") then {
    {
            player addItemToUniform _x;
    }  forEach _newUniformItems;
};

if !(isNil "_newBackpack") then {
    player addBackpack _newBackpack;
};

if !(isNil "_newVest") then {
    player addVest _newVest;
};

if !(isNil "_newBackpackItems") then {
    {
            player addItemToBackpack _x;
    } forEach _newBackpackItems;
};

if !(isNil "_newVestItems") then {
    {
            player addItemToVest _x;
    } forEach _newVestItems;
};
if !(isNil "_newWeapon") then {
    player addWeapon _newWeapon;

};

if !(isNil "_newWeaponItems") then{
    {
        player addPrimaryWeaponItem _x;
    } forEach _newWeaponItems;
};

if !(isNil "_newWeaponMagazine") then {
    player addMagazine _newWeaponMagazine;
};

//Handle experience gain
private _missionSize = player getVariable ["truckDeliverySize", "small"];
private _xpGain = switch (_missionSize) do {
    case "small": {150};
    case "medium": {300};
    case "large": {500};
};
[_xpGain] call RR_fnc_addXP;

//Remove all those player variables' values
player setVariable ["truckOldClothes", ""];
player setVariable ["truckOldUniformItems", ""];
player setVariable ["truckOldBackpack", ""];
player setVariable ["truckOldVest", ""];
player setVariable ["truckOldVestItems", ""];
player setVariable ["truckOldBackpackItems", ""];
player setVariable ["truckOldWeapon", ""];
player setVariable ["truckOldWeaponItems", ""];
player setVariable ["truckOldWeaponMagazine", ""];
player setVariable ["truckDeliveryMission", false];
player setVariable ["truckDeliveryIncome", 0];
player setVariable ["truckDeliveryLocation", ""];
player setVariable ["truckDeliveryType", ""];

//Handle the markers
deleteMarkerLocal "Delivery Name";

//Sync the players Data!
[] call SOCK_fnc_updateRequest;