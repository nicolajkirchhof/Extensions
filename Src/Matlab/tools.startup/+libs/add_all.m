[path, base, ext] = fileparts(mfilename('fullpath'));
exts = dir([path filesep '*.m']);
for ide = 1:numel(exts)
    if strcmp(exts(ide).name, [base '.m'])
        continue
    end
    [fpath, fbase, fext] = fileparts(exts(ide).name);
    eval(['libs.' fbase]);
end

