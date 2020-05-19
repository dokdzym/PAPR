
% Repeated Clipping and Filtering--PAPR Simulation
%
% Reference: J. Armstrong, New OFDM peak-to-average power reduction scheme.
% 
% Author: Bin Jiang
% National Mobile Communication Research Laboratory
% Southeast University, 210096 Nanjing, China
% Email: bjiang@seu.edu.cn

clear all; clc; close all;
K  = 128;                                                                   % SIZE OF OFDM Symbol
IF = 2;                                                                     % Interpolation factor (Oversampling factor)
N  = K*IF;                                                                  % SIZE OF FFT
CR = 4;                                                                     % Clipping ratio (linear 4 <==>log 6dB)
QPSK_Set  = [1 -1 j -j];
  
ITERATE_NUM = 4;
MAX_SYMBOLS  = 1e4;
PAPR_Orignal = zeros(1,MAX_SYMBOLS);
PAPR_RCF     = zeros(ITERATE_NUM,MAX_SYMBOLS);
for nSymbol=1:MAX_SYMBOLS
    Index = randi(1,K,length(QPSK_Set))+1;
    X = QPSK_Set(Index(1,:));                                               % Orignal Frequency domain signal
    XX = [X(1:K/2) zeros(1,N-K) X(K/2+1:K)];
    
    x = ifft(XX,[],2);                                                      % Time domain signal
    Signal_Power = abs(x.^2);
    Peak_Power   = max(Signal_Power,[],2);
    Mean_Power   = mean(Signal_Power,2);
    PAPR_Orignal(nSymbol) = 10*log10(Peak_Power./Mean_Power);
    
    for nIter=1:ITERATE_NUM
        % Clipping
        x_tmp = x(Signal_Power>CR*Mean_Power);
        x_tmp = sqrt(CR*Mean_Power)*x_tmp./abs(x_tmp);
        x(Signal_Power>CR*Mean_Power) = x_tmp;
        
        % Filtering
        XX = fft(x,[],2);
        XX(K/2+(1:N-K)) = zeros(1,N-K);
        x = ifft(XX,[],2); 
        
        % PAPR Compute
        Signal_Power = abs(x.^2);
        Peak_Power   = max(Signal_Power,[],2);
        Mean_Power   = mean(Signal_Power,2);
        PAPR_RCF(nIter,nSymbol) = 10*log10(Peak_Power./Mean_Power);
    end
end

[cdf0, PAPR0] = ecdf(PAPR_Orignal);
[cdf1, PAPR1] = ecdf(PAPR_RCF(1,:));
[cdf2, PAPR2] = ecdf(PAPR_RCF(2,:));
[cdf3, PAPR3] = ecdf(PAPR_RCF(3,:));
[cdf4, PAPR4] = ecdf(PAPR_RCF(4,:));

%--------------------------------------------------------------------------
semilogy(PAPR0,1-cdf0,'-b',PAPR1,1-cdf1,'-r',PAPR2,1-cdf2,'-g',PAPR3,1-cdf3,'-c',PAPR4,1-cdf4,'-m')
legend('Orignal','One clip and filter','Two clip and filter','Three clip and filter','Four clip and filter')
xlabel('PAPR0 [dB]');
ylabel('CCDF (Pr[PAPR>PAPR0])');
xlim([0 12])
grid on


%想问下我看了下一些文档CR的定义是CR = Amax/sqrt(Pin)，是限幅的最大幅度与均方根功率的比值
%所以是不是把程序中的
%        x_tmp = x(Signal_Power>CR*Mean_Power);
%        x_tmp = CR*Mean_Power*x_tmp./abs(x_tmp.^2);
%        x(Signal_Power>CR*Mean_Power) = x_tmp;
%改成 Ax=abs(x);
%        A=CR*sqrt(Mean_Power);
%        x_tmp = x(Ax>A);
%        x_tmp = x_tmp*A./abs(x_tmp);                                           
%        x(Ax>A) = x_tmp;
%更合理一些呢？