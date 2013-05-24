class amPlayerInput extends PlayerInput within amPlayerController;

simulated exec function Duck()
{
		if(bDuck == 0) bDuck = 1;
}
simulated exec function UnDuck()
{
		if(bDuck == 1) bDuck = 0;
}

DefaultProperties
{
}
