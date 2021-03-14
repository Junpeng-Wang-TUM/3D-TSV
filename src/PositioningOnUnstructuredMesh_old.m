function [nextElementIndex, opt] = PositioningOnUnstructuredMesh_old(oldElementIndex, physicalCoordinates)
	global nodeCoords_; global eleCentroidList_; 
	global eNodMat_; global nodStruct_;
	global boundaryElements_;
	nextElementIndex = 0; opt = 0;
	tarNodes = eNodMat_(oldElementIndex,:); 
	potentialElements = unique([nodStruct_(tarNodes(:)).adjacentEles]);
	tarNodes = eNodMat_(potentialElements,:); 
	potentialElements = unique([nodStruct_(tarNodes(:)).adjacentEles]); %% balance between safety and efficiency
	disList = vecnorm(physicalCoordinates-eleCentroidList_(potentialElements,:), 2, 2);
	[~, nextElementIndex] = min(disList); nextElementIndex = potentialElements(nextElementIndex);
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% safe but low efficiency version
	% disList = vecnorm(physicalCoordinates-eleCentroidList_, 2, 2);
	% [minVal, nextElementIndex] = min(disList); 
	boundaryMetric = intersect(nextElementIndex, boundaryElements_);
	opt = 1;
	if ~isempty(boundaryMetric)
		eleNodeCoords = nodeCoords_(eNodMat_(nextElementIndex,:)',:);
		[~, ~, opt, ~] = NewtonIteration(eleNodeCoords, physicalCoordinates);
	end	
end

function [paraCoordinates, res, opt, index] = NewtonIteration(vtxVec, target)
	%% solving a nonlinear system of equasions by Newton-Rhapson's method
	%%	f1(s,t,p) = tar1
	%%	f2(s,t,p) = tar2
	%%	:			:
	%%	:			:
	%%	fi(s,t,p) = tari
	opt = 0;
	normTar = norm(target);
	errThreshold = 1.0e-4; RF = 100*errThreshold;
	s = -0.0; t = -0.0; p = -0.0; maxIts = 200;
	index = 0;
	for ii=1:maxIts
		index = index+1;
		c0 = ShapeFunction(s, t, p)';	
		dShape = DeShapeFunction(s, t, p);
		dns = dShape(1,:)';
		dnt = dShape(2,:)';
		dnp = dShape(3,:)';
		d2Shape = De2ShapeFunction(s, t, p);
		dnss = d2Shape(1,:)';
		dntt = d2Shape(2,:)';
		dnpp = d2Shape(3,:)';
		dntp = d2Shape(4,:)';
		dnps = d2Shape(5,:)';
		dnst = d2Shape(6,:)';		
		
		q = vtxVec' * c0;
		dqs = vtxVec' * dns;
		dqt = vtxVec' * dnt;
		dqp = vtxVec' * dnp;
			
		dfdv1 = [dqs'; dqt'; dqp'];
		b = dfdv1*(q-target');
		if 0==normTar
			res = norm(q-target');
		else
			res = norm(b);
		end
		if res < errThreshold, break; end

		dfdss = vtxVec'*dnss;
		dfdtt = vtxVec'*dntt;
		dfdpp = vtxVec'*dnpp;
		dfdtp = vtxVec'*dntp;
		dfdps = vtxVec'*dnps;
		dfdst = vtxVec'*dnst;
		A11 = dfdss' * (q-target') + norm(dqs)^2;
		A22 = dfdtt' * (q-target') + norm(dqt)^2;
		A33 = dfdpp' * (q-target') + norm(dqp)^2;
		A21 = dfdst' * (q-target') + dqs'*dqt; A12 = A21;
		A23 = dfdtp' * (q-target') + dqt'*dqp; A32 = A23;
		A31 = dfdps' * (q-target') + dqp'*dqs; A13 = A31;
		A = [A11 A12 A13; A21 A22 A23; A31 A32 A33];
		x = A\(-b);
		s = s + x(1); t = t + x(2); p = p + x(3);
	end
	
	if res <= errThreshold && abs(s)<=RF+1 && abs(t)<=RF+1 && abs(p)<=RF+1
		opt = 1;
	end
	paraCoordinates = [s t p];
end


function N = ShapeFunction(s, t, p)
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
	N(1) = 0.125*(1-s)*(1-t)*(1-p);
	N(2) = 0.125*(1+s)*(1-t)*(1-p);
	N(3) = 0.125*(1+s)*(1+t)*(1-p);
	N(4) = 0.125*(1-s)*(1+t)*(1-p);
	N(5) = 0.125*(1-s)*(1-t)*(1+p);
	N(6) = 0.125*(1+s)*(1-t)*(1+p);
	N(7) = 0.125*(1+s)*(1+t)*(1+p);
	N(8) = 0.125*(1-s)*(1+t)*(1+p);			
end

function dShape = DeShapeFunction(s, t, p)		
	dN1ds = -0.125*(1-t)*(1-p); dN2ds = 0.125*(1-t)*(1-p); 
	dN3ds = 0.125*(1+t)*(1-p);  dN4ds = -0.125*(1+t)*(1-p);
	dN5ds = -0.125*(1-t)*(1+p); dN6ds = 0.125*(1-t)*(1+p); 
	dN7ds = 0.125*(1+t)*(1+p);  dN8ds = -0.125*(1+t)*(1+p);
	
	dN1dt = -0.125*(1-s)*(1-p); dN2dt = -0.125*(1+s)*(1-p); 
	dN3dt = 0.125*(1+s)*(1-p);  dN4dt = 0.125*(1-s)*(1-p);
	dN5dt = -0.125*(1-s)*(1+p); dN6dt = -0.125*(1+s)*(1+p); 
	dN7dt = 0.125*(1+s)*(1+p);  dN8dt = 0.125*(1-s)*(1+p);
	
	dN1dp = -0.125*(1-s)*(1-t); dN2dp = -0.125*(1+s)*(1-t); 
	dN3dp = -0.125*(1+s)*(1+t); dN4dp = -0.125*(1-s)*(1+t);
	dN5dp = 0.125*(1-s)*(1-t);  dN6dp = 0.125*(1+s)*(1-t); 
	dN7dp = 0.125*(1+s)*(1+t);  dN8dp = 0.125*(1-s)*(1+t);
	
	dShape = [
		dN1ds dN2ds dN3ds dN4ds dN5ds dN6ds dN7ds dN8ds
		dN1dt dN2dt dN3dt dN4dt dN5dt dN6dt dN7dt dN8dt
		dN1dp dN2dp dN3dp dN4dp dN5dp dN6dp dN7dp dN8dp ];	
end

function d2Shape = De2ShapeFunction(s, t, p)	
	dN1dss = 0; dN2dss = 0; dN3dss = 0;  dN4dss = 0;	
	dN5dss = 0; dN6dss = 0; dN7dss = 0;  dN8dss = 0;
	
	dN1dtt = 0; dN2dtt = 0; dN3dtt = 0; dN4dtt = 0;
	dN5dtt = 0; dN6dtt = 0; dN7dtt = 0; dN8dtt = 0;
	
	dN1dpp = 0; dN2dpp = 0; dN3dpp = 0; dN4dpp = 0;
	dN5dpp = 0; dN6dpp = 0; dN7dpp = 0; dN8dpp = 0;
	
	dN1dst = 1-p;		dN2dst = -(1-p);		dN3dst = 1-p;		dN4dst = -(1-p);
	dN5dst = 1+p;		dN6dst = -(1+p);		dN7dst = 1+p;		dN8dst = -(1+p);
	
	dN1dsp = 1-t;		dN2dsp = -(1-t);		dN3dsp = -(1+t);	dN4dsp = 1+t;
	dN5dsp = -(1-t);	dN6dsp = 1-t;			dN7dsp = 1+t;		dN8dsp = -(1+t);
	
	dN1dtp = 1-s;		dN2dtp = 1+s;			dN3dtp = -(1+s);	dN4dtp = -(1-s);
	dN5dtp = -(1-s);	dN6dtp = -(1+s);		dN7dtp = 1+s;		dN8dtp = 1-s;
				
	d2Shape = [
		dN1dss dN2dss dN3dss dN4dss dN5dss dN6dss dN7dss dN8dss
		dN1dtt dN2dtt dN3dtt dN4dtt dN5dtt dN6dtt dN7dtt dN8dtt
		dN1dpp dN2dpp dN3dpp dN4dpp dN5dpp dN6dpp dN7dpp dN8dpp
		dN1dtp dN2dtp dN3dtp dN4dtp dN5dtp dN6dtp dN7dtp dN8dtp
		dN1dsp dN2dsp dN3dsp dN4dsp dN5dsp dN6dsp dN7dsp dN8dsp
		dN1dst dN2dst dN3dst dN4dst dN5dst dN6dst dN7dst dN8dsp ];
	d2Shape = 0.125 * d2Shape;	
end
