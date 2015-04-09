function h = drawPose(p,varargin)
% draws a pose x, y, phi on the screen
if nargin < 2 || isstr(varargin{1})
    length = max([diff(xlim) diff(ylim)])*0.1;
else
    length = varargin{1};
    varargin = varargin(2:end);
end
rays = createRay(p(1:2,:)', p(3,:)');
rays(:,3:4) = bsxfun(@plus, rays(:,1:2), rays(:,3:4)*length);

% if nargout > 0
%     h = [drawEdge(rays, varargin{:}); drawPoint(p(1:2,:)', 'marker', 'o', varargin{:})];
% else
    h = drawEdge(rays, varargin{:}, 'marker', 'none');
    h = [h; drawPoint(p(1:2,:)', 'marker', 'o', varargin{:}, 'linestyle', 'none')];
% endk
