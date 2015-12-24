_object = _this;

_object setVariable ['editingActive', true];

detach _object;

waitUntil {
	isNull attachedTo _object;
};

_object attachTo [player];
_playerpos = (asltoatl visiblePositionASL player);

player addAction ['Drop', {	
	player setVariable ['editingActive', false];	
}];

player allowDamage false;

waitUntil {
	
	player setVelocity [0,0,0];

	_editingActive = player getVariable ['editingActive', false];
	!_editingActive
};

if (!isNil "KD_EH") then { (findDisplay 46) displayRemoveEventHandler ["KeyDown", KD_EH]; };

detach _object;

waitUntil {
	isNull attachedTo _object;
};

_vect = [_object, TITAN] call getVectorDirAndUpRelative;

_object attachTo [TITAN];

waitUntil {
	!isNull attachedTo _object;
};

_object setVectorDirAndUp _vect;
_object setVectorUp [0,0,1];


