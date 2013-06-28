class amSceneCapture extends SceneCapture2DActor;

DefaultProperties
{
	// 2D scene capture
	Begin Object Name=SceneCapture2DComponent0
		FieldOfView=50
		NearPlane=20
		FarPlane=3000
		FrameRate=30
		ViewMode=SceneCapView_Lit
		TextureTarget=TextureRenderTarget2D'timorem_devpak.Materials.PhoneDisplay'
	End Object
	SceneCapture=SceneCapture2DComponent0
	Components.Add(SceneCapture2DComponent0)
	bNoDelete=false
	bStatic=false
}
