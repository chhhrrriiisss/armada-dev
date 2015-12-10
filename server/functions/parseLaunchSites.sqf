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

		if (_x == _target) then {

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
					_dirTo = [_o, (TITAN modelToWorld [0, -50, 0])] call dirTo;
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


					[_o, _dirToRange, _elevToRange] spawn {

						_timeout = time + 10;
						waitUntil {
							Sleep 0.5;
							((((_this select 0) animationPhase 'Base_rot') == (_this select 1)) || (time > _timeout))
						};

						(_this select 0) animate ['Launcher_rot', (_this select 2)];	
						(_this select 0) animate ['Piston_rot', (_this select 2)];
						(_this select 0) animate ['Piston_inner_slide', (_this select 2)];

					};					

					SYSTEMCHAT format['Dir: %1 NewDir: %2 Rad: %3', _dirTo, _newDir, _dirToRange];



		// 			_rocket = createVehicle ["M_Titan_AT_static", _gPos, [], 0, "FLY"];
		// playSound3D ["a3\sounds_f\weapons\rockets\new_rocket_8.wss", (_this select 2), false, (ASLtoATL visiblePositionASL (_this select 2)), 10, 1, 40]; 

		// _rocket setVectorDir _heading;
		// _rocket setVelocity _velocity;

		// [(_this select 0)] spawn muzzleEffect;

		// [(ATLtoASL _gPos), (ATLtoASL _targetPos), "RPD"] call markIntersects;	

		// [_rocket, _velocity, _targetPos] spawn {
		// 	_lastPos = (ASLtoATL visiblePositionASL (_this select 0));

		// 	waitUntil {		
		// 		Sleep 0.1;
		// 		// _lastPos = (ASLtoATL visiblePositionASL (_this select 0));
		// 		// (_this select 1) set [2, ((_this select 1) select 2) -0.09];				
		// 		// (_this select 0) setVelocity (_this select 1);
		// 		(!alive (_this select 0))
		// 	};

		// 	[_lastPos, 5, "RPD"] call markNearby;
		// 	[_lastPos, 10, 10] call shockwaveEffect;

		// };



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
