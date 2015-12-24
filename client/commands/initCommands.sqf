//
//		Chat Command Interceptor
//		Based off of a script developed by Conroy
//		Retrieved from http://www.armaholic.com/page.php?id=26377
//		Modified by Sli
//

// Reset and old EH IDs and scripthandles
if (!isNil "TTN_COMMANDS_SETUP")then{
	terminate TTN_COMMANDS_SETUP;
};
if (!isNil "TTN_COMMANDS_EH")then{
	(findDisplay 24) displayRemoveEventHandler ["KeyDown", TTN_COMMANDS_EH];
	TTN_COMMANDS_EH = nil;
};

TTN_COMMANDS_SETUP = [] spawn {
	private["_equal","_chatArr"];
	
	for "_i" from 0 to 1 step 0 do {

		TTN_COMMANDS_STRING = "";		
		
		waitUntil{sleep 0.22;!isNull (finddisplay 24 displayctrl 101)};
		
		TTN_COMMANDS_EH = (findDisplay 24) displayAddEventHandler["KeyDown",{
			if (!((_this select 1) in [28, 200, 208]) ) exitWith{false};
			
			// Up
			if ((_this select 1) == 200) exitWith { 

				_textToInsert = [TTN_COMMANDS_HISTORY, ((count TTN_COMMANDS_HISTORY) -1), "", [""]] call filterParam;
				if (count toArray _textToInsert == 0) exitWith { false };

				((finddisplay 24) displayctrl 101) ctrlSetText _textToInsert;

				true 
			};

			// Down
			if ((_this select 1) == 208) exitWith { true };

			if ((_this select 1) == 28) exitWith {

				_equal = false;
				
				_chatArr = toArray TTN_COMMANDS_STRING;
				//_chatArr resize 1;
				if ((_chatArr select 0) isEqualTo ((toArray TTN_COMMANDS_MARKER) select 0))then{
					if (GW_DEBUG)then{
						systemChat format["Intercepted: %1",TTN_COMMANDS_STRING];
					};
					_equal = true;
					closeDialog 0;
					(findDisplay 24) closeDisplay 1;
					(finddisplay 24 displayctrl 101) ctrlSetText "";
					[_chatArr] call TTN_executeCommand;
				};
				
				_equal
			};
		}];
		
		waitUntil{
			if (isNull (finddisplay 24 displayctrl 101))exitWith{
				if (!isNil "TTN_COMMANDS_EH")then{
					(findDisplay 24) displayRemoveEventHandler ["KeyDown",TTN_COMMANDS_EH];
				};
				TTN_COMMANDS_EH = nil;
				true
			};
			TTN_COMMANDS_STRING = (ctrlText (finddisplay 24 displayctrl 101));
			false
		};

	};
};