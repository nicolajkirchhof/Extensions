function write_log(str, varargin)
% write_log logs the given message to the console or a choosen file.
% str = the string or printf statement to log
% varargin = optional variables or options
%
% options can be applied by leaving str = [] and using one of the following
% options tags:
%   #on      = turns logging on [default]
%   #off     = turns logging off
%   #fileon  = writes log to file, name can be applied as next parameter
%   #fileoff = stops the file logging and closes file

persistent fid ident enabled fileenabled
if isempty(enabled)
    ident = [];
    enabled = true;
    fileenabled = false;
    fid = [1];
end

if isempty(str)
    if nargin > 1
        switch (varargin{1})
            case '#on'
                fprintf(1, '#logging is on\n');
                enabled = true;
            case '#off'
                fprintf(1, '#logging is off\n');
                enabled = false;
            case '#fileon'
                if nargin > 2 && ~isempty(varargin{2}) && isstr(varargin{2})
                    filename = varargin{2};
                else
                    filename = ['log_', datestr(now, 30) '.log'];
                end
                fid = fopen(filename, 'w');
                fileenabled = true;
                fprintf(1, '#logging to file is on\n');
            case '#fileoff'
                fclose(fid);
                fprintf(1, '#logging to file is off\n');
            otherwise
                fprintf(1, '#logging option %s not recognized \n', varargin{1});
        end
    end
    return;
end

% % change indention
% if strcmp(str(1), ' ')
%     str = str(2:end);
%     ident = [ident '\t'];
% elseif strcmp(str(end), ' ')
%     str = ['\t' str(1:end-1)];
%     ident = ident(1:end-2);
% end

if nargin == 1
    str = [str '\n'];
end
   
if fileenabled
    fprintf(fid, [ident str], varargin{:});
end
if enabled
    fprintf(1, [ident str], varargin{:});
end

return;
%% Testing start
write_log('logging...');
clear write_log
%% testing ident
write_log('logging...');
write_log(' starting ident');
write_log('log in ident');
write_log(' starting ident');
write_log('log in ident');
write_log('ending ident ');
write_log('log in ident');
write_log('ending ident ');
write_log('log in ident');
clear write_log
%% testing enable
write_log('logging...');
write_log(' starting ident');
write_log('ending ident ');
write_log([], '#off');
write_log('log in offmode');
write_log('log in offmode');
write_log([], '#on');
write_log('log in onmode');
write_log('log in onmode');
clear write_log
%% testing filemode
filename = 'test.log';
write_log('logging...');
write_log(' starting ident');
write_log('ending ident ');
write_log([], '#fileon', filename);
logstring = 'log in filemode';
write_log(logstring);
write_log([], '#fileoff');
fid = fopen(filename);
filestring = fgetl(fid);
fclose(fid);
if strcmp(filestring, logstring)
    fprintf(1, 'TEST: writing to file\n\t SUCCESS\n');
    delete(filename);
else
    fprintf(1, 'TEST: writing to file\n\t FAILURE\n');
end
clear write_log


