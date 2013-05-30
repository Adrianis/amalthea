class amPlayerInput extends PlayerInput within amPlayerController;

var float LastDuckTime;
var bool  bHoldDuck;

simulated exec function Duck()
{
	if ( amPawn(Pawn)!= none )
	{
		if (bHoldDuck)
		{
			bHoldDuck=false;
			bDuck=0;
			return;
		}

		bDuck=1;

		if ( WorldInfo.TimeSeconds - LastDuckTime < DoubleClickTime )
		{
			bHoldDuck = true;
		}

		LastDuckTime = WorldInfo.TimeSeconds;
	}
}

simulated exec function UnDuck()
{
	if (!bHoldDuck)
	{
		bDuck=0;
	}
}

/***********************
 * From Grosie's Leaning
 * *********************/
exec function PlayerLeanLeft (bool shouldLean) {
	//Insert Leaning Left Code here
	`log("Lean Left: "$shouldLean);
	if (shouldLean) {
		Lean -= 1.0f;
		LeanAccel -= 1.0f;
	}
	else {
		Lean += 1.0f;
		LeanAccel += 1.0f;
	}
}

exec function PlayerLeanRight (bool shouldLean) {
	//Insert Leaning Right Code here
	`log("Lean Right: "$shouldLean);
	if (shouldLean) {
		Lean += 1.0f;
		LeanAccel += 1.0f;
	}
	else {
		Lean -= 1.0f;
		LeanAccel -= 1.0f;
	}
}





DefaultProperties
{
}
