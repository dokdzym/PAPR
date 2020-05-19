
function [IX QX] = OFDM_Normalization(IX, QX, NormFactor)


IQX = IX + 1i.*QX;
IQX = IQX./mean(abs(IQX)).*NormFactor;

IX = real(IQX);
QX = imag(IQX);