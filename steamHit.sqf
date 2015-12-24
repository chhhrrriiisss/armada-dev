_object = _this;

			
_object removeAllEventHandlers "hitPart";

steamEffect = {
	
	_obj = _this select 0;
	_position = _this select 3;
	_direction = _this select 7;

	systemchat format['Hit triggered %1 / %2', _obj worldToModel _position, _direction];

	_color = [1,1,1,1];
	_duration = 10;
	_scale = 0.1;

	_source = "#particlesource" createVehicleLocal _position;
	_source setParticleParams [["\A3\data_f\ParticleEffects\Universal\Universal", 16, 7, 48, 1], "", "Billboard", 1, 10, _obj worldToModelVisual (ASLtoATL _position),_direction vectorMultiply 2, 0, 1.277, 1, 0.025, [(0.5 * _scale), (8*_scale), (12*_scale), (15*_scale)], 
	[[(_color select 0), (_color select 1), (_color select 2), 0.7],[(_color select 0), (_color select 1), (_color select 2), 0.5], [(_color select 0), (_color select 1), (_color select 2), 0.25], [1, 1, 1, 0]],[0.2], 1, 0.04, "", "", _obj];

	_source setParticleRandom [2, [0.1, 0.1, 0.1], [0.1, 0.1, 0.1], 20, 0.2, [0, 0, 0, 0.1], 0, 0, 360];
	_source setDropInterval 0.01;
	_source attachTo [_obj];
	
	Sleep _duration;
	deleteVehicle _source;

};



_handler = _object addEventHandler ['hitPart', {
		
	
	(_this select 0) spawn steamEffect;

}];


_object setVariable ['EH', _handler];