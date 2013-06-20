class amSecurityDoor extends amGrabDoor
	placeable;

DefaultProperties
{
	Begin Object Name=StaticMeshComponent0
  		StaticMesh=StaticMesh'timorem_doors.SecurityDoor'
	End Object
	Components.Add(StaticMeshComponent0)
	CollisionComponent=StaticMeshComponent0
}
