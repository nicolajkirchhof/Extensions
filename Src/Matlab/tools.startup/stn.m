function stn(name)
if ispc
    userdir= getenv('ProgramFiles');
    sublime = [userdir '\Sublime Text 3\sublime_text.exe'];
else
    error(' ');
end
if nargin < 1
    system([sublime ' &']);
    return;
end


found = exist(name);
if found>0
    if any(found == [2, 7])
        system(['"' sublime '" --new-window ' name ' &']);
    end
    if found == 8
        file =  which(name);
        system(['"' sublime '" --new-window ' file ' &']);
    end
end