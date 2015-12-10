player setVariable ['attachmentEnabled', true];

waitUntil {Sleep 1; alive player};
[] execVM 'attachToTrigger.sqf';