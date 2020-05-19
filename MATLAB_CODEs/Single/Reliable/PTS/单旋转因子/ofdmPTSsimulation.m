

clear all; clc; close all;

K = 128;                                                                    % SIZE OF FFT 
V = 4;                                                                       % NUMBER OF SELECTIONS
QPSK_Set  = [1 -1 j -j];
Phase_Set = [1 -1 j -j];

Choose = [1 1 1 1; 1 1 1 2; 1 1 2 1; 1 2 1 1; 2 1 1 1;...
          1 1 2 2; 1 2 1 2; 1 2 2 1; 2 2 1 1; 2 1 2 1; 2 1 1 2;...
          2 2 2 1; 2 2 1 2; 2 1 2 2; 1 2 2 2; 2 2 2 2];
Choose_Len = 16;      

MAX_SYMBOLS  = 1e5;
PAPR_Orignal = zeros(1,MAX_SYMBOLS);
PAPR_PTS     = zeros(1,MAX_SYMBOLS);
samplerate=1;
for nSymbol=1:MAX_SYMBOLS
    Index = randi([1,length(QPSK_Set)],1,K);
    X = QPSK_Set(Index(1,:));                                               % Orignal Frequency domain signal
   Xsam=UtraSample(X,samplerate);
    x = ifft(Xsam,K*samplerate,2);                                                        % Time domain signal
    Signal_Power = abs(x.^2);
    Peak_Power   = max(Signal_Power,[],2);
    Mean_Power   = mean(Signal_Power,2);
    PAPR_Orignal(nSymbol) = 10*log10(Peak_Power./Mean_Power);
    
    % PTS 
    A = zeros(V,K);
    for v=1:V
        A(v,v:V:K) = X(v:V:K);                                              %Devide the original signal
    end
    Asam=UtraSample(A,samplerate);
    a = ifft(Asam,K*samplerate,2);    
    
    min_value = 10;
    for n=1:Choose_Len
        temp_phase = Phase_Set(Choose(n,:)).';
        temp_max = max(abs(sum(a.*repmat(temp_phase,1,K))));
        if temp_max<min_value
            min_value = temp_max;
            Best_n = n;
        end
    end
    aa = sum(a.*repmat(Phase_Set(Choose(Best_n,:)).',1,K));
        
    Signal_Power = abs(aa.^2);
    Peak_Power   = max(Signal_Power,[],2);
    Mean_Power   = mean(Signal_Power,2);
    PAPR_PTS(nSymbol) = 10*log10(Peak_Power./Mean_Power);
    
end

[cdf1, PAPR1] = ecdf(PAPR_Orignal);
[cdf2, PAPR2] = ecdf(PAPR_PTS);

%--------------------------------------------------------------------------
semilogy(PAPR1,1-cdf1,'-b',PAPR2,1-cdf2,'-r')
legend('Orignal','PTS')
title('V=4')
xlabel('PAPR0 [dB]');
ylabel('CCDF (Pr[PAPR>PAPR0])');
grid on
