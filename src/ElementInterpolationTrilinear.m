function varargout = ElementInterpolationTrilinear(vtxEntity, ips)
	%% vtxEntity --> entities on element vertics, Matrix: [N-by-M], e.g., M = 6 for 3D stress tensor, = 3 for 3D deformation vector
	%% ips --> to-be interpolated position in natural coordinate system
	%				*8			*7
	%			*5			*6
	%					p
	%				   |__s 
	%				  /-t
	%				*4			*3
	%			*1			*2
	%
	%			LINEAR:	8-nodes
	%--------------------------------------------------------------------------------		
	N = zeros(1,8);
	s = ips(1); t = ips(2); p = ips(3);
	N(1) = 0.125*(1-s)*(1-t)*(1-p);
	N(2) = 0.125*(1+s)*(1-t)*(1-p);
	N(3) = 0.125*(1+s)*(1+t)*(1-p);
	N(4) = 0.125*(1-s)*(1+t)*(1-p);
	N(5) = 0.125*(1-s)*(1-t)*(1+p);
	N(6) = 0.125*(1+s)*(1-t)*(1+p);
	N(7) = 0.125*(1+s)*(1+t)*(1+p);
	N(8) = 0.125*(1-s)*(1+t)*(1+p);	
	varargout{1} = N * vtxEntity;
	varargout{2} = N;
end