function varargout = NodalizeDesignDomain(varargin)
	numSeed = varargin{1};
	nx = numSeed(1); ny = numSeed(2); nz = numSeed(3);
	dd = varargin{2};		
	xSeed = dd(1,1):(dd(2,1)-dd(1,1))/nx:dd(2,1);
	ySeed = dd(2,2):(dd(1,2)-dd(2,2))/ny:dd(1,2);
	zSeed = dd(1,3):(dd(2,3)-dd(1,3))/nz:dd(2,3);		
	varargout{1} = repmat(xSeed, ny+1, 1);
	varargout{1} = reshape(varargout{1}, (nx+1)*(ny+1), 1);
	varargout{1} = repmat(varargout{1}, (nz+1), 1);
	varargout{2} = repmat(ySeed, 1, nx+1 )';
	varargout{2} = repmat(varargout{2}, (nz+1), 1);
	varargout{3} = repmat(zSeed, (nx+1)*(ny+1), 1);
	varargout{3} = reshape(varargout{3}, (nx+1)*(ny+1)*(nz+1), 1);
	if 3==nargin & strcmp(varargin{3}, 'inGrid')
		varargout{1} = reshape(varargout{1}, ny+1, nx+1, nz+1);
		varargout{2} = reshape(varargout{2}, ny+1, nx+1, nz+1);
		varargout{3} = reshape(varargout{3}, ny+1, nx+1, nz+1);			
	end	
end