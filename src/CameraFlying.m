function CameraFlying(varargin)

	if 0==nargin
		outputType = 'Video';
	elseif strcmp(varargin{1}, 'Animation') || strcmp(varargin{1}, 'Video')
		outputType = varargin{1};
	else
		warning('Wrong Input!'); return;
	end
	outPath = './data/';
	[az, el] = view;
	nFrame = 180;
	step = 360/nFrame;
	light('visible', 'off');
	lighting gouraud;
	switch outputType
		case 'Animation'
			filename = strcat(outPath, 'rotatingObject3D.gif');
			for ii=1:nFrame
				% disp(['Progress.: ' sprintf('%6i',ii) ' Total.: ' sprintf('%6i',nFrame)]);
				hdLight = camlight(az, el);
				material dull; %% dull, shiny, metal
				f = getframe(gcf);
				im = frame2im(f);
				[imind, cm] = rgb2ind(im, 256);
				if ii==1
					imwrite(imind, cm, filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
				else
					imwrite(imind, cm, filename, 'gif', 'writeMode', 'append', 'DelayTime', 0.1);
				end
				set(hdLight,'visible','off');
				az = step+az;
				view(az, el);
			end			
		case 'Video'
			filename = strcat(outPath, 'rotatingObject3D.mp4');
			v = VideoWriter(filename, 'MPEG-4');
			v.Quality = 100;
			v.FrameRate = 10;
			open(v);
			for ii=1:nFrame
				% disp(['Progress.: ' sprintf('%6i',ii) ' Total.: ' sprintf('%6i',nFrame)]);
				hdLight = camlight(az, el);
				material metal; %% dull, shiny, metal
				f = getframe(gcf);
				writeVideo(v,f);
				set(hdLight,'visible','off');
				az = step+az; %% rotate Z
				% el = -step+el; %% rotate X
				view(az, el);
			end
			close(v);		
	end
end