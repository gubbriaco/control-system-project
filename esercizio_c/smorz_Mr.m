function delta = smorz_Mr( Mr )
% Calcola lo smorzamento corrispondente ad un dato picco di risonanza (in
% dB)

delta = sqrt(0.5-0.5*sqrt(1-1/(db2mag(Mr)^2)));

end


