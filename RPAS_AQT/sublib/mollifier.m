function phi_m = mollifier(varargin)

% MOLLIFIER Generates a mollifier function:
%
%
%	\phi_m(x) = n^dim * \phi(nx),
%
% where
%
%	phi(x) = C * \left\{ \exp[-1/(1-\norm{x}^2)],		if \norm{x}<1, \\
%						0,	otherwise \right.
%
% and C is the constant such that
%
%	\int_{R^dim} \phi(x) dx = 1.
%
%
%	phi_m = mollifier(n,dim,r,m) generates a dim-D mollifier function used
%	to smooth a non smoothing function. The variables have the following meaning:
%
%	Output:
%		phi_m:		is the computed mollifier
%
%	Input:
%		n:		grid size
%		dim:	dimension of the mollifier function, 
%				dim can have values 1, 2 or 3
%		m:		parameter m of the mollifier \phi_m. 
%				m is default set to 0.5;
%
%
	[dim, n, m] = parse_inputs(varargin{:});
	switch (dim)
		case 1
			c = 1.0/0.4440;
		case 2
			c = 1/0.4665;
		case 3
			c = 1/0.4411;
	end
	
	%fprintf(1,'c=%g, n=%d, m=%d\n', c, n, m);
	scale = -m:2*m/n:m-2*m/n;
	
	switch (dim)
		case 1
			x = scale;
			x = 1-(x).^2;
			mat = x>0;
			
			phi_m = zeros(1,n);
			phi_m(mat) = exp(-1./x(mat));
			phi_m = (c*m).*phi_m;
		case 2
			[x,y] = meshgrid(scale,scale);
			xy = 1-x.^2-y.^2;
			mat = xy>0;
			phi_m = zeros(n,n);
			phi_m(mat) = (c*m^2).*exp(-1./xy(mat));
		case 3
			[x,y,z] = meshgrid(scale,scale,scale);
			xyz = 1-x.^2-y.^2-z.^2;
			mat = xyz>0;
			phi_m = zeros(n,n,n);
			phi_m(mat) = (c*m^3).*exp(-1./xyz(mat));
	end
	
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subroutine  : parse_inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function [dim, n, m] = parse_inputs(varargin)
		error(nargchk(2,3,nargin));
		for i=1:nargin
			if (~isnumeric(varargin{i}) | ~isreal(varargin{i}))
				error(['Invalid ' num2str(i) '-th input. Numeric input required.']);
			end
		end
		for i=1:2
			if (round(varargin{i}) ~= varargin{i} | varargin{i}<=0)
				error(['Invalid ' num2str(i) '-th input. Positive integer required.']);
			end
		end
		if ( nargin==3 & varargin{3}<=0)
			error(['Invalid 3-rd input. Positive real input required.']);
		end
		n = varargin{1};
		dim = varargin{2};
		m = 0.5;
		if (nargin==3) m = varargin{3};end
	end
end
