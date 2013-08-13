class amGrabCrate extends amGrabObject
	;

	var Quat HoldOrientation;
	var bool bCorrectOrientation;
	var bool bIsTouchingActor;

	var() float fCollisionRange;

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


			`log("PhysicsAssetLoc: "@PhysicsGrabber.Location
				@"AssetLoc: "@self.Location);  

			NewHandlePos = StartLoc + (HoldDistance * Vector(Aim));		
			NewHandlePos = VInterpTo(PhysicsGrabber.Location, NewHandlePos, DeltaTime, InterpAlpha/(Mass/2));
			PhysicsGrabber.SetLocation(NewHandlePos);

			//if (!IsTouchingKActor()) {
				PawnQuat = QuatFromRotator(PlayerViewPointRot);
				NewHandleOrientation = QuatProduct(PawnQuat, HoldOrientation);
				PhysicsGrabber.SetOrientation(NewHandleOrientation);
			//} 
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

			PawnQuat = QuatFromRotator(PlayerPawn.Rotation);
			InvPawnQuat = QuatInvert(PawnQuat);
			ActorQuat = QuatFromRotator(Rotation);
			HoldOrientation = QuatProduct(InvPawnQuat, ActorQuat);
		}
	}

/*function ProcessObjectSpin(float DeltaTime, Rotator ViewRotation, Rotator DeltaRot, out Rotator out_Rotation)
	{
		local Rotator NewRotation, OldRotation;
		//local Quat NewOrientation;

		OldRotation = self.Rotation;
		NewRotation = OldRotation + DeltaRot;
		NewRotation = RInterpTo(OldRotation, NewRotation, DeltaTime, 100);
		self.CollisionComponent.SetRBRotation(NewRotation);
		self.SetRotation(NewRotation);
		
		out_Rotation += DeltaRot;
		OldRotation = QuatToRotator(PhysicsGrabber.GetOrientation());
		NewRotation = RInterpTo(OldRotation, out_Rotation, DeltaTime, 100);
		NewOrientation = QuatFromRotator(NewRotation);
		PhysicsGrabber.SetOrientation(NewOrientation);
	}*/


	
function bool IsTouchingKActor()
	{
		local bool bReturn;
		local KActor A;

		bReturn = false;
		foreach OverlappingActors(class'KActor', A, fCollisionRange, PhysicsGrabber.Location) {
			if (A != none) {
				bReturn = true;
				`Log("IS TOUCHING A KACTOR");
			}
		}

		return bReturn;
	}

defaultproperties
{
	HoldDistanceMax=180.0
	HoldDistance=150.0
	
	InterpAlpha=10.0

	Mass=100

	bCorrectOrientation=false

	fCollisionRange=5.0
}