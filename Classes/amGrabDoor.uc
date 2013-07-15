class amGrabDoor extends amGrabObject;

/** limits amount of rotation pitch/yaw to apply as a force for door movement */
var() float MaxMovementForce; 

/** range within which the door should close itself, if too small then a fast moving door might skip it entirely */
var() float DoorCloseRange;

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
		local Vector ZeroMovement; // to kill extra velocity

		if (bCanAutoClose) 
		{
			if (DoorWithinCloseRange()) 
			{
				ZeroMovement.X=0;
				ZeroMovement.Y=0;
				ZeroMovement.Z=0;
				if(InterpAlpha < 100) { InterpAlpha += 0.8; }
				DesiredRotation = RInterpTo(self.Rotation, RotationAtStart, DeltaTime, InterpAlpha);
				self.CollisionComponent.SetRBRotation(DesiredRotation); // have to rotate the RB comp, rotate on self does not work
				self.CollisionComponent.SetRBAngularVelocity(ZeroMovement); // gets rid of latent velocity
			}
		}
	}


function bool DoorWithinCloseRange()
	{
		if (self.Rotation.Yaw >= (RotationAtStart.Yaw - DoorCloseRange)
			&& self.Rotation.Yaw <= (RotationAtStart.Yaw + DoorCloseRange)
			&& self.Rotation.Yaw != RotationAtStart.Yaw )
			return true;
		else 
			return false;
	}



DefaultProperties
{	
	


	HoldDistanceMax=250.0

	DoorCloseRange=600

	bCanAutoClose=true

	Mass=40
	MaxMovementForce=1000.00
}