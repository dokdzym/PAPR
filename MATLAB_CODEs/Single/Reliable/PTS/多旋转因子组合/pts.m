clc;
clear all;
close all;

K = 128;                                      % 载波数目
QPSK_Set = [1 -1 j -j];                       % QPSK星座符号
Phase_Set1 = [1 -1];                          % 加权因子集（Weighting factor set）1
Phase_Set2 = [1 -1 j -j];                     % 加权因子集（Weighting factor set）2
V = 4;                                        % 子块数目

Choose1 = [1 1 1 1; 1 1 1 2; 1 1 2 1; 1 2 1 1; 2 1 1 1;...
1 1 2 2; 1 2 1 2; 1 2 2 1; 2 2 1 1; 2 1 2 1; 2 1 1 2;...
2 2 2 1; 2 2 1 2; 2 1 2 2; 1 2 2 2; 2 2 2 2];
% 生成加权因子集1的所有可能组合矩阵

Choose_Len1 = 16;               % 使用加权因子集 1 的组合或IFFT操作的总数 
for i=1:4                       % 生成加权因子集2的4个分支的所有可能组合

X(i,1:4^i) = [repmat(1,1,4^(i-1)),repmat(2,1,4^(i-1)),repmat(3,1,4^(i-1)),repmat(4,1,4^(i-1))];
Y = X(i,1:4^i);
X(i,1:256) = repmat(Y,1,256/length(Y));
end
X = X.';
Choose2 = fliplr(X);
Choose_Len2 = 256;               % 使用加权因子集 2 的组合或IFFT操作的总数

Max_Symbols = 1e3;                 %  OFDM符号数
PAPR_Orignal = zeros(1,Max_Symbols); PAPR_PTS    = zeros(1,Max_Symbols);

for nSymbol = 1:Max_Symbols 
%原先：Index = rand(1,K,length(QPSK_Set))+1;    % 产生随机QPSK星座图索引
    Index = randi([1,length(QPSK_Set)],1,K);
X = QPSK_Set(Index(1,:));                   % QPSK调制

x = ifft(X,[],2);        % 经过IFFT操作之后的时域信号
Signal_Power = abs(x.^2);
Peak_Power = max(Signal_Power,[],2); Mean_Power = mean(Signal_Power,2);
PAPR_Orignal(nSymbol) = 10*log10(Peak_Power./Mean_Power); % 原始OFDM信号的PAPR值
L = length(X);
A = zeros(V,K);

for k=1:V                        % 将频域X中的信号划分为v个非重叠子块
A(k,:)=[zeros(1,(k-1)*L/V),X((k-1)*L/V+1:k*L/V),zeros(1,(V-k)*L/V)];
end
a = ifft(A,[],2);

%W=2
min_value = 10;

for n=1:Choose_Len1                       % 寻优算法
    temp_phase = Phase_Set1(Choose1(n,:)).';
    temp_max(n) = max(abs(sum(a.*repmat(temp_phase,1,K))));% 表示累积过程

    if temp_max(n)<min_value 
        min_value = temp_max(n); 
        Best_n = n;
    end
end
aa = sum(a.*repmat(Phase_Set1(Choose1(Best_n,:)).',1,K));
Signal_Power = abs(aa.^2);
Peak_Power = max(Signal_Power,[],2);
Mean_Power = mean(Signal_Power,2);
PAPR_PTS2(nSymbol) = 10*log10(Peak_Power./Mean_Power);

% W=4
min_value = 10;
for n=1:Choose_Len2
    temp_phase = Phase_Set2(Choose2(n,:)).';
    temp_max(n) = max(abs(sum(a.*repmat(temp_phase,1,K))));
    
    if temp_max(n)<min_value 
        min_value = temp_max(n); 
        Best_n = n;
    end
 
end
aa = sum(a.*repmat(Phase_Set2(Choose2(Best_n,:)).',1,K)); 
Signal_Power = abs(aa.^2);
Peak_Power = max(Signal_Power,[],2);
Mean_Power = mean(Signal_Power,2);
PAPR_PTS4(nSymbol) = 10*log10(Peak_Power./Mean_Power);
end;


[cdf1, PAPR1] = ecdf(PAPR_Orignal); 
[cdf2, PAPR2] = ecdf(PAPR_PTS2); 
[cdf3, PAPR3] = ecdf(PAPR_PTS4);

semilogy(PAPR1,1-cdf1,'linewidth',2)
hold on;
semilogy(PAPR2,1-cdf2,'linewidth',2)
hold on;
semilogy(PAPR3,1-cdf3,'linewidth',2)
legend(' Orignal',' W=2',' W=4') 
xlabel('PAPR0 [dB]'); 
ylabel('CCDF (Pr[PAPR>PAPR0])'); 
axis([5 12 10e-4 1])
grid on


