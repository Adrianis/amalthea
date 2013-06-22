class amGrabDoor extends amGrabObject;

var() float MaxMovementForce; // limits amount of rotation pitch/yaw to apply as a force for door movement

function ProcessDoorMove(float DeltaTime, Rotator ViewRotation, Rotator DeltaRot)
{
	local Vector X, Y, Z;

	if ((ViewRotation+DeltaRot) != ViewRotation) // check if rotation has changed
	{
		GetAxes(ViewRotation, X, Y, Z);

		// limit max force applied to door
		if (DeltaRot.Pitch > MaxMovementForce) {
			DeltaRot.Pitch = MaxMovementForce;
		}
		else if (DeltaRot.Pitch < -MaxMovementForce) {
			DeltaRot.Pitch = -MaxMovementForce;
		}

		if (DeltaRot.Yaw > MaxMovementForce) {
			DeltaRot.Yaw = MaxMovementForce;
		}
		else if (DeltaRot.Yaw < -MaxMovementForce) {
			DeltaRot.Yaw = -MaxMovementForce;
		}

		// apply impulse using rotation change as force, player view rot as direction
		self.ApplyImpulse(X, DeltaRot.Pitch*15 / Mass, PlayerPawn.Location);
		self.ApplyImpulse(Y, DeltaRot.Yaw*15 / Mass, PlayerPawn.Location);
	}
}



DefaultProperties
{	
	HoldDistanceMax=250.0

	Mass=40
	MaxMovementForce=1000.00
}
