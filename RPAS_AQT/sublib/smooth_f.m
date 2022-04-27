function g = smooth(varargin)

% SMOOTH smooths given function to some degree depending the input
% parameters m.
%
%	g = smooth(f, m) smooths the given function f to function g
%	by convoluting function f with a mollifier, \phi_m.
%
%	Output:
%		g:		the smoothed function.
%
%	Input:
%		f:		the original function.
%		m:		parameter determining the mollifier \phi_m.
%				Theoretically, the greater the m,
%				the closer of f and g. If m is too big, g == f numerically.
%				m is default set to 8
%
	[f, dim, n, m] =  parse_inputs(varargin{:});
	
	mm_sz=size(f);
	% switch data so that it starts at x=0
	f=ifftshift(f);
	
	phi = mollifier(n,dim,m);

	switch (dim)
		case 1
			f = reshape(f,1,n);
			F = fft(fftshift(f));
			G = fft(fftshift(phi));
			g = (2/n).*real(ifftshift(ifft(F.*G)));
		case 2
			f = reshape(f,n,n);
			F = fft2(fftshift(f));
			G = fft2(fftshift(phi));
			g = (2/n)^2.*real(ifftshift(ifft2(F.*G)));
		case 3
			f = reshape(f,n,n,n);
			F = fftn(fftshift(f));
			G = fftn(fftshift(phi));
			g = (2/n)^3.*real(ifftshift(ifftn(F.*G)));
	end

	
	% switch back data
	f=fftshift(f);
	
	g=fftshift(g);
	g=reshape(g,mm_sz);
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subroutine  : parse_inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	function [f, dim, n, m] = parse_inputs(varargin)
		error(nargchk(1,2,nargin));
		f = varargin{1};
		if (~isnumeric(f)|~isreal(f))
				error(['Invalid input: f.']);
		end

		% determine the dimension and grid size
		dd = size(f);
		size(dd);
		switch (prod(size(dd)))
			case 1
				dim = 1;
				n = prod(dd);
			case 2
				if (min(dd)==1)
					dim = 1;
					n = prod(dd);
				else
					if (dd(1)~=dd(2))
						error('This procedure can only smooth functions of equal grids in any directions.');
					end
					dim = 2;
					n = dd(1);
				end
			case 3
				if (min(dd)==1)
					dd = [max(dd) prod(dd)/max(dd)];
					if (min(dd)==1)
						dim = 1;
						n = prod(dd);
					else
						if (dd(1)~=dd(2))
							error('This procedure can only smooth functions of equal grids in any directions.');
						end
						dim = 2;
						n = dd(1);
					end
				else
					if (dd(1)~=dd(2) | dd(1)~=dd(3))
						error('This procedure can only smooth functions of equal grids in any directions.');
					end
					dim = 3;
					n = dd(1);
				end
		end

	%	parameter m

		m = 8;
		if (nargin==2)	m=varargin{2}; end;
		if (~isnumeric(m)|~isreal(m)|prod(size(m))>1|m<=0.0)
			error(['Invalid input: m. A real positive scalar required. m=' num2str(m)]);
		end
	end
end
