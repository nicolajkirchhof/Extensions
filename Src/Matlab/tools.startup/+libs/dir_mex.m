function path = dir_custom()
    path = [fileparts(mfilename('fullpath')) filesep '..' filesep '..' filesep '..' filesep 'mex']
end
