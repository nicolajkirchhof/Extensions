function txtmat = write_matrix(mat)
%% WRITE_MATRIX(m) writes out a matrix in matlab format

[m, n] = size(mat);
txtmat = ['[ ' sprintf([repmat('%g, ', 1, n-1), '%g ; '], mat') ' ]'];

return;
%%
tstmat = magic(5);
txtmat = write_matrix(tstmat);
refmat = eval(txtmat);
log_test(all(tstmat(:)==refmat(:)), 'Matrix matching');