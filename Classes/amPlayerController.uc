
class amPlayerController extends GamePlayerController
	config(Game);


exec function ToggleTorch()
	{
		amPawn(Pawn).ToggleTorch();	
	}

defaultproperties
	{
		InputClass=class'amalthea.amPlayerInput'
	}