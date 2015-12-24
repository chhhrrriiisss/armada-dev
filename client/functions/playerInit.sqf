_unit = player;

if (!local _unit) exitWith {};
if (!isNil { _unit getVariable 'TTN_Init'} ) exitWith {};
_unit setVariable['TTN_Init', true];

_unit addItem "ItemMap";
_unit assignItem "ItemMap";

_unit removeAllEventHandlers "Respawn";
_unit removeAllEventHandlers "Killed";
_unit removeAllEventHandlers "Hit";
_unit removeAllEventHandlers "Fired";

_unit addeventhandler ["Respawn", playerRespawn];  
_unit addeventhandler ["Killed", playerKilled];
_unit addeventhandler ["Hit", playerHit];
_unit addeventhandler ["Fired", { _this call playerFired }];

if (!isNil "TTN_DC_EH") then { removeMissionEventHandler ["HandleDisconnect",GW_DC_EH];  TTN_DC_EH = nil; };

TTN_DC_EH = addMissionEventHandler ["HandleDisconnect",{

	pubVar_logDiag = format['%1 disconnected.', _n];
	publicVariableServer "pubVar_logDiag";

	// Remove old event handlers
	{ _p removeAllEventHandlers _x;	} foreach ['killed', 'handleDamage', 'respawn'];

	// Kill the unit
	_p setDammage 1;

}];

clientLoadComplete = compileFinal "true";