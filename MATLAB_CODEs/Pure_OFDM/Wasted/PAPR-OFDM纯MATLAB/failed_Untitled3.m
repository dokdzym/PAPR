% SLM--PAPR Simulation
 
clear all; clc; close all;
 
K = 128;                                                                    % SIZE OF FFT 
N = 4;                                                                      % NUMBER OF SELECTIONS
QPSK_Set  = [1 -1 i -i];
Phase_Set = [1 -1];
 
MAX_SYMBOLS  = 1e4;
PAPR_Orignal = zeros(1,MAX_SYMBOLS);
PAPR_SLM     = zeros(3,MAX_SYMBOLS);
 
X     = zeros(N,K);
Index = zeros(N,K);
for nSymbol=1:MAX_SYMBOLS
    %Index(1,:)   = randi(1,K,length(QPSK_Set))+1;
    Index(2:N,:) = randi(N-1,K,length(Phase_Set))+1;
    
    X(1,:) = QPSK_Set(Index(1,:));                                          % Orignal Frequency domain signal
    Phase_Rot = Phase_Set(Index(2:N,:));
    X(2:N,:) = repmat(X(1,:),N-1,1).*Phase_Rot;                             % Phase roated Frequency domain signal
    
    x = ifft(X,[],2);                                                       % Time domain signal
    Signal_Power = abs(x.^2);
    Peak_Power   = max(Signal_Power,[],2);
    Mean_Power   = mean(Signal_Power,2);
    
    PAPR_temp = 10*log10(Peak_Power./Mean_Power);
    PAPR_Orignal(nSymbol) = PAPR_temp(1);
    PAPR_SLM(1,nSymbol)     = min(PAPR_temp(1:2));
    PAPR_SLM(2,nSymbol)     = min(PAPR_temp(1:4));
   
    
end
 
[cdf1, PAPR1] = ecdf(PAPR_Orignal);
[cdf2, PAPR2] = ecdf(PAPR_SLM(1,:));
[cdf3, PAPR3] = ecdf(PAPR_SLM(2,:));
 
 
%--------------------------------------------------------------------------
semilogy(PAPR1,1-cdf1,'-k',PAPR2,1-cdf2,'-r',PAPR3,1-cdf3,'-b')
legend('Orignal (N=1)','SLM (N=2)', 'SLM (N=4)')
xlabel('PAPR0 [dB]');
ylabel('CCDF (Pr[PAPR>PAPR0])');
grid on