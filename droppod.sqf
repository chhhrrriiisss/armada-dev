// _target = [_this, 0, [0,0,0], [[]]] call filterParam;

// if (_target isEqualTo [0,0,0]) then {
// 	_target = player modelToWorld [0,100,0];
// };

_dustEffect = {
	
	_pos = _this select 0;
	_duration = _this select 1;

	_source = "#particlesource" createVehicleLocal _pos;
	_source setParticleClass "CircleDustSmall";
	_source setDropInterval 0.02;

	sleep _duration;

	deleteVehicle _source;

};

_thrustEffect = {
	
	_target = _this select 0;
	_duration = _this select 1;
	_offset = _this select 2;
	_size = _this select 3;

	_pos =  (ASLtoATL visiblePositionASL _target);
	_source = "#particlesource" createVehicleLocal _pos;
	_source setParticleCircle [0, [0, 0, 0]];
	_source setParticleParams [["\A3\data_f\Cl_water", 1, 0, 1], "", "Billboard", 1, 0.5, [0, 0, 0], [0, 0, -10], 0, 10, 7.9, 0.075, [1 * _size, 2 * _size, 3  * _size], [[0.99, 0.87, 0.41, 0.4], [0.8, 0.8, 0.8, 0.15], [0.5, 0.5, 0.5, 0]], [0.08], 1, 0, "", "", _source];
	_source setParticleRandom [0, [0.075, 0.075, 0], [0.175, 0.175, 0], 0, 0.1, [0, 0, 0, 0.1], 0, 0];	
	_source setDropInterval 0.01;	
	_source attachTo [_target, _offset]; 

	// _source2 = "#particlesource" createVehicleLocal _pos;
	// _source2 setParticleParams [["\A3\data_f\ParticleEffects\Universal\Universal", 16, 7, 48, 1], "", "Billboard", 1, 3, [0, 0, 0], [0, 0, 0.5], 0, 1.277, 1, 0.025, [0.5, 4, 6, 8], [[1, 1, 1, 0.7],[1, 1, 1, 0.5], [1, 1, 1, 0.25], [1, 1, 1, 0]],
	// [0.2], 1, 0.04, "", "", _source2];
	// _source2 setParticleRandom [2, [0.3, 0.3, 0.3], [1.5, 1.5, 1], 20, 0.2, [0, 0, 0, 0.1], 0, 0, 360];
	// _source2 setDropInterval 0.1;
	// _source2 attachTo [_target];

	// _source3  = "#particlesource" createvehiclelocal _pos;
	// _source3 setParticleCircle [0, [0, 0, 0]];
	// _source3 setParticleRandom [0.05, [0, 0, 0], [0, 0, 0], 1, 0.5, [0, 0, 0, 0], 0, 0];
	// _source3 setDropInterval 0.05;
	// _source3 attachTo [_target];

	// _source3 setParticleParams
	// [
	// 	["\A3\data_f\ParticleEffects\Universal\Refract",1, 0, 1, 0],					//ShapeName ,1,0,1],	
	// 	"",																		//AnimationName
	// 	"Billboard",															//Type
	// 	1,																		//TimerPeriod
	// 	0.75,																	//LifeTime
	// 	[0, 0, -2],																//Position
	// 	[1, 1, 0],															//MoveVelocity
	// 	0,																		//RotationVelocity
	// 	3,																		//Weight
	// 	3,																		//Volume
	// 	0.1,																	//Rubbing
	// 	[2, 4],																	//Size
	// 	[[1, 1, 1, 1], [1, 1, 1, 0.5],  [1, 1, 1, 0.1]],		//0.15												//Color
	// 	[1],					  												//AnimationPhase
	// 	0,																		//RandomDirectionPeriod
	// 	0,																		//RandomDirectionIntensity
	// 	"",																		//OnTimer
	// 	"",																		//BeforeDestroy
	// 	_target																	//Object
	// ];	

	Sleep _duration;

	deleteVehicle _source;

};

// Create drop pod
_destroyPod = {
	

	detach _this;

	_podPosition = getPos _this;
	{ 

		detach _x; 
		_targetPos = [(getPos _x), 2] call setVariance;
		_vector = [_podPosition, _targetPos] call BIS_fnc_vectorFromXToY;	
		_vector = [_vector, 8] call bis_fnc_vectorMultiply;
		_vector set [2, 0.25];

		_x setVelocity _vector;
		
		_x spawn {
			Sleep (random 10);
			deleteVehicle _this;
		};

	} foreach (attachedObjects _this);

	_this spawn {
		Sleep (random 10);
		deleteVehicle _this;
	};
};


_pod = "T2_DropPod_Base" createVehicle [0,0,0];
_arm = "T2_DropPod_Arm" createVehicle [0,0,0];
_shell = "T2_DropPod_Shell" createVehicle [0,0,0];

_armS = 0.5;

_armX = 0.72 * _armS;
_armY = 0.72 * _armS;
_armZ = 1.55 * _armS;

_armOffsets = [
   [0, [_armX,-_armY, _armZ]],
   [90, [-_armX,-_armY, _armZ]],
   [180, [-_armX,_armY, _armZ]],
   [270, [_armX,_armY, _armZ]]
];

// Attach arms
{
	_arm = "T2_DropPod_Arm" createVehicle [0,0,0];
	_arm attachTo [_pod, (_x select 1)];
	_arm setDir ([getDir _pod + (_x select 0)] call normalizeAngle);
	_arm setPos (getPos _arm); // Sync dir

} foreach _armOffsets;

// Attach shells
_shellS = 0.5;
_shellX = 0.73 * _shellS;
_shellY = 0.75 * _shellS;
_shellZ = 1.52 * _shellS;

_shellOffsets = [

   [0, [0, -_shellY, _shellZ]],
   [90, [-_shellX, _shellY * 0, _shellZ]],
   [180, [_shellX * 0, _shellY, _shellZ]],
   [270, [_shellX, _shellY * 0, _shellZ]]
];

{
	_shell = "T2_DropPod_Shell" createVehicle [0,0,0];
	_shell attachTo [_pod, (_x select 1)];
	_shell setDir ([getDir _pod + (_x select 0)] call normalizeAngle);
	_shell setPos (getPos _shell); // Sync dir setPos (getPos _arm); // Sync dir

} foreach _shellOffsets;

// _pod setPos (player modelToWorld [0,5,5]);

// [_pod,2, [0,0,-0.25], 1] spawn _thrustEffect;
// [_pod,2, [0,0,-0.25], 0.4] spawn _thrustEffect;

// [_pod,2, [0.55,-0.55, 0.6], 0.25] spawn _thrustEffect;


// Prep player for launch
player setVariable ['attachmentEnabled', false];
player allowDamage false;
player hideObjectGlobal true;

_pod disableCollisionWith player;
player disableCollisionWith	_pod;
{ 
	_x disableCollisionWith player;
	player disableCollisionWith _x; 

} foreach (attachedObjects _pod);

player switchMove "AmovPknlMstpSrasWrflDnon";

// _pen = createVehicle ["Land_PenBlack_F", [0,0,0], [], 0, 'CAN_COLLIDE'];
// _pen setPos (player modelToWorld [0,5,0]);
_source = player;

// Prep pod for launch
_pod allowDamage false;
// _pod enablesimulation false;
// { _x enablesimulatioN false; } foreach (attachedObjects _pod);

_podAttachHeight = -2;
_pod attachTo [_source, ([-0.1,0.45,_podAttachHeight] vectorAdd (boundingCenter _pod)) ];
waitUntil {
	(!isNull attachedTo _pod)
};

// player attachTo [_pod];
// waitUntil {
// 	(!isNull attachedTo player)
// };



// player setMass 1;
// { _x setmass 0; } foreach (attachedObjects player);

_targetPos = if (player distance TITAN > 75) then { (TITAN modelToWorld [0, -100, 0]) } else { (getMarkerPos  "drop_target") };
_playerPos = position player;

_speed = 15;
_dir = ((_targetPos select 0) - (_playerPos select 0)) atan2 ((_targetPos select 1) - (_playerPos select 1));
_range = _playerPos distance _targetPos;

player setVelocity [_speed * (sin _dir), _speed * (cos _dir), 5 * (_range / _speed)];

_heightAbove = ((getPos _source) select 2);

// _velocity = [_vector, 75] call bis_fnc_vectorMultiply;
// _velocity set [2, 100];

// player hideObjectGlobal true;

// adjustPodVelocity = {	
		
// 	_key = (_this select 1);

// 	//32 r
// 	// 30 l
// 	// 17 u
// 	// 31 d

// 	if (_key in [32, 30, 17, 31]) exitWith {

// 		_rot = _key call {
// 			if (_this == 17) exitWith { 0 };
// 			if (_this == 31) exitWith { 180 };
// 			if (_this == 30) exitWith { -90 };
// 			if (_this == 32) exitWith { 90 };
// 			0
// 		};


// 		_dir = [(getDir player) + _rot] call normalizeAngle;
// 		_speed = 0.25;
// 		_vel = velocity player;

// 		player setVelocity [(_vel select 0)+(sin _dir*_speed),(_vel select 1)+(cos _dir*_speed),(_vel select 2)];	

// 		false
// 	};

// 	false
// };

// if (!isNil "KD_EH") then { (findDisplay 46) displayRemoveEventHandler ["KeyDown", KD_EH]; };
// KD_EH = (findDisplay 46) displayAddEventHandler ["KeyDown", "_this call adjustPodVelocity; false"];


// Wait for us to land
_maxTime = 30;
_minTime = time + 3;
_timeout = time + _maxTime;
_startAltitude = (getPosASL _source) select 2;
_minAltitude = 5;
_reachedMinAltitude = false;
_lastEffect = time - 2;

_podDir = getDir _pod;

waitUntil {
	

	if (time - _lastEffect > 1) then {
		_lastEffect = time;

		if (((velocity _source) select 2) <= 0) exitWith {};

		{
			[_pod,(_x select 2), (_x select 0), (_x select 1)] spawn _thrustEffect;
			} foreach [
			[[0,0,-0.25],1, 1]
		];
	};


	_p1 = getPosASL _source;
	_p2 = +_p1;
	_p2 set [2, (_p2 select 2) - 3 + (_podAttachHeight)];

	if ( abs ((_p1 select 2) - _startAltitude) > _minAltitude || time > _minTime) then {
		_reachedMinAltitude = true;
	};	
	
	_objs = if (_reachedMinAltitude) then { (lineIntersectsObjs [_p1, _p2, _pod, _source]) } else { [] };
	_terrainIntersect = if (_reachedMinAltitude) then { (terrainIntersectASL [_p1,_p2]) } else { false };

	_pod setDir ([_podDir - (getDir _source)] call normalizeAngle);



	// _vector = [(player modelToWorld [0,0,0]), _target] call BIS_fnc_vectorFromXToY;	
	// _velocity = _vector vectorAdd [0,0,(_timeout - time)];
	// player setVelocity _velocity;
	// if (animationState player == "halofreefall_non") then {
	// 	player switchMove "";
	// };

	(time > _timeout || (count _objs > 0) || _terrainIntersect || !alive _source)

};

// Remove key event handler
// (findDisplay 46) displayRemoveEventHandler ["KeyDown", KD_EH];

// Create burn effect
_heightAbove = (((getPos _source) select 2)) + (_podAttachHeight);

{
	[_pod,(_x select 2), (_x select 0), (_x select 1)] spawn _thrustEffect;
} foreach [
	[[0,0,-0.25], 0.4, _heightAbove]
];

_p1 = getPosASL _source;
_p2 = +_p1;
_p2 set [2, (_p2 select 2) - 5];
_intersectPositions = lineIntersectsSurfaces [_p1, _p2, _pod, _source];
_groundPos = [0,0,0];
if (count _intersectPositions > 0) then { 
	hint str ((_intersectPositions select 0) select 0);
	_groundPos = (_intersectPositions select 0) select 0;
} else {
	_groundPos = (getPos _source);
	_groundPos set [2, 0];
};

[_groundPos, _heightAbove] spawn _dustEffect;
_source setVariable ['attachmentEnabled', true];

_timeout = time + _heightAbove;
_lastVelocity = time - 0.1;

waitUntil {
	
	_pod setDir ([_podDir - (getDir _source)] call normalizeAngle);

	if ((time - _lastVelocity) > 0.1) then {
		_lastVelocity = time;
		_velocity = velocity _source;
		_velocity set [2, (_velocity select 2) * 0.25];
		_source setVelocity _velocity;
	};

	// Hold position until pod breaks
	_pos = getPosASL _source;
	_groundPos set [2, (_pos select 2)];
	_source setPosASL _groundPos;

	(time > _timeout || !alive _source)
};
_source switchMove "";

_pod call _destroyPod;

_source hideObjectGlobal false;
_source setVelocity [0,0,0];


// AmovPknlMstpSrasWrflDnon // kneel positionh
// AmovPknlMstpSrasWrflDnon_AmovPknlMevaSrasWrflDr // shuffle kneel

// Three seconds after landing, ensure no parachute animation
_timeout = time + 1;
waitUntil {
	_source switchMove "AmovPknlMstpSrasWrflDnon";
	(time > _timeout)
};

// sleep 0.5;

// player playMove "";

