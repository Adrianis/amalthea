class amSwarmBox extends amWoodenCrate
	placeable;
	
	var() Vector SwarmTargetPoint;
	var() float MoveForceMag;

	var bool bPhysGrabEnabled;

auto state Swarm
{
	simulated function Tick(float DeltaTime)
	{
		//local Vector NewPos, CurPos;

		`log("amSwarmBox:  Swarm Tick is happening");
		
		if (!bPhysGrabEnabled)
			EnablePhysicsGrabber();

		
		PhysicsGrabber.AddImpulse((PhysicsGrabber.Location - SwarmTargetPoint) * MoveForceMag);

		
		//CurPos = PhysicsGrabber.Location;

		//NewPos = VInterpTo(CurPos, SwarmTargetPoint, DeltaTime, VInterpSpeed);
		//PhysicsGrabber.SetLocation(NewPos);
	}

	function EnablePhysicsGrabber()
	{
		PhysicsGrabber.GrabComponent(CollisionComponent, 'None', CollisionComponent.Bounds.Origin, true);
		bPhysGrabEnabled = true;
	}
}

DefaultProperties
{
	//VInterpSpeed = 20
	MoveForceMag = 1.5
}
