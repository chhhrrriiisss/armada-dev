if (!isNil "TTN_LAUNCHERS") then {
	[] call cancelAllTimeouts;
	{ deleteVehicle _x; } foreach TTN_LAUNCHERS;
	Sleep 1;
};

TTN_LAUNCHERS = [];
TTN_LAUNCHER_TIMEOUT = 5;

setupLauncher = {
	_launcherPos = _this;
	_launcher = "T2_Launcher" createVehicle (_launcherPos);
	_launcher setVariable ['TTN_Status', ["GUER", 0], true];

	_elev = (random 1);
	// _launcher animate ['Base_rot', (random 1), true];
	// _launcher animate ['Launcher_rot', _elev, true];
	// _launcher animate ['Piston_rot', _elev, true];
	// _launcher animate ['Piston_Inner_rot', _elev, true];

	_launcher addAction ['Toggle launcher!', {

		systemchat 'waiting for server...';

		[
			[(_this select 0), str side player],
			'setLaunchTimeout',
			false,
			false
		] call bis_fnc_mp;	


	}];

	_launcher
};

cancelAllTimeouts = {	
	
	systemchat 'running cancel...';

	{	
		_fnc = _x getVariable ['TTN_Function', nil];
		if (!isNil "_fnc") then {
			terminate _fnc;
			_x setVariable ['TTN_Status', ["GUER", 0], true];
			systemchat 'terminated timeout';
		};
	} foreach TTN_LAUNCHERS;		

};


setLaunchTimeout = {

	systemchat 'called timeout function';
	
	params ['_target', '_newSide'];

	{	

		if (_x == _target) exitWith {

			systemchat 'found object'; 

			_status = _x getVariable ['TTN_Status', []];
			if (count _status == 0) exitWith { _x setVariable ['TTN_Status', ["GUER", 0], true]; systemchat 'status has been reset'; };

			_side = _status select 0;
			_timeout = _status select 1;	

			// Check we don't already own this 
			if (_side == _newSide) exitWith { systemchat 'already owned by this side'; };

			// Delete any previously spawned timeout functions
			_functionToKill = _x getVariable ['TTN_Function', nil];
			if (!isNil "_functionToKill") then {
				terminate _functionToKill;
				systemchat format['Timeout aborted %1!', serverTime];
			};

			// Set a new launch timeout/owner
			_x setVariable ['TTN_Status', [_newSide, (serverTime + TTN_LAUNCHER_TIMEOUT)], true];
			systemchat format['Timeout started %1!', serverTime];

			// Callback function to keep launching missiles
			launcherCallback = {

				_o = (_this select 0);
				_t = (_this select 1);

				systemchat format['New function called, launching at %1!', (serverTime + TTN_LAUNCHER_TIMEOUT)];	

				Sleep _t;

				systemchat format['Firing %1 at %2!', (_this select 0), serverTime];		


				if (!isNil "TITAN" && !isPlayer TITAN) then {

					// Calculate new rotation for target
					_titanPos = (TITAN modelToWorld [0, -50, 0]);
					_dirTo = [_o, _titanPos] call dirTo;
					_currentDir = getDir _o;
					_newDir = [_currentDir - _dirTo] call normalizeAngle;
					_dirToRange = _newDir / 360;

					_o animate ['Base_rot', _dirToRange];

					// Calculate new elevation for target
					_altitude = (getPosASL TITAN) select 2;
					_elevation = [(_altitude - 70), -30, 30] call limitToRange;
					_elevToRange = _elevation / 60;

					_o animate ['Lid_1_rot', 1];
					_o animate ['Lid_2_rot', 1];
					_o animate ['Lid_3_rot', 1];
					_o animate ['Lid_4_rot', 1];

					SYSTEMCHAT format['Dir: %1 NewDir: %2 Rad: %3', _dirTo, _newDir, _dirToRange];

					[_o, _dirToRange, _elevToRange, _titanPos] spawn {

						_timeout = time + 10;
						waitUntil {
							Sleep 0.5;
							((((_this select 0) animationPhase 'Base_rot') == (_this select 1)) || (time > _timeout))
						};

						(_this select 0) animate ['Launcher_rot', (_this select 2)];	
						(_this select 0) animate ['Piston_rot', (_this select 2)];

						// Wait for elevation adjust before launching
						_timeout = time + 7;
						waitUntil {
							Sleep 0.5;
							((((_this select 0) animationPhase 'Launcher_rot') == (_this select 2)) || (time > _timeout))
						};

						Sleep (random 1);

						// Fire a missile
						_missile = createVehicle ["M_Titan_AT_static", [0,0,0], [], 0, "FLY"];
						playSound3D ["a3\sounds_f\weapons\rockets\new_rocket_8.wss", (_this select 0), false, getPos (_this select 0), 10, 1, 40]; 

						_missile setPos ((_this select 0) modelToWorld [0,0,5]);

						_timeout = time + 60;
						waitUntil {

							systemchat format['flight control running %1', time];
	
							if (isNil "TITAN") exitWith { true };
							

							_missilePos = getPos _missile;
							_targetPos = [ (TITAN modelToWorld [0,-75,0]), 10] call setVariance;

							_heading = [_missilePos,_targetPos] call BIS_fnc_vectorFromXToY;

							_distanceToTarget = _missilePos distance _targetPos;
							_heightAboveTerrain = (_missilePos select 2);	

							_minSpeed = 20;
							_maxSpeed = 40;
							
							_speed = [(1000 / _distanceToTarget) * _minSpeed, _minSpeed, _maxSpeed] call limitToRange;
				
							if (_distanceToTarget > 5 && _heightAboveTerrain <= 3) then {					
								_heading set[2, 0];

							} else {
								//deleteVehicle _this;
							};

							_velocity = [_heading, _speed] call BIS_fnc_vectorMultiply; 	

							_missile setVectorDir _heading; 

							_velocity set [2, ([(_velocity select 2), 0, 999] call limitToRange) ]; 

							_missile setVelocity _velocity; 

							Sleep 0.25;						

							(!alive _missile || isNil "TITAN" || time > _timeout) 

						};		

						systemchat 'flight control aborted...';			

					};					

					

				};		

				_callback = _this spawn launcherCallback;
				_o setVariable ['TTN_Function', _callback];
				_o setVariable ['TTN_Status', [(_this select 2), serverTime + TTN_LAUNCHER_TIMEOUT], true];

			};

			// Launch timeout function
			_callbackFunction = [_x, TTN_LAUNCHER_TIMEOUT, _newSide] spawn launcherCallback;

			// Store the spawned function locally incase we need to cancel it
			_x setVariable ['TTN_Function', _callbackFunction];

		};

	} foreach TTN_LAUNCHERS;


};


{
	TTN_LAUNCHERS pushBack (_x call setupLauncher);
} foreach (['ttn_launcher'] call findAllMarkers);
