private ['_varToAssign', '_minTimeout', '_timeNeeded', '_canUse', '_varExists'];

_varToAssign = _this select 0;
_minTimeout = _this select 1;
_timeNeeded = time - _minTimeout;

if (isNil "TTN_floodVars") then { TTN_floodVars = []; };

// Does this var already exist?
_varExists = false;
_canUse = false;
{	
	// If var exists, check minTimeout vs currentTime
	if ((_x select 0) == _varToAssign) exitWith { 
		_varExists = true;

		// If the needed time is less than the expected time, delete entry and allow
		if ((_x select 1) - _timeNeeded >= 0) exitWith { TTN_floodVars deleteAt _foreachIndex; _canUse = true; };	
	};
} foreach TTN_floodVars;

if (_varExists) exitWith {
	_canUse
};

// Variable doesn't exist yet, create a timeout for it
TTN_floodVars pushback [_varToAssign, (time + _minTimeout)];

false

