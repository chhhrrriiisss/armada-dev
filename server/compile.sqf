_functions = [
	// ['setupLauncher', nil],
	['parseLaunchSites', nil],
	['initServer', 'server\']
	// ['initServer', 'server\']
];

[_functions, 'server\functions\', TRUE] call functionCompiler;

// Pubvar functions
pubVar_fnc_logDiag = compile preprocessFile "server\functions\pubVar_logDiag.sqf";
"pubVar_logDiag" addPublicVariableEventHandler { (_this select 1) call pubVar_fnc_logDiag };

serverCompileComplete = compileFinal "true";
publicVariable "serverCompileComplete";
