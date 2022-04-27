
		function make_folder(fdir)
			if isempty(fdir)
				return;
			end
			arch = computer('arch');
			if strcmp(arch, 'win32') | strcmp(arch, 'win64')
        pos=strfind(fdir, '\');
      else
        pos=strfind(fdir, '/');
      end
      
			for k=1:numel(pos)
				a = fdir(1:pos(k)-1);
				if ~isempty(a)
					b=exist(a);
					if b==0
						mkdir(a);
					else
						if b~=7
							msg=['The name "' a '" exist, but not a folder.\n' ]
							error(msg);
						end
					end
				end
			end
				
			a = fdir;
			b=exist(a);
			if b==0
				mkdir(a);
			else
				if b~=7
					msg=['The name "' a '" exist, but not a folder.' ]
					error(msg);
				end
			end
			return;
		end
