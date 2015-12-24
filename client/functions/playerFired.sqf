
if (true) exitWith {};
	
_maxRange = 40;
_maxTrigger = 1;

if !(["TTN_lastFired", _maxTrigger] call floodControl) exitWith {};

// systemchat format['Fired 2: %1', time];

// _muzzlePos = (visiblePositionASL (_this select 6));
// _endPos = (visiblePositionASL (_this select 6));

_bullet = _this select 6;

_startPos = (visiblePositionASL _bullet);
_vectorUp = vectorDir _bullet;
_vector = [_vectorUp, 100] call bis_fnc_vectorMultiply;
_endPos = _vector vectorAdd _startPos;

// systemchat format['StartPos: %1 EndPos: %2', _startPos, _endPos];

// _vector = 
// _endPos = _muzzlePos vectorAdd _vector;

// _endPos = [_muzzlePos, 40, getDir player] call relPos;

//[[ASLtoAGL _startPos, ASLtoAGL _endPos], 1] spawn debugLine;

_intersectsObjs = lineIntersectsWith [_startPos, _endPos, player, objNull, true, 2];
if (count _intersectsObjs == 0) exitWith {};

//hint format['%1', _intersectsObjs];

_hitUnit = if ((_intersectsObjs select 0) isKindOf "Man") then { true } else { false };

if !(_hitUnit) exitWith {};

//systemchat format['Hit unit %1', time];

_intersectsSurfaces = lineIntersectsSurfaces [_startPos, _endPos, player, objNull, true, 2];

// Second intersect point is the second object

_surface = nil;
{
	if ((_x select 2) isKindOf "static") exitWith {
		_surface = (_intersectsSurfaces select _forEachIndex);
	};
} FOREACH _intersectsSurfaces;

if (isnil "_surface") exitWith {};

_surfaceIntersect = (_surface select 0);
_surfaceIntersect set [2, (_surfaceIntersect select 2) - 0.5];
_surfaceNormal = (_surface select 1);
_surfaceObject = (_surface select 2);

// _actualDir = [90 + getDir _surfaceObject] call normalizeAngle;
_surfaceDir = [getDir _surfaceObject, 0, 0] call dirToVector;

_splatter = "UserTexture1m_F" createVehicleLocal _surfaceIntersect; 
_splatter setPosASL _surfaceIntersect;
_splatter setVectorDirAndUp [_surfaceDir, _surfaceNormal];
// _splatter attachTo [_surfaceObject];

// _splatter setVectorDirAndUp [_surfaceDir, _surfaceNormal];

_splatter setObjectTexture [0,"#(argb,8,8,3)color(1,0.109804,0.109804,1.0,co)"];

_splatter spawn {
	Sleep 3;
	deleteVehicle _this;
};

