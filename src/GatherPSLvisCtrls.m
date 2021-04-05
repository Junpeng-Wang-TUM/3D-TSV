function [imOpt, imVal, pslGeo, stressComponentOpt, lw, ribbonSmoothingOpt, miniPSLength] = GatherPSLvisCtrls(appLabel)
	global handleGraphicPSLsPrimitives_;
	imOpt = [convertCharsToStrings(appLabel.MajorLoDsDropDown.Value) convertCharsToStrings(appLabel.MediumLoDsDropDown.Value) ...
			convertCharsToStrings(appLabel.MinorLoDsDropDown.Value)];
	imVal = [appLabel.MajorResCtrlSlider.Value appLabel.MediumResCtrlSlider.Value appLabel.MinorResCtrlSlider.Value];
	pslGeo = [convertCharsToStrings(appLabel.MajorPSLGeometryDropDown.Value) ...
		convertCharsToStrings(appLabel.MediumPSLGeometryDropDown.Value) convertCharsToStrings(appLabel.MinorPSLGeometryDropDown.Value)];
	stressComponentOpt = appLabel.ColoringDropDown.Value;
	switch appLabel.ColoringDropDown.Value
		case 'None'
			stressComponentOpt = 'None';
		case 'Principal Stress', stressComponentOpt = 'Sigma';
		case 'Mises Stress', stressComponentOpt = 'Sigma_vM';
		case 'Normal Stress (xx)', stressComponentOpt = 'Sigma_xx';
		case 'Normal Stress (yy)', stressComponentOpt = 'Sigma_yy';
		case 'Normal Stress (zz)', stressComponentOpt = 'Sigma_zz';
		case 'Shear Stress (yz)', stressComponentOpt = 'Sigma_yz';
		case 'Shear Stress (zx)', stressComponentOpt = 'Sigma_zx';
		case 'Shear Stress (xy)', stressComponentOpt = 'Sigma_xy';
	end
	lw = appLabel.PSLGeometryScalingFacEditField.Value;
	ribbonSmoothingOpt = appLabel.SmoothingRibbonCheckBox.Value;
	miniPSLength = appLabel.PermittedMinLengthofVisiblePSLEditField.Value;
	if ~isempty(handleGraphicPSLsPrimitives_)
		set(handleGraphicPSLsPrimitives_, 'visible', 'off'); handleGraphicPSLsPrimitives_ = [];
	end
end
