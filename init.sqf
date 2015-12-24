//
//     Armada
//     Titan MP Game Mode by Sli
//
//     This mod and its content (excluding those already attributed therein) are under a CC-BY-NC-ND 4.0 License
//     Attribution-NonCommercial-NoDerivatives 4.0 International
//     Permission must be sought from the Author for its commercial use, any modification or use of a non-public release obtained via the mission cache
//     

TTN_Server = false;
TTN_Client = false;
TTN_JIP = false;

// Used to determine if saved vehicles are out-of-date
TTN_VERSION = 10;

if (isServer) then { TTN_Server = true };
if (!isDedicated) then { TTN_Client = true };
if (isNull player) then { TTN_JIP = true };

// Get the mission directory
MISSION_ROOT = call {
    private "_arr";
    _arr = toArray str missionConfigFile;
    _arr resize (count _arr - 15);
    toString _arr
};


// Global Variables / Functions
call compile preprocessFile "config.sqf";
call compile preprocessFile "global\compile.sqf";
//call compile preprocessFile "briefing.sqf";

hint "v0.1.0 DEV";

99999 cutText ["Loading...", "BLACK", 0.01]; 
[] spawn {

	waitUntil {
		Sleep 0.1;
		!isNil "globalCompileComplete"
	};

	if (TTN_Client || TTN_JIP) then {   

	    call compile preprocessFile "client\compile.sqf";        
	    [] spawn initClient;

	};

	if (TTN_Server) then {    
	    call compile preprocessFile "server\compile.sqf";   
	     [] spawn initServer;
	};

};



