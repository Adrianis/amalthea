
class amPlayerController extends GamePlayerController
	config(Game);


/*** Vars from Grosie's leaning ***/
var float Lean; //Can be -1,0 , or 1. Set by the exec functions that handle lean left/right
var float LeanAccel; //Used in script.
var float LeanSpeed; //Set it up in the default properties block to 10.0f for example
var float LeanAngle; // What is the angle of the leaning? Set it to 15 for example in the default properties

	var amGrabObject HeldObject; // reference for amPawn.CurrentlyHeldObject
	var bool bSpinningObject; // flag for checking if player is spinning an object



/*********************
 * Code from UTPlayerController 
 * *******************/
function CheckJumpOrDuck()
{
	if ( Pawn == None )
	{
		return;
	}
	if ( bDoubleJump && (bUpdating || ((amPawn(Pawn) != None) && amPawn(Pawn).CanDoubleJump())) )
	{
		amPawn(Pawn).DoDoubleJump( bUpdating );
	}
    else if ( bPressedJump )
	{
		Pawn.DoJump( bUpdating );
	}
	if ( Pawn.Physics != PHYS_Falling && Pawn.bCanCrouch )
	{
		// crouch if pressing duck
		Pawn.ShouldCrouch(bDuck != 0);
	}
}
/***************************/


/*****************************
 * Code from Grosie's Leaning
 * **************************/

state PlayerWalking 
{
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot) 
	{
		local vector X,Y,Z;
		local Rotator ViewRotation;
		ViewRotation = Rotation;
		GetAxes(ViewRotation,X,Y,Z);
		NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y + LeanAccel*Y;
		if (LeanAccel > 0.1f && LeanAccel != 0.0f) {
			LeanAccel -= (deltaTime * 5.0f);
		}
		else if (LeanAccel < -0.1f && LeanAccel != 0.0f) {
			LeanAccel += (deltaTime * 5.0f);
		}
		else {
			LeanAccel = 0.0f;
		}
		Super.ProcessMove(DeltaTime,NewAccel,DoubleClickMove,DeltaRot);
	}
	
	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;
		local Rotator DeltaRot, ViewRotation;

		GetAxes(Rotation,X,Y,Z);
		// Update view rotation.
		ViewRotation = Rotation;
		// Calculate Delta to be applied on ViewRotation
		DeltaRot.Yaw	= PlayerInput.aTurn;
		DeltaRot.Pitch	= PlayerInput.aLookUp;
		
		if (Lean != 0) 
			DeltaRot.Roll = 100.f * DeltaTime * LeanSpeed * Lean;
		else {
			if (ViewRotation.Roll < 0) {
				DeltaRot.Roll = 100.f * DeltaTime * LeanSpeed;
			}
			else if (ViewRotation.Roll > 0) {
				DeltaRot.Roll = -100.f * DeltaTime * LeanSpeed;
			}
		}
		
		ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
		
		if ( ViewRotation.Roll > LeanAngle * 100 && Lean == 1) {
			ViewRotation.Roll = LeanAngle * 100;
		}
			
		if (ViewRotation.Roll < LeanAngle * -100 && Lean == -1) {
			ViewRotation.Roll = LeanAngle * -100;
		}
		
		if (ViewRotation.Roll != 0 && Lean == 0) {
			if (ViewRotation.Roll > 0 && DeltaRot.Roll > 0) {
				ViewRotation.Roll = 0;
			}
			
			if (ViewRotation.Roll < 0 && DeltaRot.Roll < 0) {
				ViewRotation.Roll = 0;
			}
		}
		
		SetRotation(ViewRotation);
		UpdateRotation(DeltaTime);
		
		Super.PlayerMove(DeltaTime);
	}
}
/********************************************/


/****************************************
 * Door Grabbing control 
 * **************************************/

state GrabbedDoor extends PlayerWalking
{
	function ProcessViewRotation(float DeltaTime, out Rotator out_ViewRotation, Rotator DeltaRot)
	{
		// Need to check at this point if the object is in range, to prevent issue where with only 1 check 
		//  at the initial grab, you can walk away from the object and still move it when out of range

		// Also note that it needs to use the VSize check manually rather than using IsReachable() as simply using that function 
		//  produces a bug where the direction for yaw force is reversed when standing to the -y of the object

		HeldObject = amPawn(Pawn).CurrentlyHeldObject;

		if (VSize(HeldObject.Location - Pawn.Location) < HeldObject.HoldDistanceMax)
		{
			// send the rotation change data over to ProcessDoorMove in amGrabObject
			amGrabDoor(HeldObject).ProcessDoorMove(DeltaTime, out_ViewRotation, DeltaRot);
		}
		else 
		{
			// exit this state if the door is out of range
			self.GotoState('PlayerWalking');
		}
	}
}

state SpinningHoldObject extends PlayerWalking
{
	function ProcessViewRotation(float DeltaTime, out Rotator out_ViewRotation, Rotator DeltaRot)
	{
		HeldObject = amPawn(Pawn).CurrentlyHeldObject;
		amGrabCrate(HeldObject).ProcessObjectSpin(DeltaTime, out_ViewRotation, DeltaRot);
	}

	// security, make sure flags are set correctly
	function BeginState(name PreviousStateName) { bSpinningObject = true; }
	function EndState(name NextStateName) { bSpinningObject = false; }
}


exec function StartObjectSpin()
	{
		`log("STARTOBJECTSPIN");

		HeldObject = amPawn(Pawn).CurrentlyHeldObject;

		// only change state if the player is grabbing a hold object
		if (HeldObject.GrabbedCrate() 
			&& HeldObject.IsA('amGrabCrate')) {
				self.GotoState('SpinningHoldObject');
				bSpinningObject = true;
		}
	}
exec function StopObjectSpin()
	{
		`log("STOPOBJECTSPIN");
		
		// exit spinning state if we are in it
		if (bSpinningObject) {
			self.GotoState('PlayerWalking');
			bSpinningObject = false;
		}
	}


exec function ToggleTorch()
	{
		amPawn(Pawn).ToggleTorch();	
	}

defaultproperties
	{
		InputClass=class'amalthea.amPlayerInput'

		/* From Grosie's Leaning */
		LeanSpeed=60.0f
		LeanAngle=15

	}