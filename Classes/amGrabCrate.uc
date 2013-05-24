class amGrabCrate extends KActor;

/**********************
 * Code from PhysicsGrabber
 *********************/

	var float HoldDistanceMax, HoldDistance;
	var RB_Handle PhysicsGrabber;
	var Quat HoldOrientation;
	var Pawn PlayerPawn;
	var float InterpAlpha;
	var PhysicalMaterial HighFrictionMat;
	var PhysicalMaterial LowFrictionMat;
	var() float Mass;

function PreBeginPlay() 
	{
		local RB_BodySetup bodySetup;
	
		if(Mass <= 0) return;
	
		bodySetup = new class'RB_BodySetup';
		bodySetup.MassScale = Mass;
		Self.StaticMeshComponent.GetRootBodyInstance().UpdateMassProperties(bodySetup);
	}

event Bump(Actor Other, PrimitiveComponent OtherComp, Vector HitNormal) 
	{
	  if(Other.IsA('Pawn') && !GrabbedCrate() && !IsFalling()) {
		CollisionComponent.SetPhysMaterialOverride(LowFrictionMat);
		ApplyImpulse(-HitNormal, 4, CollisionComponent.Bounds.Origin);

		if(!IsTimerActive(NameOf(ApplyHighFriction)))
		  SetTimer(0.1, true, NameOf(ApplyHighFriction));

		bLimitMaxPhysicsVelocity = true;
		MaxPhysicsVelocity = 80;
	  }
	}

event bool EncroachingOn(Actor Other) 
	{
	  return false;
	}

function bool IsReachable() 
	{
	  return VSize(Location - GetPlayerPawn().Location) < HoldDistanceMax;
	}

function ToggleGrab() 
	{
	  local Quat PawnQuat, InvPawnQuat, ActorQuat;

		if(IsReachable()) {
		  // Make sure to clear the bump timer event so it doesn't try to apply high friction
		  if(IsTimerActive(NameOf(ApplyHighFriction)))
			ClearTimer(NameOf(ApplyHighFriction));

		  // Don't let player throw the crate too high
		  bLimitMaxPhysicsVelocity = true;
		  MaxPhysicsVelocity = 300;

		  CollisionComponent.SetPhysMaterialOverride(LowFrictionMat);
		  PhysicsGrabber.GrabComponent(CollisionComponent, 'None', CollisionComponent.Bounds.Origin, true);

		  PawnQuat = QuatFromRotator(Rotation);
		  InvPawnQuat = QuatInvert(PawnQuat);
		  ActorQuat = QuatFromRotator(Rotation);
		  HoldOrientation = QuatProduct(InvPawnQuat, ActorQuat);
		}
	}

function Drop() 
	{
	  InterpAlpha = 0;
	  ReleaseGrabbedActor(PhysicsGrabber);
	}

simulated function Tick(float DeltaTime) 
	{
		local vector NewHandlePos, StartLoc, PlayerViewPointLoc;
		local Rotator Aim, PlayerViewPointRot;
		local Quat NewHandleOrientation, PawnQuat;

		if(GrabbedCrate()) {
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

function bool GrabbedCrate() 
	{
	  return PhysicsGrabber.GrabbedComponent != None;
	}

private function ApplyHighFriction() 
	{
	  bLimitMaxPhysicsVelocity = false; // In case the player is pushing the crate off a ledge
	  CollisionComponent.SetPhysMaterialOverride(HighFrictionMat);
	  ClearTimer(NameOf(ApplyHighFriction));
	}

private function bool IsFalling() 
	{
	  return Round(Abs(Velocity.z)) != 0.0;
	}

private function bool CanStillHold() 
	{
	  local float CurrentHoldDistance;
	  CurrentHoldDistance = VSize(Self.Location - PhysicsGrabber.Location);

	  // Don't let the grabbed component get too far from the player
	  return (CurrentHoldDistance < HoldDistanceMax);
	}

private function ReleaseGrabbedActor(RB_Handle Grabber) 
	{
	  CollisionComponent.SetPhysMaterialOverride(HighFrictionMat);
	  Grabber.ReleaseComponent();
	  bLimitMaxPhysicsVelocity = false;
	}

private function UnlimitPhysicsVelocity() 
	{
	  bLimitMaxPhysicsVelocity = false;
	}

private function Pawn GetPlayerPawn() 
	{
	  if(PlayerPawn == None)
		PlayerPawn = WorldInfo.GetALocalPlayerController().Pawn;

	  return PlayerPawn;
	}

private function bool PlayerBasedOnMe() 
	{
	  return GetPlayerPawn().Base == Self;
	}

defaultproperties
	{

		Begin Object Class=RB_Handle Name=RB_Handle0
			TickGroup=TG_PreAsyncWork
			LinearDamping=100.0
			LinearStiffness=1300.0
			AngularDamping=200.0
			AngularStiffness=1000.0
			LinearStiffnessScale3D=(X=1.0,Y=1.0,Z=1.0)
			LinearDampingScale3D=(X=1.0,Y=1.0,Z=1.0)
		End Object
		PhysicsGrabber=RB_Handle0

		Begin Object Name=StaticMeshComponent0
  			StaticMesh=StaticMesh'timorem_devpak.Dev_Crate'
			End Object
		Components.Add(StaticMeshComponent0)

		HoldDistanceMax=180.0
		HoldDistance=150.0
		InterpAlpha=0.0
		bNoEncroachCheck=false
		bWakeOnLevelStart=true
		bNoDelete=false
		bCanStepUpOn=false
		bPawnCanBaseOn=true
		bSafeBaseIfAsleep=false
		Mass=100
  
		HighFrictionMat=PhysicalMaterial'timorem_devpak.Materials.HighFriction'
		LowFrictionMat=PhysicalMaterial'timorem_devpak.Materials.LowFriction'
  
	}