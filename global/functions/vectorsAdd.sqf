/* 		attachToWithMovement_0_6	*/

/*		Author: Make Love Not War	*/

/*
	vectorsAdd
 
	Description:  
		Sums any number of vectors or vector/scale pairs.

	Syntax:
		[_vectorA, [_vectorB, _scaleB]..] call F(vectorsAdd)
	
	Parameters:
		_vector (Array)
			- OR -
		[_vector (Array, _scale (Number)]
					
	Return Value: 
		Array
*/

private ["_scale","_vector","_sum"];

_sum = [0,0,0];
{
	_vector	= _x;
	_scale 	=  1;
	
	if (typeName (_x select 0) == "ARRAY") then {
		_vector	= _x select 0;
		_scale 	= _x select 1;
	};

	{
		_sum set [
			_forEachIndex,
			(_sum select _forEachIndex) + _x * _scale
		];
	} forEach _vector;
} forEach _this;

_sum