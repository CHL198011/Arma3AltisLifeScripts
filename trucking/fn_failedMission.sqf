/*
* @File: fn_failedMission.sqf
* @Author: Samuel "Pasarus" Jones
*
* Copyright (C) Samuel "Pasarus" Jones  - All Rights Reserved - https://redraw-gaming.co.uk
* Unauthorized copying of this file, via any medium is strictly prohibited
* without the express permission of Samuel "Pasarus" Jones
*
* For when your truck has been nicked or you just need to reset the mission, because your truck has been nicked!.
*/

private _missionType = (_this select 3) select 0;

//Perform checking
if (_missionType isEqualTo "") exitWith {};

//Check if on a delivery
if !(player getVariable ["truckDeliveryMission", false]) exitWith {["No delivery mission!", "You are not currently doing a delivery mission!", "danger"] call RR_fnc_notify;};

//Fine the player money for losing the truck!
private _fineAmount = switch (player getVariable ["truckDeliverySize", ""]) do {
    case "large": {75000};
    case "medium": {60000};
    case "small": {50000};
    default {10000};
};

//--- bank only yeah... k
life_atmBank = life_atmBank - _fineAmount;

//Notify the player they have been fined and their mission Log has been reset.
["Mission Failed!", format["Since you have failed your mission you have been fined £%1, you may try again if you would like!", _fineAmount], "danger"] call RR_fnc_notify;

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