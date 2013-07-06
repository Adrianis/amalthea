class amGrabCrate extends amGrabObject;

simulated function Tick(float DeltaTime) 
	{
		local vector NewHandlePos, StartLoc, PlayerViewPointLoc;
		local Rotator Aim, PlayerViewPointRot;
		local Quat NewHandleOrientation, PawnQuat;

		if(GrabbedCrate()) 
		{
			if(!CanStillHold() || PlayerBasedOnMe()) { Drop(); return; }

			GetPlayerPawn().GetActorEyesViewPoint(PlayerViewPointLoc, PlayerViewPointRot);
 			StartLoc = PlayerViewPointLoc;
			Aim = PlayerViewPointRot;

			// Don't let crate get too close to player's feet when looking down
			if(Aim.Pitch > 17000 && Aim.Pitch < 56000) { Aim.Pitch = 56000; }

			// Smooth the crate into a firm grip
			if(InterpAlpha < 100) { InterpAlpha += 0.8; }

			NewHandlePos = StartLoc + (HoldDistance * Vector(Aim));
			NewHandlePos = VInterpTo(PhysicsGrabber.Location, NewHandlePos, DeltaTime, InterpAlpha);
			PhysicsGrabber.SetLocation(NewHandlePos);

			PawnQuat = QuatFromRotator(PlayerViewPointRot);
			NewHandleOrientation = QuatProduct(PawnQuat, HoldOrientation);
			PhysicsGrabber.SetOrientation(NewHandleOrientation);
		}
	}


function ToggleGrab()
	{
		local Quat PawnQuat, InvPawnQuat, ActorQuat;

		super.ToggleGrab();

		if(IsReachable()) {
			// Make sure to clear the bump timer event so it doesn't try to apply high friction
			if(IsTimerActive(NameOf(ApplyHighFriction)))
				ClearTimer(NameOf(ApplyHighFriction));

			CollisionComponent.SetPhysMaterialOverride(LowFrictionMat);
			PhysicsGrabber.GrabComponent(CollisionComponent, 'None', CollisionComponent.Bounds.Origin, true);

			PawnQuat = QuatFromRotator(Rotation);
			InvPawnQuat = QuatInvert(PawnQuat);
			ActorQuat = QuatFromRotator(Rotation);
			HoldOrientation = QuatProduct(InvPawnQuat, ActorQuat);
		}
	}

defaultproperties
{
	Mass=100
}