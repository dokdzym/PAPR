clear all;
K=128; %���ز���         
IF=2;                    % ��ֵϵ��
N=256;                                                                  
CR=1.4;                    %�޷���                                      
QPSK_Set  = [1 -1 j -j];     %qpsk����
for n=1:1000         %����û�м�dhtʱ�ķ����
    Index = randint(1,K,length(QPSK_Set))+1;
    X = QPSK_Set(Index(1,:));%������źŽ���QPSK����
    y = ifft(X,[],2); 
    Signal_Power0 = abs(y.^2);%�����źŵķ�ֵ����
    Peak_Power0= max(Signal_Power0,[],2);%�����źŵ�ƽ������
    Mean_Power0= mean(Signal_Power0,2);%����PAPR
    PAPR_Orignal(n) =10*log10(Peak_Power0./Mean_Power0);
    XX = [X(1:K/2) zeros(1,N-K) X(K/2+1:K)];  %zeros(1,N-K)Ϊ�����0����
    y=ifft(XX,[],2);
    Signal_Power = abs(y.^2);
    Mean_Power= mean(Signal_Power,2);%�����źŵ�ƽ������
% end
% for n=1:10000
%     Index = randint(1,K,length(QPSK_Set))+1;
%     X=QPSK_Set(Index(1,:));
%     XX = [X(1:K/2) zeros(1,N-K) X(K/2+1:K)];  %zeros(1,N-K)Ϊ�����0����
%     y=ifft(XX,[],2);
%     Signal_Power = abs(y.^2);
%     Mean_Power= mean(Signal_Power,2);%�����źŵ�ƽ������
    y2=abs(y);
    y1=y;
    A=CR*sqrt(Mean_Power);
     % Clipping
    for h=1:N;
        if y2(h)>A;
        y1(h)=A*y(h)/y2(h);
        end
    end
     % Filtering         �޷�������˲�
     XX = fft(y1,[],2);
     XX(K/2+(1:N-K))=zeros(1,N-K);  %��Ϊ�Ľ������������㣬�˲���Ŀ��              
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
