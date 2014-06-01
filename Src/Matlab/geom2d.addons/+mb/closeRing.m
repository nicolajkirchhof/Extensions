function [ring] = closeRing(ring)
%% CLOSERING(ring) ensures that a ring is closed

if ~all(ring(:,1) == ring(:,end))
    ring = [ring, ring(:,1)];
end

return;

%%  TEST if random ring is closed
ring = randi(100, 2, 5);
ringcl = mb.closeRing(ring);
log_test(all(ringcl(:,1)==ringcl(:,end)), 'check if ring is closed')


%% Test if closed ring is ok
ring = randi(100, 2, 3);
ringcl = [ring ring(:,1)];
ringcltst = mb.closeRing(ringcl);
log_test(all(all(ringcl==ringcltst)), 'check if closed ring is not changed')
