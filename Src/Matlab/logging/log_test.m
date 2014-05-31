function log_test(result, description)

if result
    fprintf(1, 'TEST: %s\n\t SUCCESS\n', description);
else
    fprintf(1, 'TEST: %s\n\t FAILURE\n', description);
end