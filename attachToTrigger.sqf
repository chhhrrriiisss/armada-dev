player allowDamage false;

removeAllActions player;

PLAYER addAction ['Toggle attachment', {	
	_enabled = player getVariable ['attachmentEnabled', false];
	player setVariable ['attachmentEnabled', !_enabled];
}];

if (isNil "TITAN") then { TITAN = player };
	

PLAYER addAction ['Set position', {	
	_p = (screenToWorld[0.5,0.5]);
	_height = [(_p select 2), 40, 9999] call limitToRange;
	_p set [2, _height];
	TITAN setPos _p;
}];

PLAYER addAction ['Set target', {	
	TITAN setVariable ['targetPosition',screenToWorld[0.5, 0.5], true ];
}];

PLAYER addAction ['Increase speed', {	
	_spd = TITAN getVariable ['engineSpeed',0.01];
	TITAN setVariable ['engineSpeed', (_spd + 0.005), true ];
}];

PLAYER addAction ['Decrease speed', {	
	_spd = TITAN getVariable ['engineSpeed',0.01];
	TITAN setVariable ['engineSpeed', (_spd - 0.005), true];
}];

PLAYER addAction ['Raise altitude', {	
	_alt = TITAN getVariable ['maxAltitude', 40];
	TITAN setVariable ['maxAltitude', (_alt + 2), true];
}];

PLAYER addAction ['Lower altitude', {	
	_alt = TITAN getVariable ['maxAltitude', 40];
	TITAN setVariable ['maxAltitude', (_alt - 2), true];
}];

PLAYER addAction ['Drop pod', {	
	[(screenTOwORLD [0.5, 0.5])] execVM 'droppod.sqf';
}];

PLAYER addAction ['Start Engines', {	
	_engines = TITAN getVariable ['engines', []];
}];

PLAYER addAction ['Stop Engines', {	
	
	_engines = TITAN getVariable ['engines', []];

}];

PLAYER addAction ['Camera', {	
	[] execVM 'camera.sqs'; 
}];

_sleepPeriod = 1;
_lastTitanCheck = time - _sleepPeriod;
_targetTitan = objNull;

ATWM_array = [
	player,
	player,
	visiblePositionASL player,
	getDir player
];

hint 'started loop';

waitUntil {
	

		if ((time - _lastTitanCheck) < _sleepPeriod) then {} else {

			// If we're in the titan (turret, console) abort using attach
			_titanSource = (vehicle player) getVariable ['titanSource', nil];
			if (!isNil "_titanSource") exitWith { _targetTitan = nil; };

			//systemchat format['running check %1', time];
			_lastTitanCheck = time;

			_p1 = getPosASL player;
			_p2 = +_p1;
			_p1 set [2, (_p1 select 2) + 2];
			_p2 set [2, (_p2 select 2) - 2];

			_objs = lineIntersectsObjs [_p1, _p2, objNull, player];	

			//systemchat format['%1', _objs];

			if (count _objs == 0) then {
				//systemchat format["No titan %1", time];
				_targetTitan = nil;

			} else {

				_isTitan = false;
				{			
					_isTitan = [_x, TITAN] call isAttachedTo;
					if (_isTitan) exitWith {};
				} foreach _objs;

				if (!_isTitan) exitWith {
					//systemchat format["No titan (but objects present) %1", time];	
					_targetTitan = nil;
				};

				//systemchat format["Onboard Titan %1", time];

				_targetTitan = TITAN;	
				player disableCOllisionWith _targetTitan;

				ATWM_array = [
					player,
					_targetTitan,
					visiblePositionASL _targetTitan,
					getDir _targetTitan
				];				
			};

		};

		_attachmentEnabled = player getVariable ['attachmentEnabled', false];
		if (isNil "_targetTitan" || !_attachmentEnabled) then {} else {

			//hint format['running attachTo %1', time];

			// AttachTOWithMovement

			if ((animationState player) in ["halofreefall_non", "afalpercmstpsraswrfldnon"]) then {	player switchMove ""; };

			_attachThis = (vehicle player);
			_attachTo   = _targetTitan;
			
			_posPrv = ATWM_array select 2;
			_dirPrv = ATWM_array select 3;
			
			_posNow = visiblePositionASL _attachTo;
			_dirNow = getDir _attachTo;

			_vel = velocity _attachThis;
			_attachThis setVelocity [
				(_vel select 0) * 0.5,
				(_vel select 1) * 0.5,
				(_vel select 2) - 1.5
			];
				
			_attachThis setPosASL (
				[
					_posNow, 
					[
						[
							_posNow, 
							visiblePositionASL _attachThis
						] call BIS_fnc_vectorDiff,
						_dirPrv - _dirNow
					] call BIS_fnc_rotateVector2D,
					[_posPrv, _posNow] call BIS_fnc_vectorDiff
				] call vectorsAdd
			);

			_attachThis setDir (getDir _attachThis + _dirNow - _dirPrv);
			
			ATWM_array set [2, +_posNow];
			ATWM_array set [3, +_dirNow];

		};

		(!alive player)
	

};


hint 'ended checks....';
