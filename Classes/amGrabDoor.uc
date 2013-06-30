class amGrabDoor extends amGrabObject;

var() float MaxMovementForce; // limits amount of rotation pitch/yaw to apply as a force for door movement

var() float DoorCloseRange; // range within which the door should close itself

var bool bCanAutoClose; // flag to control when the door should close itself

var Rotator RotationAtStart; // to hold the rotation of the door at the start of the game



simulated function PostBeginPlay()
	{
		super.PostBeginPlay();

		RotationAtStart = self.Rotation;
	}


function ProcessDoorMove(float DeltaTime, Rotator ViewRotation, Rotator DeltaRot)
	{
		local Vector X, Y, Z;

		if ((ViewRotation+DeltaRot) != ViewRotation) // check if rotation has changed
		{
			GetAxes(ViewRotation, X, Y, Z);

			// limit max force applied to door
			if (DeltaRot.Pitch > MaxMovementForce) 
				DeltaRot.Pitch = MaxMovementForce;
			else if (DeltaRot.Pitch < -MaxMovementForce) 
				DeltaRot.Pitch = -MaxMovementForce;
			
			if (DeltaRot.Yaw > MaxMovementForce) 
				DeltaRot.Yaw = MaxMovementForce;
			else if (DeltaRot.Yaw < -MaxMovementForce) 
				DeltaRot.Yaw = -MaxMovementForce;
			

			// apply impulse using rotation change as force, player view rot as direction
			self.ApplyImpulse(X, DeltaRot.Pitch*15 / Mass, PlayerPawn.Location);
			self.ApplyImpulse(Y, DeltaRot.Yaw*15 / Mass, PlayerPawn.Location);
		}
	}

simulated function Tick(float DeltaTime)
	{
		local Rotator DesiredRotation;
		
		
		if (bCanAutoClose) 
		{
			if (DoorWithinCloseRange()) 
			{
				`log("SHOULD BE CLOSING NOW");

				DesiredRotation = RInterpTo(self.Rotation, RotationAtStart, DeltaTime, 10000);
				self.SetRotation(DesiredRotation);
			}
		}


	}


function bool DoorWithinCloseRange()
	{
		/*local float RelativeYaw;

		RelativeYaw = self.Rotation.Yaw - RotationAtStart.Yaw;*/

		//`log("CurrentYaw:"@self.Rotation.Yaw@" StartYaw:"@RotationAtStart.Yaw);

		/*if (RelativeYaw < 200)
			return true;
		else 
			return false;*/

		if (self.Rotation.Yaw >= (RotationAtStart.Yaw - DoorCloseRange)
			&& self.Rotation.Yaw <= (RotationAtStart.Yaw + DoorCloseRange))
			return true;
		else 
			return false;

	}

DefaultProperties
{	
	HoldDistanceMax=250.0

	DoorCloseRange=300

	bCanAutoClose=true

	Mass=40
	MaxMovementForce=1000.00
}
