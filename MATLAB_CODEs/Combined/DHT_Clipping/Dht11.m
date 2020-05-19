clear all;
N=128;
QPSK_Set  = [1 -1 j -j];  %QPSK����
%BPSK_Set = [1 -1];
for n=1:10000         %����û�м�dhtʱ�ķ����
    Index = randint(1,N,length(QPSK_Set))+1;
    X = QPSK_Set(Index(1,:));%������źŽ���QPSK����
    y = ifft(X,[],2); 
    Signal_Power0 = abs(y.^2);%�����źŵķ�ֵ����
    Peak_Power0= max(Signal_Power0,[],2);%�����źŵ�ƽ������
    Mean_Power0= mean(Signal_Power0,2);%����PAPR
    PAPR_Orignal(n) =10*log10(Peak_Power0./Mean_Power0);
%     end
% for n=1:10000%�����dht�ǵķ����
%     Index = randint(1,N,length(QPSK_Set))+1;
%     X = QPSK_Set(Index(1,:));%������źŽ���QPSK����
    z=Dht(X); %�Բ����ź���DHT�任
    y = ifft(z,[],2); 
    Signal_Power1 = abs(y.^2); %�����źŵķ�ֵ����
    Peak_Power1= max(Signal_Power1,[],2);%�����źŵ�ƽ������
    Mean_Power1= mean(Signal_Power1,2);%����PAPR
    PAPR_DHT(n) =10*log10(Peak_Power1./Mean_Power1);
    end
[cdf0, PAPR0] = ecdf(PAPR_Orignal);
[cdf1, PAPR1] = ecdf(PAPR_DHT);
figure(2);
semilogy(PAPR0,1-cdf0,'-b',PAPR1,1-cdf1,'-r');
legend('Orignal','dht');
xlabel('PAPR0 [dB]');
ylabel('CCDF (Pr[PAPR>PAPR0])');
xlim([0 13]);
grid on;