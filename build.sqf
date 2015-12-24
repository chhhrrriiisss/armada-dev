_deployOnboard = [_this, 0, true, [true]] call filterParam;

addTitanAsset = {
	param ['_class', '_selectionPosition', '_attachTo', '_attachPosition', '_matrix', '_dir'];
	private ['_class', '_selectionPosition', '_attachTo', '_attachPosition', '_matrix', '_dir', '_asset'];
	_asset = _class createVehicle [0,0,0];
	_aPosition = _asset selectionPosition _selectionPosition;
	_asset attachTo [_attachTo, [(_aPosition SELECT 0) * (_matrix select 0), (_aPosition select 1) * (_matrix select 1), (_aPosition select 2)  * (_matrix select 2)], _attachPosition]; 
	_asset attachTo [TITAN];	
	_asset setDir ([(getDir TITAN) + _dir] call normalizeAngle);	
};

if (!isNil "TITAN") then {

	TITAN = nil;

	Sleep 2;


};

_addEngineSet = {	

	_timeout = time + 1;
	waitUntil {
		(((attachedTo (_this select 0) == TITAN) && (attachedTo (_this select 1) == TITAN)) || (time > _timeout))
	};	

	_engine = "T2_Engine" createVehicle [0,0,0];
	_aPosition = (_engine selectionPosition "AP1") vectorAdd [1.1,0,-4.3];
	_engine attachTo [(_this select 0), [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP3"]; 
	_engine attachTo [TITAN];

	_engine2 = "T2_Engine" createVehicle [0,0,0];
	_aPosition = (_engine2 selectionPosition "AP1") vectorAdd [1.1,0,-4.3];
	_engine2 attachTo [(_this select 1), [(_aPosition SELECT 0) * -1, (_aPosition select 1), (_aPosition select 2) * -1], "AP3"]; 
	_engine2 attachTo [TITAN];	
	_engine2 setDir ([(getDir TITAN) + 180] call normalizeAngle);	

	_engine setVariable ['engineSpeed', 0.5];
	_engine2 setVariable ['engineSpeed', 0.5];

	if (TITAN_ENGINES_ENABLED) then {
		_engine execVM 'propEffects.sqf';
		_engine2 execVM 'propEffects.sqf';
	};

	TITANASSETS pushBack _engine;
	TITANASSETS pushBack _engine2;

};

TITAN_ENGINES_ENABLED = false;

_maxParts = 9;
_engineRoomLocation = [1];
_engineLocations = [0, _maxParts-1,_maxParts];
_upperLocations = [_maxParts, _maxParts-1, _maxParts-2];
_armoryLocations = [_maxParts];
_wallLocations = [5, 7, 9];
_hangarLocations = [_maxParts-3];
_turretLocations = [_maxParts, 1];
_ventEntry = [_maxParts];
_balconySegments = [0, _maxParts-1, _maxParts-2, _maxParts-3, _maxParts -4, _maxParts -5, _maxParts -6, _maxParts-7,  _maxParts-8];

TITANASSETS = [];

_spawnPos = (getMarkerPos "titan_spawn");
TITAN = "T2_Bulkhead_C" createVehicle _spawnPos;

// Don't add cargo to this element
// TITAN setVariable ['TTN_DNA', ['CP']];
TITANASSETS pushBack TITAN;



// // Add vent
_vent = "T2_Airvent_Straight" createVehicle [0,0,0];
_aPosition = (_vent selectionPosition "AP1");
_vent attachTo [TITAN, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP5"]; 
_vent attachTo [TITAN];
TITANASSETS pushBack _vent;

_left = "T2_Bulkhead_01" createVehicle (getMarkerPos "titan_spawn");
_aPosition = (_left selectionPosition "AP4");
_left attachTo [TITAN, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP3"]; 

_right = "T2_Bulkhead_01" createVehicle (getMarkerPos "titan_spawn");
_aPosition = (_right selectionPosition "AP3");
_right attachTo [TITAN, [(_aPosition SELECT 0) * -1, (_aPosition select 1), (_aPosition select 2) * -1], "AP4"]; 
_right setDir ([(getDir _left) + 180] call normalizeAngle);	


TITANASSETS pushBack _left;
TITANASSETS pushback _right;

if (0 in _engineLocations) then {
	[_left, _right] spawn _addEngineSet;

};

_lastAttached = TITAN;

for "_i" from 1 to _maxParts step 1 do {

	_asset = (random 100) call {
		if (_this > 50) exitWith {
			"T2_Bulkhead_01"
		};

		"T2_Bulkhead_Stairs_L"		
	};

	_addExternalBalcony = false;
	if (_i in _balconySegments) then {

		_addExternalBalcony = true;

		_index = _balconySegments find _i;
		if (_index == 0 || _index == ((count _balconySegments)-1) ) exitWith {};
		if (_index == 1 || _index == ((count _balconySegments)-2) ) exitWith {
			_asset = "T2_Bulkhead_BalconyAccess";
		}; 			
	};

	if (_i in _balconySegments && _i in _turretLocations) then { _addExternalBalcony = true; };
	if (_i in _turretLocations) then { 
		_asset = "T2_Bulkhead_Turret_L"; 
	};

	// Center 
	_centreAsset = if (_i in _ventEntry) then { "T2_Bulkhead_C_VentAccess" } else { "T2_Bulkhead_C" };
	if (_i in _engineRoomLocation || (_i- 1) in _engineRoomLocation || (_i - 2) in _engineRoomLocation) then {
		_centreAsset = "T2_Bulkhead_C_NoFloor";		
	};

	_centre = _centreAsset createVehicle [0,0,0];

	if (_centreAsset == "T2_Bulkhead_C_NoFloor") then {
		_centre setVariable ['TTN_DNA', ['CP']];
	};

	_aPosition = (_centre selectionPosition "AP1");
	_centre attachTo [_lastAttached, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP2"]; 
	_centre attachTo [TITAN];
	TITANASSETS pushBack _centre;
	_lastAttached = _centre;

	// Last slot, generate engine bay
	if ( (_i - 2) in _engineRoomLocation ) then {

		// Engine Room above 
		_engineRoom = "T2_EngineRoom_F" createVehicle [0,0,0];

		// _aPosition = (_engineRoom selectionPosition "AP2");


		// _engineRoom attachTo [TITAN, [(_aPosition SELECT 0), (_aPosition select 1), (_aPosition select 2) * -1], "AP1"]; 
		// _engineRoom setDir ([(getDir TITAN) + 180] call normalizeAngle);
		// TITANASSETS pushBack _engineRoom;

		// _timeout = time + 3;
		// waitUntil {
		// 		Sleep 0.1;
		// 		( (!isNull attachedTo _engineRoom) || time > _timeout)
		// };

		// Engine Room CENTER
		_engineRoomC = "T2_EngineRoom_C" createVehicle [0,0,0];
		_aPosition = (_engineRoomC selectionPosition "AP1");
		_engineRoomC attachTo [_engineRoom, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP2"]; 

		_timeout = time + 3;
		waitUntil {
		( (!isNull attachedTo _engineRoomC) || time > _timeout)
		};

		_engineRoomR= "T2_EngineRoom_F" createVehicle [0,0,0];
		_aPosition = (_engineRoomR selectionPosition "AP2");
		_engineRoomR attachTo [_engineRoomC, [(_aPosition SELECT 0), (_aPosition select 1), (_aPosition select 2) * -1], "AP2"]; 
		_engineRoomR setDir ([(getDir TITAN) + 180] call normalizeAngle);

		TITANASSETS pushback _engineRoomR;

		_engineRoomCore = "T2_EngineRoom_Core" createVehicle [0,0,0];
		_aPosition = (_engineRoomCore selectionPosition "AP6");
		_engineRoomCore attachTo [_engineRoomC, [(_aPosition SELECT 0), (_aPosition select 1), (_aPosition select 2)*-1], "AP1"]; 

		TITANASSETS pushback _engineRoomCore;	

		_timeout = time + 3;
			waitUntil {
			( (!isNull attachedTo _engineRoomCore) || time > _timeout)
		};

		// Attach reactor to core

		_corePos = _engineRoomCore selectionPosition "CORE1";
		_device = "Land_Device_assembled_F" createvehicle [0,0,0];
		_device2 = "Land_Device_assembled_F" createvehicle [0,0,0];

		_offset = [0,-0.7,1.4];
		_offset2 =  [0,0.7,1.4];

		_device attachTo [_engineRoomCore, (_corePos vectorAdd (boundingCenter _device)) vectorAdd _offset];
		_device2 attachTo [_engineRoomCore, (_corePos vectorAdd (boundingCenter _device)) vectorAdd _offset2];

		[_device, [90,0,0]] call setPitchBankYaw;
		[_device2, [90,0,180]] call setPitchBankYaw;

		_device setVariable ['deviceMirror', [_device, _device2]];
		_device2 setVariable ['deviceMirror', [_device, _device2]];

		_mirrorDamage = {	
			_o = (_this select 0) getVariable ['deviceMirror', []];
			{ _x setDammage (_this select 2); } foreach _o;
		};

		_device addEventHandler ['handleDamage', _mirrorDamage];
		_device2 addEventHandler ['handleDamage', _mirrorDamage];






		TITANASSETS pushback _device;	
		TITANASSETS pushback _device2;	


		// ["Land_Device_assembled_F", 1, "CORE", TRUE, 100, 0],










		_engineRoomSectionA = "T2_EngineRoom_Section" createVehicle [0,0,0];
		_aPosition = (_engineRoomSectionA selectionPosition "AP6");
		_engineRoomSectionA attachTo [_engineRoomCore, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2)], "AP1"]; 

		TITANASSETS pushback _engineRoomSectionA;

		_engineRoomSectionB = "T2_EngineRoom_Section" createVehicle [0,0,0];
		_aPosition = (_engineRoomSectionB selectionPosition "AP5");
		_engineRoomSectionB attachTo [_engineRoomCore, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2)], "AP2"]; 

		TITANASSETS pushback _engineRoomSectionB;

		_timeout = time + 3;
			waitUntil {
			( ( (!isNull attachedTo _engineRoomSectionA) && (!isNull attachedTo _engineRoomSectionB) ) || time > _timeout)
		};

		_engineRoomEndA = "T2_EngineRoom_End" createVehicle [0,0,0];
		_aPosition = (_engineRoomEndA selectionPosition "AP6");
		_engineRoomEndA attachTo [_engineRoomSectionA, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP1"]; 

		TITANASSETS pushback _engineRoomEndA;

		_engineRoomEndB = "T2_EngineRoom_End" createVehicle [0,0,0];
		_aPosition = (_engineRoomEndB selectionPosition "AP5");
		_engineRoomEndB attachTo [_engineRoomSectionB, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP2"]; 
		_engineRoomEndB setDir ([(getDir TITAN) + 180] call normalizeAngle);
		TITANASSETS pushback _engineRoomEndB;



		

		_timeout = time + 3;
		waitUntil {
		Sleep 0.1;
		( (!isNull attachedTo _engineRoomCore) || time > _timeout)
		};




		{ TITANASSETS pushback _x; } foreach attachedObjects _engineRoom;

		_timeout = time + 3;
		waitUntil {
			Sleep 0.1;
			( (!isNull attachedTo _lastAttached) || time > _timeout)
		};

		_aPosition = (_engineRoom selectionPosition "AP1");
		_engineRoom attachTo [_lastAttached, [(_aPosition SELECT 0), (_aPosition select 1), (_aPosition select 2) * -1], "AP2"]; 
		_engineRoom setDir ([(getDir TITAN) + 180] call normalizeAngle);

		TITANASSETS pushback _engineRoom;

	};

	// Air vent to centre

	_ventAsset = if (_i in _ventEntry) then { "T2_Airvent_Entry" } else { "T2_Airvent_Straight" };
	_vent = _ventAsset createVehicle [0,0,0];
	_aPosition = (_vent selectionPosition "AP1");
	_vent attachTo [_centre, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP5"]; 
	_vent attachTo [TITAN];
	TITANASSETS pushBack _vent;

	// Left Side
	_left = _asset createVehicle [0,0,0];
	_aPosition = (_left selectionPosition "AP4");
	_left attachTo [_centre, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP3"]; 
	_left attachTo [TITAN];
	TITANASSETS pushBack _left;

	_timeout = time + 3;
	waitUntil {
		Sleep 0.1;
		( (!isNull attachedTo _centre) || time > _timeout)
	};

	// Right side
	_right = _asset createVehicle [0,0,0];
	_aPosition = (_right selectionPosition "AP3");
	_right attachTo [_centre, [(_aPosition SELECT 0) * -1, (_aPosition select 1), (_aPosition select 2) * -1], "AP4"]; 
	_right attachTo [TITAN];
	_right setDir ([(getDir TITAN) + 180] call normalizeAngle);	
	TITANASSETS pushback _right;	


	// If we require external balcony
	if (_addExternalBalcony) then {

		_timeout = time + 3;
		waitUntil {
			Sleep 0.1;
			( (!isNull attachedTo _centre) && (!isNull attachedTo _left) && (!isNull attachedTo _right) || time > _timeout)
		};

		_balconyAsset = (random 100) call {
			if (_this > 40) exitWith {
				"T2_Balcony_Angled"
			};

			"T2_Balcony_Straight"
		};

		_index = _balconySegments find _i;
		if (_index == 1 || _index == ((count _balconySegments)-2) ) then {
			_balconyAsset =  "T2_Balcony_Access";
		};

		_balconyAssetR = _balconyAsset;
		_balconyAssetL = _balconyAsset;

		if (_index == 0) then {
			_balconyAssetL =  "T2_Balcony_Stairs_L";
			_balconyAssetR =  "T2_Balcony_Stairs_R";
		};

		IF (_index == ((count _balconySegments)-1)) then {
			_balconyAssetL =  "T2_Balcony_Stairs_L";
			_balconyAssetR =  "T2_Balcony_Stairs_R";
		};



		// Left balcony
		_bLeft = _balconyAssetL createVehicle [0,0,0];
		_aPosition = (_bLeft selectionPosition "AP1");
		_bLeft attachTo [_left, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP3"]; 
		_bLeft attachTo [TITAN];
		TITANASSETS pushBack _bLeft;

		// Right side partition
		_bRight = _balconyAssetR createVehicle [0,0,0];
		_aPosition = (_bRight selectionPosition "AP1");

		_offset = if (typeOf _bRight == "T2_Balcony_Stairs_R") then { 1 } else { -1 };
		_bRight attachTo [_right, [(_aPosition SELECT 0) * _offset, (_aPosition select 1) * _offset, (_aPosition select 2) * -1], "AP3"]; 
		_bRight attachTo [TITAN];

		_dir = if (typeOf _bRight == "T2_Balcony_Stairs_R") then { 0 } else { 180 };
		_bRight setDir ([(getDir TITAN) + _dir] call normalizeAngle);

		TITANASSETS pushBack _bRight;

	};


	// If it's a turret slot, add a turret!
	if (_i in _turretLocations) then { 

		// Left side turret
		_turret = "T2_Turret_80mm" createVehicle [0,0,0];
		_aPosition = (_turret selectionPosition "AP1");
		_turret attachTo [_left, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "TP1"]; 
		_turret attachTo [TITAN];
		TITANASSETS pushback _turret;

		// Right side turret
		_turret = "T2_Turret_80mm" createVehicle [0,0,0];
		_aPosition = (_turret selectionPosition "AP1");
		_turret attachTo [_right, [(_aPosition SELECT 0) * -1, (_aPosition select 1), (_aPosition select 2) * -1], "TP1"]; 
		_turret setDir ([(getDir TITAN) + 180] call normalizeAngle);	
		TITANASSETS pushback _turret;

	};

	// If this section is a wall
	if (_i in _wallLocations) then {

		_timeout = time + 3;
		waitUntil {
			Sleep 0.1;
			( (!isNull attachedTo _centre) && (!isNull attachedTo _left) && (!isNull attachedTo _right) || time > _timeout)
		};
		// Center partition
		_wall = "T2_Wall_CargoNet_C" createVehicle [0,0,0];
		_aPosition = (_wall selectionPosition "AP1");
		_wall attachTo [_centre, [(_aPosition SELECT 0) * -1, (_aPosition select 1)* -1, (_aPosition select 2) * -1], "AP2"]; 
		_wall attachTo [TITAN];
		TITANASSETS pushBack _wall;

		// Left side partition
		_leftWall = "T2_Wall_CargoNet_01" createVehicle [0,0,0];
		_aPosition = (_leftWall selectionPosition "AP1");
		_leftWall attachTo [_left, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP2"]; 
		_leftWall attachTo [TITAN];
		TITANASSETS pushBack _leftWall;

		// Right side partition
		_rightWall = "T2_Wall_CargoNet_01" createVehicle [0,0,0];
		_aPosition = (_rightWall selectionPosition "AP1");
		_rightWall attachTo [_right, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP1"]; 
		_rightWall attachTo [TITAN];
		_rightWall setDir ([(getDir TITAN) + 180] call normalizeAngle);
		TITANASSETS pushBack _rightWall;
	};


	_timeout = time + 3;
	waitUntil {
		( (!isNull attachedTo _centre) && (!isNull attachedTo _left) && (!isNull attachedTo _right) || time > _timeout)
	};
	
	// Upper cabin
	if (_i in _upperLocations) then {

		_asset = (random 100) call {
			if (_this > 50) exitWith {
				"T2_BulkheadMid_01"
			};		
			"T2_BulkheadMid_Stairs_L"
		};

		_leftAsset = _asset;
		_rightAsset = _asset;

		if (typeOf _left == "T2_Bulkhead_Stairs_L") then { _leftAsset = "T2_BulkheadMid_Stairs_L"; };
		if (typeOf _right == "T2_Bulkhead_Stairs_L") then { _rightAsset = "T2_BulkheadMid_Stairs_L"; };

		// If asset behind hangar door exit
		_centreAsset = "T2_BulkheadMid_C_Sealed";
		if ((_i-1) in _hangarLocations) then { _centreAsset = "T2_BulkheadMid_C"; };

		_centreUpper = _centreAsset createVehicle [0,0,0];
		_aPosition = (_centreUpper selectionPosition "AP1");
		_centreUpper attachTo [_centre, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP5"]; 
		_centreUpper attachTo [TITAN];
		TITANASSETS pushBack _centreUpper;

		_leftUpper = _leftAsset createVehicle [0,0,0];
		_aPosition = (_leftUpper selectionPosition "AP1");
		_leftUpper attachTo [_left, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP5"]; 
		_leftUpper attachTo [TITAN];
		TITANASSETS pushBack _leftUpper;

		_rightUpper = _rightAsset createVehicle [0,0,0];
		_aPosition = (_rightUpper selectionPosition "AP3");
		_rightUpper attachTo [_right, [(_aPosition SELECT 0) , (_aPosition select 1) * -1 , (_aPosition select 2) * -1], "AP8"]; 
		_rightUpper attachTo [TITAN];
		_rightUpper setDir ([(getDir TITAN) + 180] call normalizeAngle);
		TITANASSETS pushBack _rightUpper;

		if (_i in _armoryLocations) then {

			// Armory above cargo (right)
			

			// waitUntil {
			// 	(!isNull attachedTo _rightUpper)
			// };

			// _armory attachTo [_rightUpper, [5,-6.5,3.1], "AP2"]; 
			// [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1 , (_aPosition select 2) * -1]
			_timeout = time + 3;
			waitUntil {
				Sleep 0.1;
				( (!isNull attachedTo _rightUpper) && (!isNull attachedTo _leftUpper) || time > _timeout)
			};

			_armory = "T2_BulkheadMid_Armory_R" createVehicle [0,0,0];
			_aPosition = (_armory selectionPosition "AP2");
			_armory attachTo [_rightUpper, [(_aPosition SELECT 0), (_aPosition select 1), (_aPosition select 2)*-1], "AP1"]; 
			_armory attachTo [TITAN];
			TITANASSETS pushBack _armory;

			_armory = "T2_BulkheadMid_Armory_l" createVehicle [0,0,0];
			_aPosition = (_armory selectionPosition "AP2");
			_armory attachTo [_leftUpper, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2)*-1], "AP2"]; 
			_armory attachTo [TITAN];
			TITANASSETS pushBack _armory;

			// Working
			// waitUntil {
			// 	!isNUll attachedTo _rightUpper
			// };

			// _armory = "T2_BulkheadMid_Armory_R" createVehicle [0,0,0];

			// _aPosition = (_armory selectionPosition "AP2");

			// _armory attachTo [_right, [(_aPosition SELECT 0), (_aPosition select 1) , (_aPosition select 2)*-1], "AP5"]; 
			// _armory attachTo [TITAN]
		};

		

	};

	if (_i in _hangarLocations) then {
		_hangar = "T2_HangarDoor_L" createVehicle [0,0,0];
		_aPosition = (_hangar selectionPosition "AP1");	

		_hangar attachTo [_left, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP5"]; 
		_hangar attachTo [TITAN];

		// Add doors to this asset
		//[_hangar] call generateDoors;

		TITANASSETS pushBack _hangar;
	};

	// EngineS for last BULKHEAD
	if (_i in _engineLocations) then {
		[_left, _right] spawn _addEngineSet;
	};
	
	

};


// Cargo Door (Left)
_cargo = "T2_CargoDoor_L" createVehicle [0,0,0];
_aPosition = (_cargo selectionPosition "AP1");
_cargo attachTo [_left, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP2"]; 
_cargo attachTo [TITAN];
TITANASSETS pushback _cargo;

_cargo = "T2_CargoDoor_R" createVehicle [0,0,0];
_aPosition = (_cargo selectionPosition "AP1");
_cargo attachTo [_right, [(_aPosition SELECT 0), (_aPosition select 1), (_aPosition select 2) * -1], "AP1"]; 
_cargo attachTo [TITAN];
TITANASSETS pushback _cargo;


Sleep 1;

TITAN setVectorUp [0,0,1];

_p = getPosASL TITAN;
_p set [2, 40];
TITAN setPosASL _p;

HITBOX = "PhysicsTest" createVehicle [0,0,0];
HITBOX attachTo [TITAN, [0,6,3.3], "AP1"]; 
HITBOX enableSimulation false;
TITANASSETS pushback HITBOX;

detach HITBOX;
TITAN attachTo [HITBOX];

HITBOX ANIMATE ['box_1_slide', 1, true];
HITBOX ANIMATE ['box_2_slide', 1, true];
HITBOX ANIMATE ['box_3_slide', 1, true];
HITBOX ANIMATE ['box_4_slide', 1, true];
HITBOX ANIMATE ['box_5_slide', 1, true];

HITBOX enableSimulation true;

TITAN = HITBOX;

HITBOX setMass 0;
HITBOX addEventHandler['EpeContact', {		

	[(_this select 0), (_this select 1)] spawn {
		{ _x setVelocity [0,0,0] } foreach _this;
		Sleep 0.5;
		{ _x setVelocity [0,0,0] } foreach _this;
	};
}];

{
	_x setVariable ['titanSource', TITAN, true];	
} foreach TITANASSETS;

batchAddAttachments = {
	{
		[_x] call generateAttachments;
		if ((count attachedObjects _x) > 0) then {
			_x call batchAddAttachments;
		};
	} foreach attachedObjects _this;
};

TITAN call batchAddAttachments;

sLEEP 1;

if (!isDedicated) then {


	// _unit = "B_Soldier_F" createVehicle [0,0,0];
	// _unit setPosASL (TITAN modelToWorld [0.206909,-70.562,1.71262]);
	// _unit execVM 'initdummy.sqf';

	if (!_deployOnboard) exitWith {};

	[] spawn { 

		if (isServer) then {

			{
				_x setPosASL (TITAN modelToWorldVisual [0,-55,11]);
			} foreach allUnits;		
		};

	};

};

// [] SPAWN {
// 	Sleep 3;
// 	player setPosASL (TITAN modelToWorldVisual [0,-15,3]);

// 	Sleep 3;

// 	// _V1 = createVehicle ["B_HELI_LIGHT_01_F", getpos player, [], 0, "FLY"];  
// 	// _v1 enablesimulation false;  
// 	// _p = getposasl player; 
// 	// _p set [2, 58]; 
// 	// _v1 setPosASL _p;

	

// 	// // _V1 = createVehicle ["B_Plane_CAS_01_F", getpos player, [], 0, "FLY"];  
// 	// // _v1 enablesimulation false;  
// 	// // _p = getposasl player; 
// 	// // _p set [2, 48]; 
// 	// // _P SET [1, (_p select 1) - 35];
// 	// // _v1 setPosASL _p;





// 	// // _V2 = createVehicle ["C_SUV_01_F", getpos player, [], 0, "CAN_COLLIDE"];  
// 	// // _v2 enablesimulation false;  
// 	// // _p = getposasl player; 
// 	// // _p set [2, 48]; 
// 	// // _P SET [1, (_p select 1) - 10];
// 	// // _v2 setPosASL _p;

// 	// [_v1, _v1] SPAWN {
// 	// 	SLEEP 1;
// 	// 	{ _x enableSimulation true; } foreach _this;

// 	// 	player moveInDriver (_this select 1);
// 	// };


// 	//"b_heli_light_01_f" createvehicle (TITAN modelToWorldVisual [0,3,20]));

// };



_currentPos = getPosASL TITAN;
_currentDir =  getDir TITAN;
TITAN setVariable ['targetPosition', _currentPos];
TITAN setVariable ['engineSpeed', 0.005];
TITAN setVariable ['maxAltitude', (_currentPos select 2)];
_targetVel = TITAN getVariable ['_targetVel', [0,0.01,0.8]];

publicVariable "TITAN";

waitUntil {
	
	if (isNil "TITAN") exitWith { true };

	//Has target position changed?
	_targetPos = TITAN getVariable ['targetPosition', [0,0,0]];
	_speed = TITAN getVariable ['engineSpeed', 0.005];
	_altitude = TITAN getVariable ['maxAltitude', 40];
	_minAltitude = 20;
	_maxAltitude = 100;

	_verticalVelocity = if ((_currentPos select 2) < _altitude) then { 
		0.2
	} else { 0.1 };

	if (_targetPos distance _currentPos > 1) then {
		
		// Ensure targetposition height is set correctly
		_surfaceHeight = if (surfaceIsWater _targetPos) then { _altitude } else { ((getTerrainHeightASL [(_targetPos select 0), (_targetPos select 1)]) + _altitude) };
		_targetPos = [(_targetPos select 0), (_targetPos select 1), _surfaceHeight];
		TITAN setVariable ['targetPosition', _targetPos];

		// Alternative velocity method
		// _speed = 1;
		// _currentPos = (ASLtoATL visiblePositionASL TITAN);
		// _dir = ((_targetPos select 0) - (_currentPos select 0)) atan2 ((_currentPos select 1) - (_currentPos select 1));
		// _range = _currentPos distance _targetPos;
		// TITAN setVelocity [_speed * (sin _dir), _speed * (cos _dir), _verticalVelocity];	

		// Ease to new target position
		_vector = [_currentPos, _targetPos] call BIS_fnc_vectorFromXToY; 
		_targetPos set [2, ([(_targetPos select 2), _minAltitude, _maxAltitude] call limitToRange) ];
		_heightDif = [((_targetPos select 2) - (_currentPos select 2)) * 0.001, -0.006, 0.006] call limitToRange; // Minimum/Max ascent speed
		_currentPos = [(_currentPos select 0) + (_speed * (_vector select 0)), (_currentPos select 1) + (_speed * (_vector select 1)), (_currentPos select 2) + _heightDif];	

		// // Also adjust direction to new location
		// _dirTo = [ ([_currentPos, _targetPos] call dirTo) + 180] call normalizeAngle;
		// _currentDir = getDir TITAN;
		// _dirDif = [(_currentDir - _dirTo)] call flattenAngle;
		// if ( abs _dirDif > 2 ) then {
		// 	_currentDir = _currentDir + (_dirDif * -0.0001);
		// };

	} else {

		// TITAN setVelocity [0, 0, _verticalVelocity];	
		// Periodically shake craft
		// _increment = (sin (time* ((random 50) + 50))) * (0.002 + (random 0.001));
		// _targetPos set [2, (_targetPos select 2) + _increment]; 
		// _currentPos = _targetPos;			

	};
	
	// Set new pos/dir/vel
	if (getPosASL TITAN distance _currentPos > 0) then { TITAN setPosASL _currentPos; };
	if (abs ([_currentDir - getDir TITAN] call flattenAngle) > 0) then { TITAN setDir _currentDir;};
	if (((velocity TITAN) distance [0,0,0]) > 0) then { TITAN setVelocity [0,0,0]; };
	if (((vectorUp TITAN) distance [0,0,1]) > 0) then { TITAN setVectorUp [0,0,1]; };

	if (!isDedicated) exitWith { (!alive player || isNil "TITAN") };
		
	(isNil "TITAN")
};


{
	deleteVehicle _x;
} foreach TITANASSETS;


// // Right side
// {
// 	_att = "T2_CargoDoor_L" createVehicle (ASLtoATL visiblePositionASL TITAN);

// 	// _lastAttachmentPosition = (_lastAttached selectionPosition "AP2");
// 	_aPosition = (_att selectionPosition "AP1");
// 	// _boundingCenterAtt = (boundingCenter _att);
// 	// _boundingCenterLast =  (boundingCenter _lastAttached);

// 	// hint format['%1 : %2 / %3 : %4', _lastAttachmentPosition,  _boundingCenterLast, _attachmentPosition, _boundingCenterAtt]; 

// 	// _lastAttachmentPosition set [2, 0];


// 	// _att attachTo [_lastAttached, _position];

// 	_att attachTo [_lastAttached, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP2"]; 


// 	_lastAttached = _x;

// } foreach [		
// 	[0,0,0]
// ];



// TITAN = "T2_Bulkhead_01" createVehicle (player modelToWorld [0,20,0]);

// TITAN_OFFSET_Y = 11.23;
// TITAN_OFFSET_X = -10.225;

// // Right side
// {
// 	_att = "T2_Bulkhead_01" createVehicle (ASLtoATL visiblePositionASL TITAN);
// 	_att attachTo [TITAN, _x];
// 	_att enableSImulationGlobal false;
// 	_att disableCollisionWith TITAN;
// } foreach [		
// 	[0,TITAN_OFFSET_Y,0]
// ];

// // Left side
// {
// 	_att = "T2_Bulkhead_01" createVehicle (ASLtoATL visiblePositionASL TITAN);
// 	_att attachTo [TITAN, _x];

// 	_att setDir ([(getDir TITAN) + 180] call normalizeAngle);

// 	_att enableSImulationGlobal false;
// 	_att disableCollisionWith TITAN;


// } foreach [		
// 	[TITAN_OFFSET_X,0,0],
// 	[TITAN_OFFSET_X,TITAN_OFFSET_Y,0]
// ];

// // cARGO LEFT SIDE

// _att = "T2_CargoDoor_L" createVehicle (ASLtoATL visiblePositionASL TITAN);
// _att attachTo [TITAN, [TITAN_OFFSET_X,TITAN_OFFSET_Y*1.9,2.1]  ];

// _att setDir ([(getDir TITAN) + 180] call normalizeAngle);

// _att disableCollisionWith TITAN;

// removeAllActions player;


// _pos = getPos player;
// _pos set [2, 20];

// TITAN setPos _pos;

// player attachTo [TITAN, [0,0,1]]; // -1 for inner deck

// _offsetPos = TITAN worldToModelVisual (ASLtoATL visiblePositionASL player);

// TITAN setPos (player modelToWorld [0,0,10]);

// Sleep 1;

// detach player;



// player switchMove "";
	
// _timeout = time + 30;

// if (!simulationEnabled TITAN) then {	TITAN enableSimulationGlobal true; };

// waitUntil {

// 	if (animationState player == "halofreefall_non") then {	player switchMove ""; };

// 	_p = getPos TITAN;
// 	_p set [2, 20];

// 	TITAN setPos _p;

// 	(!alive player)
// };



