waitUntil {
	Sleep 0.1;
	!isNil "configCompileComplete"
};

functionCompiler = compile preprocessFile "global\functions\functionCompiler.sqf";

_functions = [
	['dirTo', nil],	
	['relPos', nil],	
	['filterParam', nil],	
	['vectorsAdd', nil],	
	['limitToRange', nil],
	['roundTo', nil],
	['normalizeAngle', nil],
	['setPitchBankYaw', nil],
	['flattenAngle', nil],
	['setVariance', nil],
	['inString', nil],
	['isAttachedTo', nil],
	['findAllMarkers', nil],
	['cropString', nil]

];

[_functions, 'global\functions\', TTN_DEV_BUILD] call functionCompiler;

if (isDedicated) then {
	[] execVM 'build.sqf';
};

globalCompileComplete = compileFinal "true";