class amTorch extends SpotLightMovable
	notplaceable;

DefaultProperties
{
	Begin Object name=SpotLightComponent0
        LightColor=(R=255,G=255,B=255)
		InnerConeAngle = 20.00
		OuterConeAngle = 22.00
		
	//	bCastCompositeShadow=false // makes it light the model only very slightly
	//	bCanAffectDynamicPrimitivesOutsideDynamicChannel = true // nothing?
	//	bHasLightEverBeenBuiltIntoLightMap = false // nothing?
	//	bUseVolumes = true // Warning
	//	bForceDynamicLight = true // nothing

    End Object
    bNoDelete=FALSE
}
