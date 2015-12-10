// _hasGroundCheck = player getVariable ['groundCheckEH', false];
// if (_hasGroundCheck) exitWith {};
waitUntil {
	(!isNil "clientCompileComplete" && !isNull player)
};

_this call playerRespawn;



// waitUntil {

// 	_p1 = ATLtoASL (player modelToWorldVisual [0,0,0]);
// 	_p2 = ATLtoASL (player modelToWorldVisual [0,0,-2]);

// 	_objs = lineIntersectsObjs [_p1, _p2, objNull, player];

// 	if (count _objs == 0) then {
// 		systemchat format["No titan %1", time];
// 	} else {

// 		_isTitan = false;
// 		{
// 			if ((objectParent _x) == TITAN || (_x == TITAN) || (attachedTo _x == TITAN)) exitWith { _isTitan = true; };
// 		} foreach _objs;

// 		if (_isTitan) exitWith {
// 			systemchat format["Onboard Titan %1", time];
// 		};
// 	};

// 	Sleep 3;

// 	(!alive player)

// };

// systemchat 'stopped';