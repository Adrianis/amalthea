class amWoodenCrate extends amGrabCrate
	placeable;

DefaultProperties
{
	Begin Object Name=StaticMeshComponent0
  		StaticMesh=StaticMesh'Timorem_Props.WoodenCrate'
	End Object
	Components.Add(StaticMeshComponent0)
	CollisionComponent=StaticMeshComponent0

	bCollideActors=true
	bCollideWorld=true
	Mass=13
}