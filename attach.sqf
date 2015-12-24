// if (!isNil "attachHandler") then {
// 	attachHandler = nil;
// };

_target = [_this, 0, objNull, [objNull]] call filterParam;


if (isNull _target) then {
	_target = player;
};

_target allowDamage false;

_target setVariable ['TTN_attachPoint', TITAN worldToModelVisual (ASLtoATL VISIBLEPOSITIONASL _target)];	
_target setVariable ['TTN_allowAttach', true];

attachHandler = true;

ATTACH_KD_EH = (findDisplay 46) displayAddEventHandler ["KeyDown", "_this call deferAttachUpdate; false;"];
ATTACH_KU_EH = (findDisplay 46) displayAddEventHandler ["KeyUp", "_this, call updateAttachPoint; false;"];

getMovementKeys = {

	_arr = [];
	{
		_arr append (actionKeys _x);
		false
	} count [
		"MoveForward",
		"MoveBack",
		"MoveLeft",
		"MoveRight",
		"EvasiveLeft",		
		"EvasiveRight",
		"TurnLeft",
		"TurnRight",
		"EvasiveBack"
	];

	_arr
};

deferAttachUpdate = {	
	
	_key = _this select 1;
	_movementKeys = call getMovementKeys;
	if !(_key in _movementKeys || _key == -1) exitWith { false };

	_isAllowed = player getVariable ['TTN_allowAttach', true];
	if (_isAllowed) then { 

		player setVariable ['TTN_allowAttach', false];

		[] spawn {

			waitUntil {

				// _titanVel = (velocity TITAN);
				// _titanVel = [_titanVel, 2] call bis_fnc_vectorMultiply;
				// _playerVel = (velocity player) vectorAdd _titanVel;
				// player setVelocity _playerVel;


				// _velocity = [(velocity TITAN), 1] call bis_fnc_vectorMultiply;
				// player setVelocity _velocity;

				// if (isNil "TITAN") exitWith { true };
				// _speed = [(velocity player) distance [0,0,0], 0, 1] call limitToRange;

				// if (_speed > ((velocity TITAN) distance [0,0,0])) exitWith { false };

				// _currentPos = (ASLtoATL visiblePositionASL TITAN);
				// _targetPos = TITAN getVariable ['targetPosition', _currentPos];
				// _dir = [_currentPos, _targetPos] call dirTo;
				// _vel = velocity player;
				// player setVelocity [(_vel select 0)+(sin _dir*_speed),(_vel select 1)+(cos _dir*_speed),(_vel select 2)];	

				hint format['%1', velocity player];

				_isAllowed = player getVariable ['TTN_allowAttach', false];
				_isAllowed
			};

		};

	};

	false
};

updateAttachPoint = {	
	
	//hint format['%1', _this];
	_key = _this select 1;
	_movementKeys = call getMovementKeys;
	if !(_key in _movementKeys || _key == -1) exitWith { false };

	_attachPoint = TITAN worldToModelVisual (ASLtoATL VISIBLEPOSITIONASL player);	

	_offset = _key call {
		if (_this in actionKeys "MoveForward") exitWith { [0,0.75,0] };
		if (_this in (actionKeys "MoveBack" + actionKeys "EvasiveBack")) exitWith { [0,-0.5,0] };
		[0,0,0]
	};

	_attachPoint = TITAN worldToModelVisual (player modelToWorldVisual _offset);	


	player setVariable ['TTN_attachPoint', _attachPoint];	
	player setVariable ['TTN_allowAttach', true];



	false
};

_timeout = time + 120;


// TTN_lastAttachUpdate = time - TTN_attachUpdateFrequency;



[nil, -1] call updateAttachPoint;

systemchat format['Started attach %1', time];

waitUntil {

	
	//hint format['%1', animationState player];
	if ((animationState _target) in ["halofreefall_non", "afalpercmstpsraswrfldnon"]) then { _target switchMove ""; };

	if (isNIl "TITAN") exitWith { true };

	_isAllowed = _target getVariable ['TTN_allowAttach', false];

	// hint format['%1', (time - TTN_lastAttachUpdate)];

	if (!_isAllowed) exitWith { false };

	systemchat format['Running attach %1 / %2', time, name _target];

	_attachPoint = _target getVariable ['TTN_attachPoint', [0,0,0]];

	

	_targetPos = TITAN modelToWorldVisual _attachPoint;	
	_playerPos = (ASLtoATL visiblePositionASL _target);

	_speed = [(_targetPos distance _playerPos) * 3, 0, 1] call limitToRange;

	_dir = ((_targetPos select 0) - (_playerPos select 0)) atan2 ((_targetPos select 1) - (_playerPos select 1));
	_range = _playerPos distance _targetPos;

	_target setVelocity [_speed * (sin _dir), _speed * (cos _dir), -1.5];	

	(time > _timeout)

};

systemchat format['Stopped attach %1', time];