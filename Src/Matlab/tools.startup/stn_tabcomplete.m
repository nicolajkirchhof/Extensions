% set(0, 'DefaultFigurePosition', get(0, 'FactoryFigurePosition'));
def = tabcomplete('stn');
%%
if isempty(def)
    tabcomplete('stn', 'file');
    exit
end