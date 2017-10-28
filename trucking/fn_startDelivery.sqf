/*
* @File: fn_startDelivery.sqf
* @Author: Samuel "Pasarus" Jones
*
* Copyright (C) Samuel "Pasarus" Jones  - All Rights Reserved - https://redraw-gaming.co.uk
* Unauthorized copying of this file, via any medium is strictly prohibited
* without the express permission of Samuel "Pasarus" Jones
* 
* Start file of Deliveries
*/

//Intended use is ["fuel", "medium", "Fuel_garage_1"] call RR_fnc_startDelivery. This should start a small fuel delivery with a fuel van.
//this addaction ["Small Fuel Delivery", "RR_fnc_startDelivery", ["fuel","small", "Fuel_garage_1"], 1, false, false, "", "true", 5];
//this addaction ["Medium Fuel Delivery", "RR_fnc_startDelivery", ["fuel","medium", "Fuel_garage_1"], 2, false, false, "", "true", 5];
//this addaction ["Large Fuel Delivery", "RR_fnc_startDelivery", ["fuel","large", "Fuel_garage_1"], 3, false, false, "", "true", 5];

private _missionType = (_this select 3) select 0;
private _missionSize = (_this select 3) select 1;
private _vehicleSpawnMarker = (_this select 3) select 2;

if (_missionSize isEqualTo "medium" && !(["mediumTrucking"] call RR_fnc_hasPerk)) exitWith {["Delivery Missions", "You do not have the required skill to use this truck size", "danger"] call RR_fnc_notify; }; 
if (_missionSize isEqualTo "large" && !(["largeTrucking"] call RR_fnc_hasPerk)) exitWith {["Delivery Missions", "You do not have the required skill to use this truck size", "danger"] call RR_fnc_notify; }; 

//You know the checking part?
if !(playerside isEqualTo civilian) exitWith {};
if (_missionType isEqualTo "" || _missionSize isEqualTo "" || _vehicleSpawnMarker isEqualTo "") exitWith {};
if !(isNull objectParent player) exitWith {["Delivery Missions", "You are inside of a vehicle", "danger"] call RR_fnc_notify;};
if (player getVariable ["truckDeliveryMission", false]) exitWith {["Delivery Missions", "You already have a mission!", format ["Go to the destination %1", (getText (missionConfigFile >> "cfgDelivery" >> "deliveryLocations" >> (player getVariable truckDeliveryLocation) >> "name"))]] call RR_fnc_notify;};
if !((nearestObjects[(getMarkerPos _vehicleSpawnMarker),["AllVehicles"],5]) isEqualTo []) exitWith {["Delivery Missions", "Spawn point blocked", "warning"] call RR_fnc_notify;};
if !(license_civ_trucking) exitWith {["Delivery Missions", "You do not have a valid trucking license", "danger"] call RR_fnc_notify;};

[] call SOCK_fnc_updateRequest;

//Getting the truck type to use
private _truckToSpawnFormat = format["vehicles%1", _missionSize];
private _truckToSpawn = ((getArray (missionConfigFile >> "cfgDelivery" >> "deliveryTypes" >> _missionType >> _truckToSpawnFormat)) select 0);

//The destination decision
private _destination = [_missionType] call RR_fnc_destinationSelector;

//Start the mission!
player setVariable ["truckDeliveryMission", true];

//Get some random money income! between set values defined in the config
private _minMax = getArray (missionConfigFile >> "cfgDelivery" >> "deliveryLocations" >> (format["%1Locations", _missionType]) >> _destination >> "moneyMinMax");
private _min = _minMax select 0;
private _max = _minMax select 1;

private _truckDeliveryMultiplier = switch (_missionSize) do {
	case "small": { 1; };
	case "medium": { 1.25; };
	case "large": { 1.5; };
};

if (["trucking1"] call RR_fnc_hasPerk) then {
	_truckDeliveryMultiplier + 0.25;
};

private _truckDeliveryIncome = (round(random [_min, (_max/2 + _max/4),_max])) * _truckDeliveryMultiplier;

player setVariable ["truckDeliveryIncome", _truckDeliveryIncome];
player setVariable ["truckDeliveryLocation", _destination];
player setVariable ["truckDeliveryType", _missionType];
player setVariable ["truckDeliverySize", _missionSize];

//Handle stripping and dressing player ---------------------------------------------------------------

//Make it so that when uniform is present stop new clothing/weapons from syncing!

//Players inventory saved
player setVariable ["truckOldClothes", uniform player];
player setVariable ["truckOldUniformItems", uniformItems player];
player setVariable ["truckOldBackpack", backpack player];
player setVariable ["truckOldVest", vest player];
player setVariable ["truckOldVestItems", vestItems player];
player setVariable ["truckOldBackpackItems", backpackItems player];
player setVariable ["truckOldWeapon", primaryWeapon player];
player setVariable ["truckOldWeaponItems", primaryWeaponItems player];
player setVariable ["truckOldWeaponMagazine", primaryWeaponMagazine player];

//Remove inventory items that are not welcome
player removeWeapon (primaryWeapon player);
removeUniform player;
removeVest player;
removeBackpack player;

//Give them their new clothes
player addUniform "U_C_WorkerCoveralls";
player addBackpack "B_Kitbag_rgr";
private _uniformTexture = format ["textures\trucking\%1\uniform\%1_uniform.paa", _missionType];
["uniform", player, _uniformTexture, uniform player] remoteexec ["RR_fnc_applyTexture", 0];

//Give em a GPS
if !("ItemGPS" in (items player + assignedItems player)) then {
	player addItem "ItemGPS";
	player assignItem "ItemGPS";
};

//Give em a Map
if !("ItemMap" in (items player + assignedItems player)) then {
	player addItem "ItemMap";
	player assignItem "ItemMap";
};

//Handle vehicle spawning ----------------------------------------------------------------------------
private "_vehicle";

//Set up the vehicle
_vehicle = createVehicle [_truckToSpawn, (getMarkerPos _vehicleSpawnMarker), [], 0, "NONE"];
waitUntil {!isNil "_vehicle" && {!isNull _vehicle}};
_vehicle allowDamage false;
_vehicle setPos (getMarkerPos _vehicleSpawnMarker);
_vehicle setVectorUp (surfaceNormal (getMarkerPos _vehicleSpawnMarker));
_vehicle setDir (markerDir _vehicleSpawnMarker);

//Lock the vehicle
[_vehicle, 2] remoteExecCall ["life_fnc_lockVehicle", _vehicle];

//Clear vehicle ammo
[_vehicle] call life_fnc_clearVehicleAmmo;

//Set Trunk variable
[_vehicle,"trunk_in_use",false,true] remoteExecCall ["TON_fnc_setObjVar",_vehicle];

//Set owners
private _truckOwner = getText (missionConfigFile >> "cfgDelivery" >> "deliveryCompanies" >> _missionType >> "name");
[_vehicle,"vehicle_info_owners",[["", _truckOwner],[getPlayerUID player,profileName]],true] remoteExecCall ["TON_fnc_setObjVar"];

//Apply texture - Not for now because paul said so!
private _vehicleTexture = format ["textures\trucking\%1\vehicles\%2.paa", _missionType, _truckToSpawn];
_vehicle setObjectTextureGlobal [0, _vehicleTexture];
//--- use this to color vehicle
//[_vehicle,_colorIndex] call life_fnc_colorVehicle;

//Give it some toolkits
_vehicle addItemCargoGlobal ["ToolKit", 2];

//Renable damage handling
_vehicle allowDamage true;

//Give keys to player
life_vehicles pushBack _vehicle;

//Notification
private _destinationName = (getText (missionConfigFile >> "cfgDelivery" >> "deliveryLocations" >> (format["%1Locations", _missionType]) >> _destination >> "name"));

//Handle creating the marker
private _markerPos = getMarkerPos _destination;
private _markerInputArray = [_markerPos select 0, _markerPos select 1];

private _markerstr = createMarkerLocal ["Delivery Name",_markerInputArray];
_markerstr setMarkerShapeLocal "ICON";
_markerstr setMarkerTypeLocal "hd_objective";
_markerstr setMarkerColorLocal "ColorWhite";
_markerstr setMarkerTextLocal "Your delivery destination!";

//private _packet = format ["Mission started<br />Location: %1<br />Payout: %2<br />Size:%3<br />A marker has been placed at your destination", _destinationName, player getVariable ["truckDeliveryIncome", "error"], _missionSize];

//["Your destination", _packet, "success"] call RR_fnc_notify;

["Delivery Mission Started!", format["You need to head to %1 for £%2, a marker has been placed at your destination!", _destinationName, (player getVariable ["truckDeliveryIncome", "error"])] , "success"] call RR_fnc_notify;

//eof