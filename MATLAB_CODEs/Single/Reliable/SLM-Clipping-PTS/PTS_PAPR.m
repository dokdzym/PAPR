
% PTS--PAPR Simulation
%
% Reference: S. H. M��ller and J. B. Huber, ��OFDM with Reduced
% Peak�Cto�CAverage Power Ratio by Optimum Combination
% of Partial Transmit Sequences,�� Elect. Lett., vol. 33,
% no. 5, Feb. 1997, pp. 368�C69.%
% 
% Author: Bin Jiang
% National Mobile Communication Research Laboratory
% Southeast University, 210096 Nanjing, China
% Email: bjiang@seu.edu.cn
clear all;
clc; 
close all;

K = 128;                                                                    % SIZE OF FFT 
V = 4;                                                                       % NUMBER OF SELECTIONS
QPSK_Set  = [1 -1 j -j];
Phase_Set = [1 -1];

Choose = [1 1 1 1; 1 1 1 2; 1 1 2 1; 1 2 1 1; 2 1 1 1;
          1 1 2 2; 1 2 1 2; 1 2 2 1; 2 2 1 1; 2 1 2 1; 2 1 1 2;
          2 2 2 1; 2 2 1 2; 2 1 2 2; 1 2 2 2; 2 2 2 2];
Choose_Len = 16;      

MAX_SYMBOLS  = 1e4;
PAPR_Orignal = zeros(1,MAX_SYMBOLS);
PAPR_PTS     = zeros(1,MAX_SYMBOLS);

for nSymbol=1:MAX_SYMBOLS
    %ԭ�ȱ�����룺Index = randint(1,K,length(QPSK_Set))+1;
    Index = randi([1,length(QPSK_Set)],1,K) ; 
    %Index= randperm(K);      
    X = QPSK_Set(Index(1,:));                                               % Orignal Frequency domain signal
    x = ifft(X,[],2);                                                       % Time domain signal
    Signal_Power = abs(x.^2);
    Peak_Power   = max(Signal_Power,[],2);
    Mean_Power   = mean(Signal_Power,2);
    PAPR_Orignal(nSymbol) = 10*log10(Peak_Power./Mean_Power);
    
    % PTS 
    A = zeros(V,K);
    for v=1:V
        A(v,v:V:K) = X(v:V:K);
    end
    a = ifft(A,[],2);
    
    %A = zeros(V,K);
    %for v=1:V
    %    A(v,Index(v:V:K)) = X(Index(v:V:K));
    %end
    %a = ifft(A,[],2);
    
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


%�������ͨ���Բ��ã������ο��������ĳ�����V=4���������������Ҫ�޸�Choose������ϵ�Ԫ��.
%���Եȼ����ѡȡ���ֵ���������
%���磺
%semilogy(PAPR1,1-cdf1,'-b'��
%�ɸ�Ϊ:
%semilogy(PAPR1(1:4:end), 1-cdf1(1:4:end), '-bo')
%�м�ļ�����Ը���ʵ�ʻ�ͼЧ����ȷ��
% PTS ���ڷָ�
%A = zeros(V,K);
%for v=1:V
%    A(v,v:V:K) = X(v:V:K);
%end
%a = ifft(A,[],2);
% ע����1�� ����Ĵ���û��Ҫ��K/V������

%����������ָ����������������:

%Index= randperm(K);
%A = zeros(V,K);
%for v=1:V
%    A(v,Index(v:V:K)) = X(Index(v:V:K));
%end
%a = ifft(A,[],2);
% ע��Index��1��K������û�������У���Index�Ŀ��Խ�������ָ����Ĵ����Բ��õȼ���ָ�
