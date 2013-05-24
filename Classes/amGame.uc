
class amGame extends UDKGame;


var PlayerController Player;


//========================================================================

event PreLogin(
    string Options,
    string Address,
    const UniqueNetId UniqueId,
    bool bSupportsAuth,
    out string ErrorMessage
) {
    super.PreLogin(Options, Address, UniqueID, bSupportsAuth, ErrorMessage);
}


event PlayerController Login(
    string Portal,
    string Options,
    const UniqueNetID UniqueID,
    out string ErrorMessage ) 
{
    Player = Spawn(PlayerControllerClass, Self);
    return Player;
}


event PostLogin(PlayerController NewPlayerController) {
    NewPlayerController.Pawn = SpawnPlayerPawn();
    NewPlayerController.Possess(NewPlayerController.Pawn, false);
    NewPlayerController.ClientSetHUD(HUDType);
}

//========================================================================

protected function Pawn SpawnPlayerPawn() {
    local Pawn NewPawn;
    local vector SpawnPosition;
    local PlayerStart PS;
    
    /// Spawn at first available spawn position
    foreach WorldInfo.AllNavigationPoints(class'PlayerStart', PS) {
        if(PS != None) SpawnPosition = PS.Location;
    }
    
    NewPawn = Spawn(DefaultPawnClass,,, SpawnPosition);
    
    return NewPawn;
}

//========================================================================






defaultproperties
{
	bDelayedStart=false
    PlayerControllerClass=class'amalthea.amPlayerController'
    DefaultPawnClass=class'amalthea.amPawn'
    HUDType=class'amalthea.amHUD'

	bPushedByEncroachers=false // from PhysicsGrabber
}