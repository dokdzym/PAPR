clear all;
K=128; %子载波数         
IF=2;                    % 插值系数
N=256;                                                                  
CR=1.4;                    %限幅率                                      
QPSK_Set  = [1 -1 j -j];     %qpsk编制
for n=1:1000         %计算没有加dht时的峰均比
    Index = randint(1,K,length(QPSK_Set))+1;
    X = QPSK_Set(Index(1,:));%对随机信号进行QPSK调制
    y = ifft(X,[],2); 
    Signal_Power0 = abs(y.^2);%计算信号的峰值功率
    Peak_Power0= max(Signal_Power0,[],2);%计算信号的平均功率
    Mean_Power0= mean(Signal_Power0,2);%计算PAPR
    PAPR_Orignal(n) =10*log10(Peak_Power0./Mean_Power0);
    XX = [X(1:K/2) zeros(1,N-K) X(K/2+1:K)];  %zeros(1,N-K)为插入的0数据
    y=ifft(XX,[],2);
    Signal_Power = abs(y.^2);
    Mean_Power= mean(Signal_Power,2);%计算信号的平均功率
% end
% for n=1:10000
%     Index = randint(1,K,length(QPSK_Set))+1;
%     X=QPSK_Set(Index(1,:));
%     XX = [X(1:K/2) zeros(1,N-K) X(K/2+1:K)];  %zeros(1,N-K)为插入的0数据
%     y=ifft(XX,[],2);
%     Signal_Power = abs(y.^2);
%     Mean_Power= mean(Signal_Power,2);%计算信号的平均功率
    y2=abs(y);
    y1=y;
    A=CR*sqrt(Mean_Power);
     % Clipping
    for h=1:N;
        if y2(h)>A;
        y1(h)=A*y(h)/y2(h);
        end
    end
     % Filtering         限幅后进行滤波
     XX = fft(y1,[],2);
     XX(K/2+(1:N-K))=zeros(1,N-K);  %人为的将带外噪声置零，滤波的目的              
     x = ifft(XX,[],2); 
     % PAPR Compute
     Signal_Power2 = abs(x.^2);
     Peak_Power2   = max(Signal_Power2,[],2);
     Mean_Power2   = mean(Signal_Power2,2);
     PAPR_Clipping(n) = 10*log10(Peak_Power2./Mean_Power2);
end
[cdf0, PAPR0] = ecdf(PAPR_Orignal);
[cdf1, PAPR1] = ecdf(PAPR_Clipping);
figure(1);
semilogy(PAPR0,1-cdf0,'-b',PAPR1,1-cdf1,'-r');
legend('Orignal','Clipping');
xlabel('PAPR0 [dB]');
ylabel('CCDF (Pr[PAPR>PAPR0])');
xlim([0 13]);
grid on;
