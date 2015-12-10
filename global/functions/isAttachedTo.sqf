params ['_target', '_source'];

if (_target == _source) exitWith { true };
if (isNull attachedTo _target) exitWith { hint 'nothing attached'; false };
	
findParent = {
	params ['_t', '_s'];
	if (isNull attachedTo _t) exitWith { _t };
	if ((attachedTo _t) == _s) exitWith { _s };
	([(attachedTo _t), _s] call findParent)
};

_parent = [_target, _source] call findParent;

if (_parent == _source) exitWith { true };

false


// _checkEachAttached = {

// 	private ['_target', '_source', '_found'];
// 	params ['_target', '_source'];

// 	_match = false;
// 	{
// 		if (_x == _source) exitWith { hint 'attached = source'; _match = true; };
// 		if (count (attachedObjects _x) > 0) then { _match = [_x, _source] call _checkEachAttached; };
// 		if (_match) exitWith {};				
// 	} foreach (attachedObjects _target);

// 	hint str _match;

// 	_match

// };

// ([_parent, _source] call _checkEachAttached)
