clear all;
K=128; %���ز���         
IF=2;                    % ��ֵϵ��
N=256;                                                                  
CR=1.4;                    %�޷���                                      
QPSK_Set  = [1 -1 j -j];     %qpsk����
for n=1:10000         
    Index = randi([1,length(QPSK_Set)],1,K);
    X = QPSK_Set(Index(1,:));%������źŽ���QPSK����
    
    %����PAPR_Orignal
    y = ifft(X,[],2); 
    Signal_Power0 = abs(y.^2);%�����źŵķ�ֵ����
    Peak_Power0= max(Signal_Power0,[],2);%�����źŵ�ƽ������
    Mean_Power0= mean(Signal_Power0,2);%����PAPR
    PAPR_Orignal(n) =10*log10(Peak_Power0./Mean_Power0);
    
    
    %����PAPR_Clipping
    XX = [X(1:K/2) zeros(1,256-K) X(K/2+1:K)];  %zeros(1,N-K)Ϊ�����0����
    y=ifft(XX,[],2);
    Signal_Power = abs(y.^2);
    Mean_Power= mean(Signal_Power,2);%�����źŵ�ƽ������
    y2=abs(y);
    y1=y;
    A=CR*sqrt(Mean_Power);
     % Clipping
    for h=1:256;
        if y2(h)>A;
        y1(h)=A*y(h)/y2(h);
        end
    end
     % Filtering         �޷�������˲�
     XX = fft(y1,[],2);
     XX(K/2+(1:256-K))=zeros(1,256-K);  %��Ϊ�Ľ������������㣬�˲���Ŀ��              
     x = ifft(XX,[],2); 
     % PAPR Compute
     Signal_Power2 = abs(x.^2);
     Peak_Power2   = max(Signal_Power2,[],2);
     Mean_Power2   = mean(Signal_Power2,2);
     PAPR_Clipping(n) = 10*log10(Peak_Power2./Mean_Power2);
 
     
     %����PAPR_DHT
     z=Dht(X); %�Բ����ź���DHT�任
    y = ifft(z,[],2); 
    Signal_Power1 = abs(y.^2); %�����źŵķ�ֵ����
    Peak_Power1= max(Signal_Power1,[],2);%�����źŵ�ƽ������
    Mean_Power1= mean(Signal_Power1,2);%����PAPR
    PAPR_DHT(n) =10*log10(Peak_Power1./Mean_Power1);
    
    
    X1=Dht(X); %�Բ����ź���DHT�任
    y=ifft(X1,[],2);
    Signal_Power= abs(y.^2);
    Mean_Power= mean(Signal_Power,2);%�����źŵ�ƽ������
    y2=abs(y);
    y1=y;
    A=CR*sqrt(Mean_Power);
    % Clipping
    for h=1:128;
        if y2(h)>A;
            y1(h)=A*y(h)/y2(h);
         end
    end
    Signal_Power3 = abs(y1.^2);
    Peak_Power3   = max(Signal_Power3,[],2);
    Mean_Power3   = mean(Signal_Power3,2);
    PAPR_DhtClipping(n) = 10*log10(Peak_Power3./Mean_Power3);
end
[cdf0, PAPR0] = ecdf(PAPR_Orignal);
[cdf1, PAPR1] = ecdf(PAPR_Clipping);
[cdf2, PAPR2] = ecdf(PAPR_DHT);
[cdf3, PAPR3] = ecdf(PAPR_DhtClipping);
figure(1);
semilogy(PAPR0,1-cdf0,'-b+',PAPR1,1-cdf1,'-r*',PAPR2,1-cdf2,'-gs',PAPR3,1-cdf3,'-mo');
legend('Orignal','Clipping','DHT','DhtClipping');
xlabel('PAPR0 [dB]');
ylabel('CCDF (Pr[PAPR>PAPR0])');
xlim([0 13]);
grid on;
