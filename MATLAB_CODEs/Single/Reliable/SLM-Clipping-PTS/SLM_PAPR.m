clear all; 
clc; 
close all;
K = 128;                                                                    % SIZE OF FFT 
N = 4;                                                                      % NUMBER OF SELECTIONS
QPSK_Set  = [1 -1 j -j];
Phase_Set = [1 -1];
MAX_SYMBOLS  = 1e5;
PAPR_Orignal = zeros(1,MAX_SYMBOLS);
PAPR_SLM     = zeros(1,MAX_SYMBOLS);
X     = zeros(N,K);
Index = zeros(N,K);
for nSymbol=1:MAX_SYMBOLS
    %Index(1,:)   = randint(1,K,length(QPSK_Set))+1;
    Index(1,:)   = randi([1,length(QPSK_Set)],1,K);
    %Index(2:N,:) = randint(N-1,K,length(Phase_Set))+1;
    Index(2:N,:) = randi([1,length(Phase_Set)],N-1,K);
    
    X(1,:) = QPSK_Set(Index(1,:));                                          % Orignal Frequency domain signal
    Phase_Rot = Phase_Set(Index(2:N,:));
    X(2:N,:) = repmat(X(1,:),N-1,1).*Phase_Rot;                             % Phase roated Frequency domain signal
    
    x = ifft(X,[],2);                                                       % Time domain signal
    Signal_Power = abs(x.^2);
    Peak_Power   = max(Signal_Power,[],2);
    Mean_Power   = mean(Signal_Power,2);
    
    PAPR_temp = 10*log10(Peak_Power./Mean_Power);
    PAPR_Orignal(nSymbol) = PAPR_temp(1);
    PAPR_SLM(nSymbol)     = min(PAPR_temp);
end
[cdf1, PAPR1] = ecdf(PAPR_Orignal);
[cdf2, PAPR2] = ecdf(PAPR_SLM);

semilogy(PAPR1,1-cdf1,'-b',PAPR2,1-cdf2,'-r')
legend('Orignal','SLM')
title('N=4')
xlabel('PAPR0 [dB]');
ylabel('CCDF (Pr[PAPR>PAPR0])');
grid on

