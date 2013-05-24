
class amHUD extends HUD;


var Actor HitActor; // From PhysicsGrabber


/**********************
 * Code from PhysicsGrabber
 *********************/
function DrawHUD() {
  Super.DrawHUD();
  Canvas.SetDrawColorStruct(WhiteColor);
  Canvas.SetPos(CenterX, CenterY);
  Canvas.DrawRect(5, 5);
  HUDTrace();
}

function HUDTrace() {
  local Vector Loc, Norm, End, PlayerViewPointLoc;
  local PlayerController Player;
  local Rotator PlayerViewPointRot;
  
  Player = WorldInfo.GetALocalPlayerController();
  Player.Pawn.GetActorEyesViewPoint(PlayerViewPointLoc, PlayerViewPointRot);

  PlayerViewPointLoc = PlayerViewPointLoc + (32 * Vector(PlayerViewPointRot));
  End = PlayerViewPointLoc + Normal(Vector(PlayerViewPointRot)) * 32768;
  HitActor = Trace(Loc, Norm, End, PlayerViewPointLoc, true);
}
/********************************************/





defaultproperties
{
}