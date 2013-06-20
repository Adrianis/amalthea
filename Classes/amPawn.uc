
class amPawn extends UTPawn
	config(Game)
	notplaceable;

var amTorch Torch; // add torch as variable
var bool bIsTorchOn; // flag for on/off

var Rotator TorchCurrentRotation; // holds previous Rot of player's view, for delaying update of torch Rot
var Rotator TorchDesiredRotation; // takes new Rot of player's view, for delaying update of torch Rot

var PlayerController MyController; // hold ref to current PC, set in Postbeginplay

var amGrabObject CurrentlyHeldObject; // Keeps track of held object
var float ThrowForce; // Force applied when throwing held object


simulated function PostBeginPlay()
	{

	// TORCH STUFF ----------------------------------------
		Torch = Spawn(class'amTorch', self);
		Torch.SetBase(self);
		Torch.LightComponent.SetEnabled(bIsTorchOn);
	//	---------------------------------------------------

		MyController = GetALocalPlayerController();

		super.PostBeginPlay();
	}

event UpdateEyeHeight(float DeltaTime)
	{
		super.UpdateEyeHeight(DeltaTime);


	// TORCH SWING DELAY ------------------------------
		TorchDesiredRotation = Controller.Rotation; // get actual rot as desired rot
		if (TorchCurrentRotation != TorchDesiredRotation) // assuming current rot is not the desired rot
		{
			TorchCurrentRotation = RInterpTo(TorchCurrentRotation, TorchDesiredRotation, DeltaTime, 10); // interp value for current rot against desired rot
		}
		Torch.SetRotation(TorchCurrentRotation); // set the torch rot to interped val for current rot
	}

simulated function ToggleTorch()
	{
		bIsTorchOn = !bIsTorchOn; 
		Torch.LightComponent.SetEnabled(bIsTorchOn);
	}


/*******************************
 * 
 *  OVERRIDES FOR UTPawn
 * 
 * *****************************/

function bool Dodge(eDoubleClickDir DoubleClickMove)
	{}


event SetWalking( bool bNewIsWalking )
	{
		super(Pawn).SetWalking(!bNewIsWalking);
	}

/***********************************/


/*****************************
 * 
 * For Physics grabbing
 * 
 ****************************/

simulated function StartFire(byte FireModeNum)
	{
		local amGrabObject HitActor;
		if (FireModeNum == 0) 
		{
			HitActor = amGrabObject(amHUD(MyController.myHUD).HitActor); // run trace to find actor in the players crosshair

			if(HitActor.IsA('amGrabObject')) // check that hitactor is valid grab object
			{
				HitActor.ToggleGrab(); // run grab func from amGrabObject
				CurrentlyHeldObject = HitActor; // get reference to held object
				self.GoToState('CarryingObject'); // Tell the player to go into the CarryingObject state
			}
		}
	}

simulated function StopFire(byte FireModeNum)
	{
		if (FireModeNum == 0) 
		{
			CurrentlyHeldObject.Drop(); // execute Drop func from amGrabCrate
			CurrentlyHeldObject = none; // remove reference to held object
			self.GotoState('Auto'); // reset to default state
		}
	}


state CarryingObject
{

	simulated function StartFire(byte FireModeNum) // This basically overwrites the shoot mechanism while in this state
	{
		local amGrabObject ThrownObject; // This is a temporary way of remembering which object we're throwing
		if (FireModeNum == 1)
		{
			if (CurrentlyHeldObject != none)
			{
				ThrownObject = CurrentlyHeldObject;
				CurrentlyHeldObject.Drop(); // This sets CurrentlyHeldObject to be none, hence why we need ThrownObject
				ThrownObject.ApplyImpulse(Vector(Controller.Rotation), ThrowForce, self.Location); // Launches the object in the direction the player is facing
				CurrentlyHeldObject = none; // remove reference to held object, prevent continued remote throwing
			}
		}
	}

	event BeginState(name PreviousStateName) // This is called when a player first enters the state
	{
		if (CurrentlyHeldObject.IsA('amGrabDoor'))
			MyController.GotoState('GrabbedDoor');
	}

	event EndState(name NextStateName)
	{
		// need to not check if it's a door, as the reference may already be none, and the PC needs to go back to normal anyway
		MyController.GotoState('PlayerWalking'); 

		if (CurrentlyHeldObject != none)
		{
			CurrentlyHeldObject.Drop();
			CurrentlyHeldObject = none;
		}
	}
}



/*********************************
	Needed to pass players view rotation change data to
	amGrabDoor, and keep the amGrabObject type for CurrentlyHeldObject
	**********/
function PassOnRotationData(float DeltaTime, Rotator ViewRotation, Rotator DeltaRot)
{
	amGrabDoor(CurrentlyHeldObject).ProcessDoorMove(DeltaTime, ViewRotation, DeltaRot);
}
/******************************************/





defaultproperties
	{

	// OVERRIDES FOR UTPAWN ----------

		Begin Object Name=CollisionCylinder
			CollisionRadius=+0020.000000
			CollisionHeight=+0050.000000
			//BlockNonZeroExtent=true
			//BlockZeroExtent=true
			BlockActors=true
			CollideActors=true
			End Object
		CylinderComponent=CollisionCylinder
		
		BaseEyeHeight=60.0
		EyeHeight=60.0
		CrouchHeight=35.0

		JumpZ=370.0

		ViewPitchMin=-12000
		ViewPitchMax=15000

		GroundSpeed=600.0 // base running speed
		WalkingPct=+0.5 // division of base running speed when walking is applied
		CrouchedPct=+0.3 // division of base running speed when crouching is applied
		bCanCrouch=true // enable crouching

		bCanDoubleJump=false // removes double jump
		MaxMultiJump=0 // removes double jump
		
	//-----------------------------

		InventoryManagerClass=class'amalthea.amInventoryManager'

		bIsTorchOn = false // initialise false so torch is not on at start
		ThrowForce=100000 // amount of force to apply when throwing held object


	}