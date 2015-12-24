if (!isNil "BIS_DEBUG_CAM") then {
	camDestroy BIS_DEBUG_CAM;
};

// inGameUISetEventHandler['PrevAction', 'true'];
// inGameUISetEventHandler['NextAction', 'true'];
// inGameUISetEventHandler['Action', 'true'];

// _position = (ASLtoATL visiblePositionASL player);

// EDIT_CAMERA = "camera" camCreate _position;

// player attachTo [EDIT_CAMERA, [0,2,0]];

// EDIT_TARGET = "Land_Portable_generator_F" createVehicle [0,0,0];
// EDIT_TARGET setPos (player modelToWorldVisual [0,3,0]);
// EDIT_TARGET attachTo [player];

// BIS_DEBUG_CAM camSetTarget (BIS_DEBUG_CAM modelToWorldVisual [0,2,0]);
// EDIT_CAMERA cameraeffect["internal","back"];
// EDIT_CAMERA camCommit 0;

_this call bis_fnc_cameraOld;

waitUntil {	
	(!isNil "BIS_DEBUG_CAM")
};

UNDO_LOG = [];
REDO_LOG = [];

EDITING_OBJECT = false;
if (isNil "SNAPPING_ENABLED") then {
	SNAPPING_ENABLED = false;
};

cameraActions = {	
		
	_key = (_this select 1);
	_shift = _this select 2; 
	_ctrl = _this select 3; 
	_alt = _this select 4; 

	//32 r
	// 30 l
	// 17 u
	// 31 d

	if (_ctrl && _key == ('S' call stringToCode)) exitWith {
		['Test'] execVM 'save.sqf';
	};

	if (_ctrl && _key == ('O' call stringToCode)) exitWith {
		['Test'] execVM 'load.sqf';
	};

	if (_key == ('T' call stringToCode)) exitWith {
		SNAPPING_ENABLED = !SNAPPING_ENABLED;
		if (SNAPPING_ENABLED) then { systemchat 'Snapping enabled!'; } else { systemchat 'Snapping disabled!'; };\

		false
	};

	if (_key == ('R' call stringToCode) && EDITING_OBJECT) exitWith {

		CANCEL_EDITING = TRUE;
		EDITING_OBJECT = false;

		false
	};

	if ((_key == ('C' call stringToCode) || _key == ('X' call stringToCode)) && EDITING_OBJECT) exitWith {

		_increment = 90;

	 	if (_shift) then {_increment = 45; };
	 	if (_ctrl) then {_increment = 15; };
	 	if (_alt) then {_increment = 5; };

	 	if (_key == ('X' call stringToCode)) then { _increment = _increment * -1; };
	
		EDITING_OBJECT_DIR = [EDITING_OBJECT_DIR + _increment] call normalizeAngle;

		false
	};	

	if ( _ctrl && _key == ('X' call stringToCode) && count REDO_LOG > 0) exitWith {

		_lastObject = REDO_LOG select ((count REDO_LOG) -1);

		_lastObject hideObject true;	

		REDO_LOG deleteAt (REDO_LOG find _lastObject);
		UNDO_LOG pushback _lastObject;

		false

	};

	if ( _ctrl && _key == ('Z' call stringToCode) && count UNDO_LOG > 0) exitWith {

		_lastObject = UNDO_LOG select ((count UNDO_LOG) -1);

		_lastObject hideObject false;

		UNDO_LOG deleteAt (UNDO_LOG find _lastObject);
		REDO_LOG pushback _lastObject;

		false

	};

	if ( _key == ('End' call stringToCode) ) exitWith {

		_intersects = lineIntersectsWith [ATLtoASL (positionCameraToWorld [0,0,-4]), ATLtoASL (positionCameraToWorld [0,0,75]), BIS_DEBUG_CAM, objNull, true];

		if (count _intersects == 0) exitWith { false };
		if ((_intersects SELECT 0) == TITAN) exitWith { false };

		_selectedObject = (_intersects select ((count _intersects) -1));

		//deleteVehicle _selectedObject;
		UNDO_LOG pushback _selectedObject;
		_selectedObject hideObject true;

		false

	};

	if ( (_key == ('E' call stringToCode) || _key == ('C' call stringToCode)) ) exitWith {

		if (EDITING_OBJECT) exitWith { EDITING_OBJECT = false; false };

		EDITING_OBJECT = true;
		CANCEL_EDITING = false;

		_isCopy = if (_key == ('C' call stringToCode)) then { true } else { false };

		_intersects = lineIntersectsWith [ATLtoASL (positionCameraToWorld [0,0,-4]), ATLtoASL (positionCameraToWorld [0,0,75]), BIS_DEBUG_CAM, objNull, true];

		if (count _intersects == 0) exitWith { false };
		if ((_intersects SELECT 0) == TITAN) exitWith { false };

		_selectedObject = (_intersects select ((count _intersects) -1));

		if (_isCopy) then {

			_class = typeof _selectedObject;
			_worldPos = getPosWorld _selectedObject;

			_selectedObject = _class createVehicle [0,0,0];
			_selectedObject setPosWorld _worldPos;
			_selectedObject attachTo [TITAN];

		};

		[_selectedObject, _isCopy] spawn {

			_isCopy = _this select 1;
			_this = _this select 0;

			systemchat format["%1", typeof _this];

			_savedPos = visiblePositionASL _this;
			_savedDir = getDir _this;
			EDITING_OBJECT_DIR = _savedDir;
			_savedVector = vectorUp _this;

			detach _this;

			_this enableSimulation false;

			waitUntil {
				isNull attachedTo _this
			};	

			_distance = BIS_DEBUG_CAM distance _this;
			_timeout = time + 999;

			_findAttachmentPoints = {

				private ['_this', '_aps', '_pos'];

				_aps = [];

				for "_i" from 1 to 20 step 1 do {
					_id = format['%1%2', 'AP',_i];
					_pos = _this selectionPosition format['%1%2', 'AP', _i];
					if (_pos isEqualTo [0,0,0]) exitWith {};				
					_aps pushBack _pos;
				};

				_aps

			};

			_this enableSimulation false;
			waitUntil {
				!simulationEnabled _this
			};

			waitUntil {

				_targetPos = (AGLtoASL positionCameraToWorld [0,0,_distance]);
				_snappedPos = nil;

				if (SNAPPING_ENABLED) then {				
					
					_nearbyObjects = nearestObjects [visiblePositionASL _this, ["All"], 20];
					if (count _nearbyObjects == 0) exitWith {};

					_nearbyAPS = [];

					{
						if (_x == _this) then {

							_nearbyObjects deleteAt _forEachIndex;

						} else {

							systemchat format['%1', typename _x];

							_nearbyObjects set [_forEachIndex, visiblePositionASL _x];

							// Find all APS
							for "_i" from 1 to 10 step 1 do {

								_id = format['%1%2', 'AP',_i];
								_pos = _x selectionPosition format['%1%2', 'AP', _i];	
								if (_pos isEqualTo [0,0,0]) exitWith {};

								_nearbyAPS pushback (AGLtoASL (_x modelToWorldVisual _pos));
							};
						};

					} foreach _nearbyObjects;

					_nearbyObjects append _nearbyAPS;
					
		
					_currentPos = AGLtoASL positionCameraToWorld [0,0,_distance];
					//_currentPos = getPosWorld _this;

					_closestX = [9999, (_currentPos select 0)];
					_closestY = [9999, (_currentPos select 1)];
					_closestZ = [9999, (_currentPos select 2)];			
				
					{
						_vP = if (_x isEqualType objNull) then { visiblePositionASL _x } else { _x };

						{
							_index = _x select 0;
							_tolerance = _x select 1;
							_dif = abs ((_vP select _index) - (_currentPos select _index));
							if (_dif < _tolerance && _dif < ((_x select 2) select 0)) then {
								(_x select 2) set [0, _dif];
								(_x select 2) set [1, (_vP select _index)];
							};
						} foreach [
							[0, 1, _closestX],
							[1, 1, _closestY],
							[2, 1, _closestZ]
						];					
				
					} foreach _nearbyObjects;

					_targetPos set [0, (_closestX select 1)];
					_targetPos set [1, (_closestY select 1)];
					_targetPos set [2, (_closestZ select 1)];
		
				};

				_this setPosASL _targetPos;
				_this setVectorUp _savedVector;
				_this setDir EDITING_OBJECT_DIR;

				(time > _timeout) || !EDITING_OBJECT
			};

			_this enableSimulation true;

			waitUntil {
				simulationEnabled _this
			};

			if (CANCEL_EDITING && _isCopy) exitWith {
				deleteVehicle _this;
			};

			if (CANCEL_EDITING) then {
				_this setPosASL _savedPos;
				EDITING_OBJECT_DIR = _savedDir;
			};



			_this attachTo [TITAN];

			waitUntil {
				!isNull attachedTo _this
			};			

			_this setVectorUp _savedVector;
			_this setDir EDITING_OBJECT_DIR;

			_this enableSimulation true;

		};

	};

	false
};

if (!isNil "KD_EH") then { (findDisplay 46) displayRemoveEventHandler ["KeyDown", KD_EH]; };
KD_EH = (findDisplay 46) displayAddEventHandler ["KeyDown", "_this call cameraActions; false"];

// mouseActions = {
	
	

// };

// if (!isNil "MBD_EH") then { (findDisplay 46) displayRemoveEventHandler ["MouseButtonDown", MBD_EH]; };
// MBD_EH = (findDisplay 46) displayAddEventHandler ["MouseButtonDown", "systemchat format['%1', _this]; false"];

_timeout = time + 99999;
waitUntil {	
	((time > _timeout) || (isNil "BIS_DEBUG_CAM"))
};

if (EDITING_OBJECT) then { EDITING_OBJECT = false; CANCEL_EDITING = true; };

player cameraeffect["terminate","back"];
(findDisplay 46) displayRemoveEventHandler ["KeyDown", KD_EH]; 
(findDisplay 46) displayRemoveEventHandler ["MouseButtonDown", MBD_EH];
KD_EH = nil;
MBD_EH = nil;
// detach player;
// deleteVehicle EDIT_TARGET;




// _timeout = time + GW_RESPAWN_DELAY;

// // Initialize the camera based on type requested
// switch (_type) do {
	
// 	case "nukefocus":
// 	{
// 		profileNamespace setVariable ['killedByNuke', []];
// 		saveProfileNamespace;

// 		_cam camSetTarget _targetPosition;
// 		_cam cameraeffect["internal","back"];
// 		_cam camCommit 0;


// hint format['%1', nearestObjects [(positionCameraToWorld [0,0,0]), ["All"], 5]];
