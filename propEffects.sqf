waitUntil {
	Sleep 1;
	!isNil "globalCompileComplete"
};

private ['_engine'];
params ['_engine'];

if (isNil { (_engine getVariable ['engineSpeed', nil]) } ) then { _engine setVariable ['engineSpeed', 0.01]; };
_engineSpeed = _engine getVariable ['engineSpeed', 0];
_currentSpeed = _engineSpeed;
_animPhase = 0;

_smokeEffect = {
	
	_target = [_this,0, objNull, [objNull]] call filterParam;
	_duration = [_this,1, 1, [0]] call filterParam;
	_color = [_this,2, [1, 1, 1, 1], [[]]] call filterParam;
	_scale = [_this,3, 1, [0]] call filterParam;
	_offset = [_this,4, [0,0,0], [[]]] call filterParam;

	if (isNull _target || _duration < 0) exitWith {};

	_pos = (ASLtoATL visiblePositionASL _target);

	_source = "#particlesource" createVehicleLocal _pos;
	_source setParticleParams 
	[
		["\A3\data_f\ParticleEffects\Universal\Universal", 16, 7, 48, 1], 
		"", 
		"Billboard", 
		1, 
		10, 
		_offset,
		[0, 0, -20],
		 0, 
		 1.277, 
		 1, 
		 0.025, 
		 [(4*_scale), (6*_scale), (10*_scale), (12*_scale)],
		 [_color, [1, 1, 1, 0]],
		 [0.2],
		 1, 
		 0.04, 
		 "", 
		 "", 
		 _target
	];

	_source setParticleRandom [2, [0.3, 0.3, 0.3], [1.5, 1.5, 1], 20, 0.2, [0, 0, 0, 0.1], 0, 0, 360];
	_source setDropInterval 0.06;
	_source attachTo [_target];

	Sleep _duration;
	deleteVehicle _source;
	

};


_refractEffect = {
	
	_target = _this select 0;
	_duration = _this select 1;
	_offset = _this select 2;
	_size = _this select 3;

	_pos = (ASLtoATL visiblePositionASL _target);

	_source  = "#particlesource" createvehiclelocal _pos;
	_source setParticleCircle [0, [0, 0, 0]];
	_source setParticleRandom [0.05, [0, 0, 0], [0, 0, 0], 1, 0.5, [0, 0, 0, 0], 0, 0];
	_source setDropInterval 0.1;
	_source attachTo [_target];

	_source setParticleParams
	[
		["\A3\data_f\ParticleEffects\Universal\Refract",1, 0, 1, 0],					//ShapeName ,1,0,1],	
		"",																		//AnimationName
		"Billboard",															//Type
		1,																		//TimerPeriod
		0.5,																	//LifeTime
		_offset,																//Position
		[0, 0, -20 * _size],															//MoveVelocity
		0,																		//RotationVelocity
		1,																		//Weight
		1,																		//Volume
		0,																	//Rubbing
		[3.5 * _size, 3.5  * _size, 5* _size],																	//Size
		[[1, 1, 1, 0.5], [1, 1, 1, 0.25],  [1, 1, 1, 0]],		//0.15												//Color
		[1],					  												//AnimationPhase
		0,																		//RandomDirectionPeriod
		0,																		//RandomDirectionIntensity
		"",																		//OnTimer
		"",																		//BeforeDestroy
		_target																	//Object
	];	

	Sleep _duration;

	deleteVehicle _source;


};

_dustEffect = {
	
	_pos = _this select 0;
	_duration = _this select 1;
	_intensity = _this select 2;

	_dropRate = 0.02;
	_particles = switch(_intensity) do {
		case 0:	{ [["CircleDustMed", 0.1]]	};
		case 1:	{ [["CircleDustMed", 0.06]]	};
		case 2:	{ [["CircleDustSmall", 0.04], ["CircleDustMed", 0.1]]	};
		case 3:	{ [["CircleDustSmall", 0.02], ["CircleDustMed", 0.02]] };
		default
		{
			[["CircleDustMed", 0.06]]
		};
	};
	
	{
		_particle = _x;
		_source = "#particlesource" createVehicleLocal _pos;
		_source setParticleClass (_particle select 0);
		_source setDropInterval (_particle select 1);
		
		_particles set [_forEachIndex, _source];

	} foreach _particles;

	sleep _duration;

	{
		deleteVehicle _x;
		false
	} count _particles;

};

_lastEffect = time - 2;
_lastSoundEffect = time - 10;

waitUntil {	

	_engineSpeed = _engine getVariable ['engineSpeed', 0];
	_animPhase = _animPhase + _engineSpeed;

	if ((time - _lastEffect) >= 2 && !isDedicated) then {
		_lastEffect = time;
		[_engine, 2, [0,0,-3.5], 2] spawn _refractEffect;

		[_engine, 2, [1,1,1,0.005], 2, [0,0,-2]] spawn _smokeEffect;

		_enginePos = (ASLtoATL visiblePositionASL _engine);

		_dustIntensity = if (surfaceIsWater _enginePos) then { -1 } else { 
			(_enginePos select 2) call {			
				if (_this >= 50) exitWith { -1 }; // No effect
				if (_this > 40) exitWith { 0 };
				if (_this > 30) exitWith { 1 };
				if (_this > 20) exitWith { 2 };
				3 
			};
		};

		if (_dustIntensity == -1) exitWith {};

		_enginePos set [2, 0];	
		_enginePos = [_enginePos, 3] call setVariance;
		
		[_enginePos, 2, _dustIntensity] spawn _dustEffect;

	};

	if ((time - _lastSoundEffect) >= 10 && !isDedicated) then {
		_lastSoundEffect = time;
		playSound3D ["T2_Engine\prop.ogg", _engine, false, getPosASL _engine, 7.5, 1, 500];
	};

	if (_animPhase >= 1) then { 
		_animPhase = 0.01; 
		_engine animate ['Prop_1_rot', 0, true];  
	};
	
	if (_animPhase > 0) then {
		_engine animate ['Prop_1_rot', _animPhase, true];
	};

	(!alive _engine)
};

