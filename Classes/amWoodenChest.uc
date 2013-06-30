class amWoodenChest extends amGrabCrate
	placeable;

DefaultProperties
{
	Begin Object Name=StaticMeshComponent0
  		StaticMesh=StaticMesh'Timorem_Props.WoodenChest'
	End Object
	Components.Add(StaticMeshComponent0)
	CollisionComponent=StaticMeshComponent0
	Mass=35
}
