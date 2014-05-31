function types = get_package_functions(fullpath)

types = [];
[path, base, ext] = fileparts(fullpath);
exts = dir([path filesep '*.m']);
for ide = 1:numel(exts)
    if strcmp(exts(ide).name, [base '.m'])
        continue
    end
    [fpath, fbase, fext] = fileparts(exts(ide).name);
    types.(fbase) = fbase;
end

types.compare = @(type1, type2) strcmp(type1, type2);