player setVariable ['attachmentEnabled', true];

[] call interactionSystem;
[] spawn attachmentSystem;
[] call playerActions;