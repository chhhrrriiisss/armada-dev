private ['_code'];

_code = -1;

{	
	if ((_x select 0) == _this) exitWith {
		_code = (_x select 1);
	};
} foreach TTN_KeyCodes;

_code
