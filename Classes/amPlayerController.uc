
class amPlayerController extends GamePlayerController
	config(Game);


/*** Vars from Grosie's leaning ***/
var float Lean; //Can be -1,0 , or 1. Set by the exec functions that handle lean left/right
var float LeanAccel; //Used in script.
var float LeanSpeed; //Set it up in the default properties block to 10.0f for example
var float LeanAngle; // What is the angle of the leaning? Set it to 15 for example in the default properties



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
		// send the rotation change data over to ProcessDoorMove in amGrabObject
		amPawn(Pawn).CurrentlyHeldObject.ProcessDoorMove(DeltaTime, out_ViewRotation, DeltaRot);
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