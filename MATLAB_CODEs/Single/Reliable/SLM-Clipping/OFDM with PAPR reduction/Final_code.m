clc;
clear all;
close all;
n=0;
while n~=8
disp(' ');
disp('STUDY OF OFDM SIGNAL WITH PAPR REDUCTION');
disp('To view QPSK baseband signal, PRESS 1');
disp('To view OFDM power spectrum, PRESS 2');
disp('To view BER performance of OFDM system, PRESS 3');
disp('To view Frequency Spectrum of OFDM baseband signal, PRESS 4');
disp('To view PAPR reduction using Clipping+Filtering Technique, PRESS 5');
disp('To view PAPR reduction using SLM Technique, PRESS 6');
disp('To compare PAPR reduction using SLM Technique and Clipping+Filtering Technique, PRESS 7');
disp('To exit, PRESS 8');

n=input('ENTER your choice =');
if n==1
    A_qpsk();
elseif n==2
B_OFDM();
elseif n==3
    C_a_ber_ran();
elseif n==4
    D_Frequency_Spectrum();
elseif n==5
    E_papr_clipConv();    
elseif n==6
    F_papr_SLM();
elseif n==7
    G_papr_Combined();    
elseif n==8
    disp('Execution Completed');    
else
    disp('Sorry you entered an INVALID choice');
end;


end;