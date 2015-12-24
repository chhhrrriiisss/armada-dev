removeAllActions player;

PLAYER addAction ['Edit Titan', {	

	[] execVM 'edit.sqf';

}];


PLAYER addAction ['Build Titan', {	

	[true] execVM 'build.sqf';

}];


PLAYER addAction ['Add Test Bot', {	

	_s = "b_soldier_f" createvehicle (player modelToWorldVisual [0,0,1]);  
	_s setPosASL (GETPOSASL player); 
	[_s] execVM 'attach.sqf';

}];

PLAYER addAction ['Attachment System', {	
	[] execVM 'attach.sqf';
}];

// PLAYER addAction ['Toggle attachment', {	
// 	_enabled = player getVariable ['attachmentEnabled', false];
// 	player setVariable ['attachmentEnabled', !_enabled];
// }];

PLAYER addAction ['Set position', {	
	_p = (screenToWorld[0.5,0.5]);
	_height = [(_p select 2), 40, 9999] call limitToRange;
	_p set [2, _height];
	TITAN setPos _p;
}];

PLAYER addAction ['Set target', {	
	TITAN setVariable ['targetPosition',screenToWorld[0.5, 0.5], true ];
}];

PLAYER addAction ['Increase speed', {	
	_spd = TITAN getVariable ['engineSpeed',0.01];
	TITAN setVariable ['engineSpeed', (_spd + 0.005), true ];
}];

PLAYER addAction ['Decrease speed', {	
	_spd = TITAN getVariable ['engineSpeed',0.01];
	TITAN setVariable ['engineSpeed', (_spd - 0.005), true];
}];

PLAYER addAction ['Raise altitude', {	
	_alt = TITAN getVariable ['maxAltitude', 40];
	TITAN setVariable ['maxAltitude', (_alt + 2), true];
}];

PLAYER addAction ['Lower altitude', {	
	_alt = TITAN getVariable ['maxAltitude', 40];
	TITAN setVariable ['maxAltitude', (_alt - 2), true];
}];

PLAYER addAction ['Drop pod', {	
	[(screenTOwORLD [0.5, 0.5])] execVM 'droppod.sqf';
}];

PLAYER addAction ['Start Engines', {	
	_engines = TITAN getVariable ['engines', []];
}];

PLAYER addAction ['Stop Engines', {	
	
	_engines = TITAN getVariable ['engines', []];

}];

PLAYER addAction ['Camera', {	
	[] execVM 'camera.sqs'; 
}];