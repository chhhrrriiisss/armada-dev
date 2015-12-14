waitUntil {
	Sleep 0.1;
	!isNil "globalCompileComplete"
};

_functions = [
	['playerRespawn', nil],
	['playerKilled', nil],
	['getZoom', nil]
];

[_functions, 'client\functions\', TTN_DEV_BUILD] call functionCompiler;

clientCompileComplete = compileFinal "true";