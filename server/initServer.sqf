waitUntil { (!isNil "serverCompileComplete") };    

[] execVM 'build.sqf';

serverInitComplete = compileFinal "true";
publicVariable "serverInitComplete";