//
//      Name: save
//      Desc: Gathers all information about a vehicle and saves to profileNameSpace
//      Return: None
//

if (isNil "WAITSAVE") then { WAITSAVE = FALSE; };
if (WAITSAVE) exitWith {  systemChat 'Save currently in progress. Please wait.'; };
WAITSAVE = true;

_saveTarget = [_this, 0, "", [""]] call filterParam;

if (count toArray _saveTarget == 0) exitWith {
     ['No save target specified'] spawn _onExit;
};

private['_saveTarget'];

_onExit = {
    systemChat (_this select 0);
    WAITSAVE = false;
};

if (isNil "TITAN") exitWith {
    ['No titan found...'] spawn _onExit;
};

SAVE_VEHICLE = TITAN;
SAVE_VEHICLE setDir 0;

// Actually saving now
systemChat 'Saving...';

_class = typeOf SAVE_VEHICLE;
_startTime = time;



ATTACH_ARRAY = [];

ATTACH_POS = getPosWorld SAVE_VEHICLE;
ATTACH_POS set [2, 40];

// Get information about each attached items
saveAttachedObjects = {

    _attachments = attachedObjects _this;
    if (count _attachments > 0) then {
        
        {     
            _p = getPosWorld _x;
            _p = _p vectorDiff ATTACH_POS;
            
            // Delete the object if we're having issues with it (or its old)
            if (!alive _x) then {
               deleteVehicle _x;
            } else {   

                // Don't save hidden objects
                if (isObjectHidden _x) exitWith {};

                _isProcedural = _x getVariable ['pA', false];
                if (_isProcedural) exitWith {};

                //_p =  _p call positionToString;
                _dir = getDir _x;

                // _pitchBank = _x call BIS_fnc_getPitchBank;
                // _dir = [(_pitchBank select 0), (_pitchBank select 1), getDir _x];

                _tagsToIgnore = _x getVariable ['TTN_DNA', []];

                _element = [typeof _x, _p, _dir, _tagsToIgnore];
                ATTACH_ARRAY pushBack _element;
            };

            if (count (attachedObjects _x) > 0) then {
                _x call saveAttachedObjects;
            };

        } ForEach _attachments;
    };

};

SAVE_VEHICLE call saveAttachedObjects;

_data = [_class, ATTACH_ARRAY];
profileNameSpace setVariable [_saveTarget, _data];
saveProfileNamespace;

_totalTime = time - _startTime;
systemChat format['Vehicle saved: %1 in %2.', _saveTarget, _totalTime];

// Then re-disable simulation
[''] spawn _onExit;
