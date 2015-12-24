_this allowfleeing 0;

_this setDir (random 360);

_unitPos = (random 100) call {	
	if (_this >= 40) exitwITH {	"UP" };	
	if (_this >= 5) exitwITH {	"MIDDLE" };	
	"DOWN"
};

_this setUnitPos _unitPos;

_this disableAI "MOVE";
_this disableAI "FSM";

_this addEventHandler ['hitpart', {
	_this call playerHitPart;
}];

_this addEventHandler ['killed', {
	
	(_this select 0) removeAllEventHandlers 'killed';
	(_this select 0) removeAllEventHandlers 'hit';

	(_this select 0) spawn {
		Sleep 5;		

		_type = typeOf _this;

		_new = _type createVehicle (getpos _this);

		_new execVM 'initdummy.sqf';

	};
	
}];
