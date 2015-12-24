//
//      Name: load
//      Desc:  Generate a vehicle on server using raw data
//      Return: None
//

if (isNil "WAITSAVE") then { WAITSAVE = FALSE; };
if (WAITSAVE) exitWith {
    systemchat 'Cant load while saving... ';
};

if (!isNil "TITAN") then {

    if (count TITANASSETS == 0) exitWith {};

    {
        deleteVehicle _x;
    } foreach TITANASSETS;

    deleteVehicle TITAN;
};

if (!isNil "LOAD_COMPLETE") exitWith {
    systemchat 'Currently loading vehicle...';
};

LOAD_COMPLETE = false;

private ['_target', '_newVehicle', '_spawnPosition'];

_target = [_this , 0, "", [""]] call filterParam;

_startTime = time; 
if (count toArray _target == 0) exitWith {
    systemchat "No load target specified";
};

_spawnPosition = ATLtoASL (getMarkerPos "titan_spawn");
_spawnPosition set [2, 40];

{
    if (isPlayer _x) then {} else {
        deleteVehicle _x;
    };
} FOREACH nearestObjects [_spawnPosition, ['All'], 300];

_data = profileNameSpace getVariable [_target, []];

if (count _data == 0) exitWith {
    systemchat "No data for that target.";
};

_newVehicle = createVehicle [(_data select 0), _spawnPosition, [], 0, "CAN_COLLIDE"];
_newVehicle setPosASL _spawnPosition;
_newVehicle setDir 0;
_newVehicle setVectorUp [0,0,1];

_newVehicle enableSimulation false;

waitUntil {
    !simulationEnabled _newVehicle
};

TITANASSETS = [];
TITANASSETS pushback _newVehicle;

// Loop through and create attached objects
{

    if (!isNil "_x") then {     

        // Retrieve position (and convert if needed)
        _c = _x select 0;
        _p = _x select 1;
        _dir = _x select 2;
        _tagsToIgnore = _x select 3;

        // if (typename _p == "STRING") then {
        //     _p = call compile _p;
        // };    

        _p = _spawnPosition vectorAdd _p;

        // Spawn the object
        _o = _c createVehicle [0,0,0];



        //_o setPosASL _p;

        _mP = _newVehicle worldToModel (ASLtoAGL _p);

        _o attachTo [_newVehicle, _mP];

        // _o attachTo [_newVehicle];

        //_bounds = (boundingCenter _newVehicle) vectorAdd (boundingCenter _o);
        //_o attachTo [_newVehicle, _p vectorAdd (boundingCenter _o)];      
        
        _o setDir _dir;  

        _o setVariable ['TTN_DNA', _tagsToIgnore];

        TITANASSETS pushback _o;

    };

    false
    
} count (_data select 1) > 0;

LOAD_COMPLETE = true;

_timeout = time + 5;
waitUntil { ((time > _timeout) || LOAD_COMPLETE) };

_newVehicle enableSimulation true;

waitUntil {
    simulationEnabled _newVehicle
};

TITAN = _newVehicle;

batchAddAttachments = {
    {
        
        if ((count attachedObjects _x) > 0) then {
            _x call batchAddAttachments;
        };
        [_x] call generateAttachments;

    } foreach attachedObjects _this;
};

TITAN call batchAddAttachments;

TITAN setPosASL _spawnPosition;
TITAN setVectorUp [0,0,1];
TITAN setVelocity [0,0,0];

_currentPos = _spawnPosition;
_currentDir = getDir TITAN;

_endTime = time;
_totalTime = round ((_endTime - _startTime) * (10 ^ 3)) / (10 ^ 3);
systemchat format['Vehicle loaded in %1.',  (_endTime - _startTime)];

LOAD_COMPLETE = nil;

waitUntil {

    if (isNil "TITAN") exitWith { true };

     // Set new pos/dir/vel
    if (getPosASL TITAN distance _currentPos > 0) then { TITAN setPosASL _currentPos; };
    if (abs ([_currentDir - getDir TITAN] call flattenAngle) > 0) then { TITAN setDir _currentDir;};
    if (((velocity TITAN) distance [0,0,0]) > 0) then { TITAN setVelocity [0,0,0]; };
    if (((vectorUp TITAN) distance [0,0,1]) > 0) then { TITAN setVectorUp [0,0,1]; };

    (isNil "TITAN") 

};


