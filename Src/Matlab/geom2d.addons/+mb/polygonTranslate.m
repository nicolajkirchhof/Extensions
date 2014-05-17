function poly = polygonTranslate(poly, offset)
%polygonArea for boost polygon
if all(size(offset) ~= [2 1])
    if all(size(offset) == [1 2])
        offset = offset';
    else
        error('offset must be [x, y] or [x;y]');
    end
end
translate = @(r) ringTranslate(r, offset);
poly = mb.foreachRing(poly, translate);


function ring = ringTranslate(ring, offset)
    ring = bsxfun(@plus, ring, int64(offset));
    