//
//		Chat Command Interceptor
//		Based off of a script developed by Conroy
//		Retrieved from http://www.armaholic.com/page.php?id=26377
//		Modified by Sli
//

TTN_COMMANDS_LIST = [
	
	[
		"spectate",
		{
			[] execVM 'camera.sqs';
		}
	],

	[
		
		"inv",
		{

			if ( !(serverCommandAvailable "#kick") ) exitWith {
				systemChat 'You need to be an admin to use that.';
			};	

							
		}
	]

];        


TTN_COMMANDS_MARKER = "!"; //Character at the front of the chat input to intercept it
TTN_COMMANDS_HISTORY = [];
TTN_COMMANDS_HISTORY_INDEX = 0;

TTN_executeCommand = {

	private ["_chatArr","_seperator","_commandDone","_command","_argument", "_index"];

		_chatArr = [_this,0,[]] call filterParam;

		_chatString = toString(_chatArr);

		// Remove leading intercept character
		_chatArr set [0,-1];
		_chatArr = _chatArr - [-1];

		_seperator = (toArray " ") select 0;
		_commandDone = false;
		_command = [];
		_argument = [];

		{
			if (_x == _seperator && !_commandDone)then{
				_commandDone = true;
			}else{
				if (!_commandDone) then{
					_command set[count _command,_x];
				}else{
					_argument set[count _argument,_x];
				};
			};
			false
		} count _chatArr > 0;

		_command = toString _command;
		_argument = toString _argument;
		_commandFound = false;

		{
			if (_command == (_x select 0))exitWith{
				_commandFound = true;
				[_argument] call (_x select 1);
			};
		}  Foreach GW_COMMANDS_LIST;

		if (!_commandFound) exitWith {
			systemchat format['Command %1 not found.', _chatString];
			true
		};

		// Add command to history if found
		_index = TTN_COMMANDS_HISTORY find _chatString;
		if (_index >= 0) then { TTN_COMMANDS_HISTORY deleteAt _index; };
		TTN_COMMANDS_HISTORY pushBack _chatString;
		if (count TTN_COMMANDS_HISTORY > 10) then { TTN_COMMANDS_HISTORY deleteAt 0; };

		true

};