%************************beginning of file*****************************
%nyquistimp_PS.m
%使用改进的Nyquist脉冲实现OFDM信号的PAPR抑制
function dout=nyquistimp_PS()
%改进的Nyquist脉冲整形方法能够显著改善OFDM信
%号的PAPR分布；该方法实现简单，和PTS和SLM相比
%不需迭代计算多个IFFT操作，不需传送边带信息，
%不会引起信号的畸变；通用性强，可以调整滚降
%系数以适应任何子载波数的通信系统。当然，
%Nyquist脉冲成形的方法由于扩展了频谱，一定程
% 度上降低了频谱利用率。

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