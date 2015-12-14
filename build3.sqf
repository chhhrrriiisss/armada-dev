generateAttachments = {
	
	_target = [_this, 0, objNull, [objNull]] call filterParam;
	if (isNull _target) exitWith { false };

	_config = [
		[["Box_Nato_AmmoVeh_F", "Land_PaperBox_open_full_F", "Land_PaperBox_closed_F"], 10, "VAP", TRUE, 50, 20],
		[["Land_Cargo20_light_green_F", "Land_Cargo20_orange_F", "Land_Cargo20_sand_F"], 10, "CP", TRUE, 80, 20],
		["T2_Door_Standard", 10, "DP", TRUE, 100, 0]
	];

	_tagsToIgnore = _target getVariable ['TTN_DNA', []];

	{


		_classToUse = (_x select 0);
		_maxItems = (_x select 1);
		_tag = (_x select 2);
		_canRotate = (_x select 3);
		_chance = (_x select 4);
		_rotationVariance = (_x select 5);

		if (_tag in _tagsToIgnore) then {} else { 

			_arr = [];

			
			for "_i" from 1 to _maxItems step 1 do {

				_id = format['%1%2', _tag,_i];
				_pos = _target selectionPosition format['%1%2', _tag, _i];	

				if (_pos isEqualTo [0,0,0]) exitWith {};

				_dirPos = _target selectionPosition format['DP%1_DIR', _i];	
				_dirPos = if (_dirPos isEqualTo [0,0,0]) then { _pos } else { _dirPos };
				_dir = [([_pos, _dirPos] call dirTo) - 90] call normalizeAngle;

				if (_chance < random 100) then {} else {
					_arr pushBack [_id, _dir];
				};

			};


			{	

				_class = if (typename _classToUse == "ARRAY") then {
					(_classToUse call BIS_fnc_selectRandom)
				} else {
					_classToUse
				};

				_item = _class createVehicle [0,0,0];
				_item attachTo [_target,([0,0,0] vectorAdd (boundingCenter _item)), (_x select 0) ]; 
				TITANASSETS pushBack _item;

				if (!_canRotate) then {} else {


					[_item, ((_x select 1) + ((random _rotationVariance) - (_rotationVariance/2)))] spawn { 
						(_this select 0) setDir ([(getDir TITAN) + (_this select 1)] call normalizeAngle);	
					};		
				};
				
			} foreach _arr;

		};

	} foreach _config;



};







if (!isNil "TITAN") then {

	TITAN = nil;

	Sleep 2;


};

_addEngineSet = {	

	_timeout = time + 1;
	waitUntil {
		Sleep 0.1;
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
		




	};

	TITANASSETS pushBack _engine;
	TITANASSETS pushBack _engine2;

};

TITAN_ENGINES_ENABLED = [_this, 0, true, [false]] call filterParam;

_maxParts = 7;
_engineLocations = [0, _maxParts-1,_maxParts];
_upperLocations = [_maxParts, _maxParts-1, _maxParts-2];
_armoryLocations = [_maxParts];
_wallLocations = [1 , 3, 5];
_hangarLocations = [_maxParts-3];
_turretLocations = [_maxParts, 1];
_ventEntry = [_maxParts];

TITANASSETS = [];

TITAN = "T2_Bulkhead_C" createVehicle (getMarkerPos "titan_spawn");


TITAN setVariable ['TTN_DNA', ['CP']];
TITANASSETS pushBack TITAN;

_vent = "T2_Airvent_Straight" createVehicle [0,0,0];
_aPosition = (_vent selectionPosition "AP1");
_vent attachTo [TITAN, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP5"]; 
_vent attachTo [TITAN];
TITANASSETS pushBack _vent;


_engineRoom = "T2_EngineRoom_F" createVehicle [0,0,0];
_aPosition = (_engineRoom selectionPosition "AP2");
_engineRoom attachTo [TITAN, [(_aPosition SELECT 0), (_aPosition select 1), (_aPosition select 2) * -1], "AP1"]; 
_engineRoom setDir ([(getDir TITAN) + 180] call normalizeAngle);	


TITANASSETS pushBack _engineRoom;



_left = "T2_Bulkhead_01" createVehicle (getMarkerPos "titan_spawn");
_aPosition = (_left selectionPosition "AP4");
_left attachTo [TITAN, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP3"]; 

_right = "T2_Bulkhead_01" createVehicle (getMarkerPos "titan_spawn");
_aPosition = (_right selectionPosition "AP3");
_right attachTo [TITAN, [(_aPosition SELECT 0) * -1, (_aPosition select 1), (_aPosition select 2) * -1], "AP4"]; 
_right setDir ([(getDir _left) + 180] call normalizeAngle);	

TITANASSETS pushBack _left;
TITANASSETS pushback _right;


_centreAsset = "T2_Bulkhead_C";
_centre = _centreAsset createVehicle [0,0,0];
_aPosition = (_centre selectionPosition "AP2");
_centre attachTo [TITAN, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP1"]; 
_centre attachTo [TITAN];
TITANASSETS pushBack _centre;

_engineRoom = "T2_EngineRoom_F" createVehicle [0,0,0];
_aPosition = (_engineRoom selectionPosition "AP2");
_engineRoom attachTo [_centre, [(_aPosition SELECT 0), (_aPosition select 1), (_aPosition select 2) * -1], "AP1"]; 
_engineRoom setDir ([(getDir TITAN)] call normalizeAngle);	
TITANASSETS pushBack _engineRoom;

//
_left = "T2_Bulkhead_01" createVehicle [0,0,0];
_aPosition = (_left selectionPosition "AP4");
_left attachTo [_centre, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP3"]; 
TITANASSETS pushBack _left;

_right = "T2_Bulkhead_01" createVehicle [0,0,0];
_aPosition = (_right selectionPosition "AP3");
_right attachTo [_centre, [(_aPosition SELECT 0) * -1, (_aPosition select 1), (_aPosition select 2) * -1], "AP4"]; 
_right setDir ([(getDir _left) + 180] call normalizeAngle);
TITANASSETS pushBack _right;


waitUntil {
	( (!isNull attachedTo _left) && (!isNull attachedTo _right) && (!isNull attachedTo _centre) )
};

_centreAsset = "T2_Bulkhead_C";
_centre2 = _centreAsset createVehicle [0,0,0];
_aPosition = (_centre2 selectionPosition "AP2");
_centre2 attachTo [_centre, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP1"]; 
_centre2 attachTo [TITAN];
TITANASSETS pushBack _centre2;


_left = "T2_Bulkhead_01" createVehicle [0,0,0];
_aPosition = (_left selectionPosition "AP4");
_left attachTo [_centre2, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP3"]; 
TITANASSETS pushBack _left;

_right = "T2_Bulkhead_01" createVehicle [0,0,0];
_aPosition = (_right selectionPosition "AP3");
_right attachTo [_centre2, [(_aPosition SELECT 0) * -1, (_aPosition select 1), (_aPosition select 2) * -1], "AP4"]; 
_right setDir ([(getDir _left) + 180] call normalizeAngle);
TITANASSETS pushBack _right;


waitUntil {
	( (!isNull attachedTo _left) && (!isNull attachedTo _right) && (!isNull attachedTo _centre) )
};

_centreAsset = "T2_Bulkhead_C";
_centre3 = _centreAsset createVehicle [0,0,0];
_aPosition = (_centre3 selectionPosition "AP2");
_centre3 attachTo [_centre2, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP1"]; 
_centre3 attachTo [TITAN];
TITANASSETS pushBack _centre2;


_left = "T2_Bulkhead_01" createVehicle [0,0,0];
_aPosition = (_left selectionPosition "AP4");
_left attachTo [_centre3, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP3"]; 
TITANASSETS pushBack _left;

_right = "T2_Bulkhead_01" createVehicle [0,0,0];
_aPosition = (_right selectionPosition "AP3");
_right attachTo [_centre3, [(_aPosition SELECT 0) * -1, (_aPosition select 1), (_aPosition select 2) * -1], "AP4"]; 
_right setDir ([(getDir _left) + 180] call normalizeAngle);
TITANASSETS pushBack _right;



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

	if (_i in _turretLocations) then { _asset = "T2_Bulkhead_Turret_L"; };

	_centreAsset = if (_i in _ventEntry) then { "T2_Bulkhead_C_VentAccess" } else { "T2_Bulkhead_C" };
	_centre = _centreAsset createVehicle [0,0,0];
	_aPosition = (_centre selectionPosition "AP1");
	_centre attachTo [_lastAttached, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP2"]; 
	_centre attachTo [TITAN];
	TITANASSETS pushBack _centre;
	_lastAttached = _centre;


	_ventAsset = if (_i in _ventEntry) then { "T2_Airvent_Entry" } else { "T2_Airvent_Straight" };
	_vent = _ventAsset createVehicle [0,0,0];
	_aPosition = (_vent selectionPosition "AP1");
	_vent attachTo [_centre, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP5"]; 
	_vent attachTo [TITAN];
	TITANASSETS pushBack _vent;

	_left = _asset createVehicle [0,0,0];
	_aPosition = (_left selectionPosition "AP4");
	_left attachTo [_centre, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP3"]; 
	_left attachTo [TITAN];
	TITANASSETS pushBack _left;

	_asset = (random 100) call {
		if (_this > 50) exitWith {
			"T2_Bulkhead_01"
		};		
		"T2_Bulkhead_Stairs_L"
	};

	if (_i in _turretLocations) then { _asset = "T2_Bulkhead_Turret_L"; };

	_right = _asset createVehicle [0,0,0];
	_aPosition = (_right selectionPosition "AP3");
	_right attachTo [_centre, [(_aPosition SELECT 0) * -1, (_aPosition select 1), (_aPosition select 2) * -1], "AP4"]; 
	_right attachTo [TITAN];
	_right setDir ([(getDir TITAN) + 180] call normalizeAngle);	
	TITANASSETS pushback _right;	


	if (_i in _turretLocations) then { 

		_turret = "T2_Turret_80mm" createVehicle [0,0,0];
		_aPosition = (_turret selectionPosition "AP1");
		_turret attachTo [_left, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "TP1"]; 
		_turret attachTo [TITAN];
		TITANASSETS pushback _turret;

		_turret = "T2_Turret_80mm" createVehicle [0,0,0];
		_aPosition = (_turret selectionPosition "AP1");
		_turret attachTo [_right, [(_aPosition SELECT 0) * -1, (_aPosition select 1), (_aPosition select 2) * -1], "TP1"]; 
		_turret setDir ([(getDir TITAN) + 180] call normalizeAngle);	
		TITANASSETS pushback _turret;

	};

	if (_i in _wallLocations) then {

		_timeout = time + 3;
		waitUntil {
			Sleep 0.1;
			( (!isNull attachedTo _centre) && (!isNull attachedTo _left) && (!isNull attachedTo _right) || time > _timeout)
		};
		_wall = "T2_Wall_CargoNet_C" createVehicle [0,0,0];
		_aPosition = (_wall selectionPosition "AP1");
		_wall attachTo [_centre, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP2"]; 
		_wall attachTo [TITAN];
		TITANASSETS pushBack _wall;

		_leftWall = "T2_Wall_CargoNet_01" createVehicle [0,0,0];
		_aPosition = (_leftWall selectionPosition "AP1");
		_leftWall attachTo [_left, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP2"]; 
		_leftWall attachTo [TITAN];
		TITANASSETS pushBack _leftWall;
		_rightWall = "T2_Wall_CargoNet_01" createVehicle [0,0,0];
		_aPosition = (_rightWall selectionPosition "AP2");
		_rightWall attachTo [_right, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP2"]; 
		_rightWall attachTo [TITAN];
		_rightWall setDir ([(getDir TITAN) + 180] call normalizeAngle);
		TITANASSETS pushBack _rightWall;
	};


	_timeout = time + 3;
	waitUntil {
		Sleep 0.1;
		( (!isNull attachedTo _centre) && (!isNull attachedTo _left) && (!isNull attachedTo _right) || time > _timeout)
	};
	
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

			
			_timeout = time + 3;
			waitUntil {
				Sleep 0.1;
				( (!isNull attachedTo _rightUpper) && (!isNull attachedTo _leftUpper) || time > _timeout)
			};

			_armory = "T2_BulkheadMid_Armory_R" createVehicle [0,0,0];

			_aPosition = (_armory selectionPosition "AP2");

			_armory attachTo [_rightUpper, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2)*-1], "AP3"]; 
			_armory attachTo [TITAN];
			TITANASSETS pushBack _armory;

		};

		

	};

	if (_i in _hangarLocations) then {
		_hangar = "T2_HangarDoor_L" createVehicle [0,0,0];
		_aPosition = (_hangar selectionPosition "AP1");	

		_hangar attachTo [_left, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP5"]; 
		_hangar attachTo [TITAN];



		TITANASSETS pushBack _hangar;
	};


	if (_i in _engineLocations) then {
		[_left, _right] spawn _addEngineSet;
	};
	
	

};


_cargo = "T2_CargoDoor_L" createVehicle [0,0,0];
_aPosition = (_cargo selectionPosition "AP1");
_cargo attachTo [_left, [(_aPosition SELECT 0) * -1, (_aPosition select 1) * -1, (_aPosition select 2) * -1], "AP2"]; 
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

	[] spawn { 
		Sleep 1;
		player setPosASL (TITAN modelToWorldVisual [0,-15,15]);
	};

};



_currentPos = getPosASL TITAN;
_currentDir =  getDir TITAN;
TITAN setVariable ['targetPosition', _currentPos];
TITAN setVariable ['engineSpeed', 0.005];
TITAN setVariable ['maxAltitude', (_currentPos select 2)];
_targetVel = TITAN getVariable ['_targetVel', [0,0.01,0.8]];

publicVariable "TITAN";

waitUntil {
	
	if (isNil "TITAN") exitWith { true };

	_targetPos = TITAN getVariable ['targetPosition', [0,0,0]];
	_speed = TITAN getVariable ['engineSpeed', 0.005];
	_altitude = TITAN getVariable ['maxAltitude', 40];
	_minAltitude = 20;
	_maxAltitude = 100;



	if (_targetPos distance _currentPos > 1) then {
		

		_surfaceHeight = if (surfaceIsWater _targetPos) then { _altitude } else { ((getTerrainHeightASL [(_targetPos select 0), (_targetPos select 1)]) + _altitude) };
		_targetPos = [(_targetPos select 0), (_targetPos select 1), _surfaceHeight];
		TITAN setVariable ['targetPosition', _targetPos];


		_vector = [_currentPos, _targetPos] call BIS_fnc_vectorFromXToY; 
		_targetPos set [2, ([(_targetPos select 2), _minAltitude, _maxAltitude] call limitToRange) ];
		_heightDif = [((_targetPos select 2) - (_currentPos select 2)) * 0.001, -0.006, 0.006] call limitToRange; // Minimum/Max ascent speed
		_currentPos = [(_currentPos select 0) + (_speed * (_vector select 0)), (_currentPos select 1) + (_speed * (_vector select 1)), (_currentPos select 2) + _heightDif];	

		_dirTo = [ ([_currentPos, _targetPos] call dirTo) + 180] call normalizeAngle;
		_currentDir = getDir TITAN;
		_dirDif = [(_currentDir - _dirTo)] call flattenAngle;
		if ( abs _dirDif > 2 ) then {
			_currentDir = _currentDir + (_dirDif * -0.0001);
		};

	} else {

		_increment = (sin (time* ((random 50) + 50))) * (0.002 + (random 0.001));
		_targetPos set [2, (_targetPos select 2) + _increment]; 
		_currentPos = _targetPos;			

	};
	
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
