if (isDedicated) exitWith {};

waitUntil {Sleep 0.1; !isNil "clientCompileComplete" };    

// Wait for the server to finish doing its thang
systemchat 'Waiting for server...';
waitUntil {Sleep 0.1; !isNil "serverInitComplete"};
systemchat 'Server is ready to go!';

[] call initCommands;
[] call playerInit;

if (isNil "DEBUG_POINTS") then {
	DEBUG_POINTS = [];
};

if (isNil "DRAW_EH") then {
	DRAW_EH = addMissionEventHandler ["Draw3D", {

		{
			drawLine3D [(_x select 0), (_x select 1), [1,0,0,1]];	
			false	
		} count DEBUG_POINTS > 0;

	}];
};

debugLine = {	
	DEBUG_POINTS pushback (_this select 0);
	Sleep (_this select 1);
	DEBUG_POINTS = [];
};

_timeout = time + 30;
waitUntil {Sleep 1; ((time > _timeout) || (!isNil "clientLoadComplete"))};	
99999 cutText ["","PLAIN", 0.6];
