/*    
* @File: fn_ANPR.sqf                 
* @Author: ArrogantBread
* @Editor/bugfinder extraordinair: Samuel "Pasarus" Jones               
*                
* Copyright (C) Nathan "ArrogantBread" Wright  - All Rights Reserved - https://www.WEBSITENAMEHERE.co.uk                
* Unauthorized copying of this file, via any medium is strictly prohibited                
* without the express permission of Nathan "ArrogantBread" Wright                
*/
private ["_vehicle", "_targetSpeed", "_target", "_activetargets", "_activeTarget", "_vehicleOwners", "_vehicleType", "_output", "_phrase", "_chunk", "_passengers", "_phrase", "_chunk", "_i"];

//--- side/vehicle checks
if !((playerSide isEqualTo west) OR  !((vehicle player) isEqualTo player)) exitWith {};

//--- Delay to stop network spammage
if(time - RR_ANPRDelay < 3) exitWith {};
RR_ANPRDelay = time;

//-- Vehicle checks
_vehicle = vehicle player;
if(isNull _vehicle) exitWith {};
if(!((typeOf _vehicle) in ["C_Offroad_01_F","C_Offroad_02_unarmed_F","C_SUV_01_F","C_Hatchback_01_F","C_Hatchback_01_sport_F","B_MRAP_01_F","B_T_LSV_01_unarmed_F"])) exitWith {};
if(count (crew (_vehicle)) == 0) exitWith {};
if(!alive _vehicle) exitWith {};

//--- No sound because Phil moans
// [_veh,"ANPRSound"] remoteExec ["life_fnc_say3D",RANY];

_targetArraySize = 50;
_target = nearestObjects [_vehicle, ["car"], _targetArraySize];
//--- First vehicle in array is own car

/*
{
	if (alive _x) then {
		_activetargets set [(count _activetargets),_x];
	};
} forEach _target;
*/

_activeTarget = _vehicle;
_i = 1;
while {(isNull _activeTarget || _activeTarget isEqualTo _vehicle) || !(_i < _targetArraySize)} do {
  //First vehicle is your own vehicular thingymabob
  if (alive (_target select _i)) then {
    _activeTarget = _target select _i;
  };
};

if (_activeTarget == _vehicle) exitWith {parseText format["<t color='#5A80EB'><t align='center'><t size='1.5'>ERROR</t></t><br/><t color='#FF0000'><t size='1'>No Vehicle In Range</t></t>"];}; //--- TODO: Replace with custom notification system

_vehicleType = getText(configFile >> "CfgVehicles" >> (typeOf _activeTarget) >> "displayName");//--- Vehicle Type
_targetSpeed = round speed (_activeTarget); //---Speed of target
_vehicleOwners = _activeTarget getVariable "vehicle_info_owners";//--- Keyholders
_output = "";
_speed = (speed _activeTarget);
_phrase = "";

if (count _vehicleOwners < 1) then {
  _output = "<t color='#5A80EB'><t align='center'><t size='1.5'>ERROR</t></t><br/><t color='#FF0000'><t size='1'>No Registered Owner<br />(Send to Impound)</t></t>";
} else {
  _output = format ["<t color='#5A80EB'><t align='center'><t size='1.5'>%1</t></t><br/><t color='#FF0000'>", _vehicleType];
  _ownerInfo = "";
  {
    _chunk = "";
    if (_forEachIndex == 0) then { _chunk = "<t color='#ffffff'><t size='1.5'>Registered Owner:</t></t><br/>";};
    if (_forEachIndex == 1) then { _chunk = "<t color='#ffffff'><t size='1.5'>Other Keyholder(s):</t></t><br/>";};
    _owneruid = _x select 0;

    if !([_owneruid] call life_fnc_isUIDActive) then {
      _chunk = _chunk + format["(Away) %1<br/>",_x select 1];
    } else {
      // _chunk = _chunk + format["%1<br/>",_x select 1];	
      //If they have a bounty bigger than 0 (wanted) then add them to the list with a prefix!
      if(false) then {
        _chunk = _chunk + format["<t color='#ff0000'>(WANTED) </t>%1<br/>",_x select 1];		
      } else {
        //Not wanted
        _chunk = _chunk + format["%1<br/>",_x select 1];		
      };
    };
    _phrase = _phrase + _chunk;
  } forEach _vehicleOwners;
  
_output = _output + format["<t color='#ffffff'><t size='1'>%1</t></t><br/>", _phrase];

};

switch (true) do {
  case ((_speed > 60 && _speed <= 120)):
  {
    _output = _output + format ["<br /><t color='#efd810'><t align='center'><t size='1'>Vehicle Speed: %1 km/h", round _speed]; //--- Yellow
  };
  
  case ((_speed > 120)):
  {
    _output = _output + format ["<br /><t color='#af0000'><t align='center'><t size='1'>Vehicle Speed: %1 km/h", round _speed]; //--- Steve mcqueen Red
  };
  
  default
  {
    _output = _output + format ["<br /><t color='#01af1b'><t align='center'><t size='1'>Vehicle Speed: %1 km/h", round _speed]; //--- Law abiding, green
  };
};

hint parsetext _output; 

_passengers = crew _vehicle;
_passengers = _passengers - [player];
[3, _output] remoteExecCall ["life_fnc_broadcast", _passengers]
