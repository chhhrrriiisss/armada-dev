waitUntil {
	Sleep 0.1;
	!isNil "globalCompileComplete"
};

_functions = [
	// ['setupLauncher', nil],
	['parseLaunchSites', nil]
	// ['initServer', 'server\']
];

[_functions, 'server\functions\', TTN_DEV_BUILD] call functionCompiler;

serverCompileComplete = compileFinal "true";
