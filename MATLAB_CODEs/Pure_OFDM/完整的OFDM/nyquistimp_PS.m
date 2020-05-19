%************************beginning of file*****************************
%nyquistimp_PS.m
%ʹ�øĽ���Nyquist����ʵ��OFDM�źŵ�PAPR����
function dout=nyquistimp_PS()
%�Ľ���Nyquist�������η����ܹ���������OFDM��
%�ŵ�PAPR�ֲ����÷���ʵ�ּ򵥣���PTS��SLM���
%�������������IFFT���������贫�ͱߴ���Ϣ��
%���������źŵĻ��䣻ͨ����ǿ�����Ե�������
%ϵ������Ӧ�κ����ز�����ͨ��ϵͳ����Ȼ��
%Nyquist������εķ���������չ��Ƶ�ף�һ����
% ���Ͻ�����Ƶ�������ʡ�

%creat a matrix to shape the subcarries.
%the spectrum of the pulse is as follows:
%     if abs(f)<=Bw*(1-b)
%         spec=1;
%        else if (abs(f)>Bw*(1-b))&(abs(f)<=Bw) 
%             spec=exp(aa.*(Bw.*(1-b)-abs(f)));
%           else if (abs(f)>Bw)&(abs(f)<Bw*(1+b))   
%               spec=1-exp(aa.*(abs(f)-Bw.*(1+b)));
%              else if  abs(f)>=Bw*(1+b)
%                 spec=0;    
%              end
%           end
%         end
%     end 

N=106;
L=11;
b=0.22;

% N=84;
% L=22;
% b=0.5;

% N=98;
% L=15;
% b=0.3;

% N=116;
% L=6;
% b=0.1;

T=0.004;
Ts=T/N;
Bw=1/Ts;

begin=-Bw*(1+b)+Bw*(1+b)/128;
finish=Bw*(1+b)-Bw*(1+b)/128;
distance=Bw*(1+b)/64;
kk=0;
aa=log(2)/(b.*Bw);


for f=begin:distance:finish
    kk=kk+1;
    if abs(f)<=Bw*(1-b)
        spec=1;
       else if (abs(f)>Bw*(1-b))&(abs(f)<=Bw) 
            spec=exp(aa.*(Bw.*(1-b)-abs(f)));
          else if (abs(f)>Bw)&(abs(f)<Bw*(1+b))   
              spec=1-exp(aa.*(abs(f)-Bw.*(1+b)));
             else if  abs(f)>=Bw*(1+b)
                spec=0;    
             end
          end
        end
    end 
   C(kk)=spec;
end

for m=0:N-1
    for k=0:(N+2*L-1)
        p(m+1,k+1)=C(k+1)*exp(-i*2*pi.*m.*(k-L)./N);
    end
end

dout=p;
% ************************end of file***********************************