function log_test(result, description)
%% LOG_TEST(result, description) produces a standard log output for a test with 
%   description 

if result
    fprintf(1, 'TEST: %s\n\t SUCCESS\n', description);
else
    fprintf(1, 'TEST: %s\n\t FAILURE\n', description);
end