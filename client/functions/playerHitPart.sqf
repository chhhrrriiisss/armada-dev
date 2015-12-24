//systemchat format['hitpart %1', time];

if (true) exitWith {};

_unit = (_this select 0) select 0;
_bullet = (_this select 0) select 2;

_selection = (_this select 0) select 5;
hint format['%1', _selection];

_startPos = (visiblePositionASL _bullet);
_vectorUp = vectorDir _bullet;
_vector = [_vectorUp, 100] call bis_fnc_vectorMultiply;
_endPos = _vector vectorAdd _startPos;

//hint format['%1 / %2', _startPos, _endPos];

[[ASLtoAGL _startPos, ASLtoAGL _endPos], 1] spawn debugLine;

// _intersectsObjs = lineIntersectsWith [_startPos, _endPos, _unit, objNull, true, 2];
// if (count _intersectsObjs == 0) exitWith {};

// hint format['%1', _intersectsObjs];

// _hitUnit = if ((_intersectsObjs select 0) isKindOf "Man") then { true } else { false };

// if !(_hitUnit) exitWith {};

// systemchat format['Hit unit %1', time];

_intersectsSurfaces = lineIntersectsSurfaces [_startPos, _endPos, _unit, objNull, true, 2];

// Second intersect point is the second object

_surface = nil;
{
	
	if ((_x select 2) isKindOf "static" || (_x select 2) isKindOf "thing" ) exitWith {
		_surface = (_intersectsSurfaces select _forEachIndex);
	};
} FOREACH _intersectsSurfaces;

if (isnil "_surface") exitWith {};

hint format['surface: %1', typeof (_surface select 2)];

_surfaceIntersect = (_surface select 0);
// _surfaceIntersect set [2, (_surfaceIntersect select 2)];
_surfaceNormal = (_surface select 1);

// _surfaceNormalPitch = if ((_surfaceNormal distance [0,0,1]) < 0.5) then {
// 	456
// } else { 0 };

_surfaceNormalPitch = 30;

_surfaceObject = (_surface select 2);

// _actualDir = [90 + getDir _surfaceObject] call normalizeAngle;

// _surfaceIntersect = [_surfaceIntersect, 2, getDir _surfaceObject] call relPos;


_splatters = [];

{

	_surfaceDir = [(getDir _surfaceObject) + (_x select 1), 0, _surfaceNormalPitch] call dirToVector;
	_surfacePos = [_surfaceIntersect, (_x select 0), getDir _surfaceObject] call relPos;

	_sp = "UserTexture1m_F" createVehicleLocal _surfaceIntersect; 
	//_sp setPosASL _surfacePos;
	_sp setPosASL _surfaceIntersect;
	// _sp setVectorDirAndUp [_surfaceDir, _surfaceNormal];
	_sp setVectorUp _surfaceNormal;

	_sp setObjectTexture [0,MISSION_ROOT + "client\images\splatter2.paa"];
	_splatters pushback _sp;
	
} foreach [[-0.07, 0], [0.01, 180] ];

// _splatter attachTo [_surfaceObject];

// _splatter setVectorDirAndUp [_surfaceDir, _surfaceNormal];


_splatters spawn {
	Sleep 60;
	{ deleteVehicle _x; } foreach _this;
};


