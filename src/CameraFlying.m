function CameraFlying(varargin)
	if 0==nargin, axHandle_ = gca; else, axHandle_ = varargin{1}; end
	outPath = './data/';
	[az, el] = view(axHandle_);
	nFrame = 180;
	step = 360/nFrame;
	light(axHandle_, 'visible', 'off');
	lighting(axHandle_, 'gouraud');
	filename = strcat(outPath, 'result.mp4');
	v = VideoWriter(filename, 'MPEG-4');
	v.Quality = 100;
	v.FrameRate = 10;
	open(v);
	for ii=1:nFrame
		hdLight = camlight(axHandle_, 'headlight','infinite'); 
		material(axHandle_, 'dull'); %% dull, shiny, metal
		f = getframe(gcf);
		writeVideo(v,f);
		set(hdLight,'visible','off');
		az = step+az; %% rotate Z
		view(axHandle_, az, el);
	end
	close(v);
	camlight(axHandle_, 'headlight','infinite');
end