class amGrabObject extends KActor
	abstract;


/**********************
 * Code from PhysicsGrabber
 *********************/
	var Pawn PlayerPawn;
	var float HoldDistanceMax, HoldDistance;
	var RB_Handle PhysicsGrabber;
	var float InterpAlpha;
	var PhysicalMaterial HighFrictionMat;
	var PhysicalMaterial LowFrictionMat;

	/** Mass for the object, obviously! Less obviously, it doesn't obey any proper laws of physics (i.e. its not newtonian): 7 MIN (for a pencil), 100 MAX (for an anvil)
	 *  Any lower than 7, throwing the object will make it fly through walls. Any higher than 100, and it becomes un-liftable, so why even grab it*/
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
		bLimitMaxPhysicsVelocity = true;
		MaxPhysicsVelocity = 450;
	}

function Drop() 
	{
	  InterpAlpha = 0;
	  ReleaseGrabbedActor(PhysicsGrabber);
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

protected function bool CanStillHold() 
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

protected function Pawn GetPlayerPawn() 
	{
	  if(PlayerPawn == None)
		PlayerPawn = GetALocalPlayerController().Pawn;

	  return PlayerPawn;
	}

protected function bool PlayerBasedOnMe() 
	{
	  return GetPlayerPawn().Base == Self;
	}

/************************/



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


		InterpAlpha=0.0
		bNoEncroachCheck=false
		bWakeOnLevelStart=true
		bNoDelete=false
		bCanStepUpOn=false
		bPawnCanBaseOn=true
		bSafeBaseIfAsleep=false
		

  
		HighFrictionMat=PhysicalMaterial'timorem_devpak.Materials.HighFriction'
		LowFrictionMat=PhysicalMaterial'timorem_devpak.Materials.LowFriction'
  
	}

