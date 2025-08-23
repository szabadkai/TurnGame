function move(direction) {
	// Validate direction parameter
	if (!is_real(direction) || direction < Dir.UP || direction > Dir.RIGHT) {
		show_debug_message("ERROR: Invalid direction passed to move(): " + string(direction));
		return false;
	}
	
	// Set common animation properties
	is_animating = true;
	image_index = direction;  // Set sprite frame based on direction
	alarm[0] = MOVEMENT_DURATION;  // Use constant for movement duration
	
	// Apply movement based on direction using switch statement
	switch (direction) {
		case Dir.UP:
			vspeed = -MOVEMENT_SPEED;
			break;
			
		case Dir.DOWN:
			vspeed = MOVEMENT_SPEED;
			break;
			
		case Dir.LEFT:
			hspeed = -MOVEMENT_SPEED;
			break;
			
		case Dir.RIGHT:
			hspeed = MOVEMENT_SPEED;
			break;
			
		default:
			// This should never happen due to validation above, but safe fallback
			show_debug_message("ERROR: Unhandled direction in move() switch: " + string(direction));
			is_animating = false;
			return false;
	}
	
	return true;  // Movement initiated successfully
}