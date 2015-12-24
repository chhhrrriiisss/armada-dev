_config = [
	["Land_PowerGenerator_F", 20, "GP", true, 75, 0],
	["Land_HeatPump_F", 10, "HP", TRUE, 100, 0],
	[["Box_Nato_AmmoVeh_F", "Land_PaperBox_open_full_F", "Land_PaperBox_closed_F"], 10, "VAP", TRUE, 50, 20],
	[["Land_Cargo20_light_green_F", "Land_Cargo20_orange_F", "Land_Cargo20_sand_F"], 10, "CP", TRUE, 50, 20],
	["T2_Door_Standard", 10, "DP", TRUE, 100, 0]
];

_target = [_this, 0, objNull, [objNull]] call filterParam;

if (isNull _target) exitWith { false };	

_tagsToIgnore = _target getVariable ['TTN_DNA', []];

{
	_classToUse = (_x select 0);
	_maxItems = (_x select 1);
	_tag = (_x select 2);
	_canRotate = (_x select 3);
	_chance = (_x select 4);
	_rotationVariance = (_x select 5);

	if (_tag in _tagsToIgnore) then {} else { 

		_arr = [];

		// Find all entries of that tag
		for "_i" from 1 to _maxItems step 1 do {

			_id = format['%1%2', _tag,_i];
			_pos = _target selectionPosition format['%1%2', _tag, _i];	

			if (_pos isEqualTo [0,0,0]) exitWith {};

			_dirPos = _target selectionPosition format['%1%2_DIR', _tag, _i];	
			_dirPos = if (_dirPos isEqualTo [0,0,0]) then { _pos } else { _dirPos };
			_dir = [([_pos, _dirPos] call dirTo) - 90] call normalizeAngle;

			// Chance we don't use this AP
			if (_chance < random 100) then {} else {
				_arr pushBack [_id, _dir];
			};

		};


		// Add at each position in selection
		{	
			// If it's an array of classes, select a random one
			_class = if (typename _classToUse == "ARRAY") then {
				(_classToUse call BIS_fnc_selectRandom)
			} else {
				_classToUse
			};

			_item = _class createVehicle [0,0,0];
			_item attachTo [_target,([0,0,0] vectorAdd (boundingCenter _item)), (_x select 0) ]; 

			// Flag as procedurally added so it doesn't get saved
			_item setVariable ['pA', true];

			TITANASSETS pushBack _item;

			if (!_canRotate) then {} else {


				[_item, ((_x select 1) + ((random _rotationVariance) - (_rotationVariance/2)))] spawn { 
					(_this select 0) setDir ([(getDir TITAN) + (_this select 1)] call normalizeAngle);	
				};		
			};
			
		} foreach _arr;

	};

} foreach _config;



// _doorsArray = [];
// _maxDoors = 10;

// for "_i" from 1 to _maxDoors step 1 do {

// 	_id = format['DP%1', _i];
// 	_pos = _target selectionPosition format['DP%1', _i];	

// 	if (_pos isEqualTo [0,0,0]) exitWith {};

// 	_dirPos = _target selectionPosition format['DP%1_DIR', _i];	
// 	_dirPos = if (_dirPos isEqualTo [0,0,0]) then { _pos } else { _dirPos };
// 	_dir = [([_pos, _dirPos] call dirTo) - 90] call normalizeAngle;
// 	_doorsArray pushBack [_id, _dir];

// };

// // Add a door at each position in selection
// {
// 	_door = "T2_Door_Standard" createVehicle [0,0,0];
// 	_door attachTo [_target,([0,0,0] vectorAdd (boundingCenter _door)), (_x select 0) ]; 

// 	[_door, (_x select 1)] spawn { 
// 		(_this select 0) setDir ([(getDir TITAN) + (_this select 1)] call normalizeAngle);	
// 	};		

// 	TITANASSETS pushBack _door;
// } foreach _doorsArray;


