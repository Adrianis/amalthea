class amSecurityDoor extends amGrabDoor
	placeable;

DefaultProperties
{
	Begin Object Name=StaticMeshComponent0
  		StaticMesh=StaticMesh'timorem_doors.SecurityDoor'
	End Object
	Components.Add(StaticMeshComponent0)
	CollisionComponent=StaticMeshComponent0

	Begin Object Class=DynamicLightEnvironmentComponent Name=LightEnvironment0
		bEnabled=true
		bCastShadows=true
		bCompositeShadowsFromDynamicLights=true
		bDynamic=true
		bSynthesizeDirectionalLight=true
	End Object
	Components.Add(LightEnvironment0)
}
