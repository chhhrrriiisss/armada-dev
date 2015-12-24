waitUntil {
	Sleep 0.1;
	!isNil "configCompileComplete"
};

functionCompiler = compile preprocessFile "global\functions\functionCompiler.sqf";

_functions = [
	['dirTo', nil],	
	['dirToVector', nil],	
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
	['cropString', nil],
	['checkScope', nil],
	['padZeros', nil],
	['floodControl', nil],
	['getVectorDirAndUpRelative', nil],
	['positionToString', nil],
	['getBoundingBox', nil]

];

[_functions, 'global\functions\', TRUE] call functionCompiler;

globalCompileComplete = compileFinal "true";


