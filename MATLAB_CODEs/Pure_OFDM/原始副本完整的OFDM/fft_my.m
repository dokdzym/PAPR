%************************beginning of file*****************************
%fft_my.m
%实现N点FFT运算
function  dout=fft_my(din)
%本程序对输入序列din实现DIT——FFT基2算法，点数取大于等于din长度的2的幂次

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% din           输入数据
% dout          输出数据
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

m=nextpow2(din) ;
N=2^m ;
if length(din)<N
    din=[din,zeros(1,N-length(din))];
end
nxd=bin2dec(fliplr(dec2bin([1:N]-1,m)))+1;
y=din(nxd);
for mm=1:m
Nmr=2^mm;
u=1;
WN=exp(-i*2*pi/Nmr);
    for j=1:Nmr/2 
        for k=j:Nmr:N
            kp=k+Nmr/2;
            t=y(kp)*u;
            y(kp)=y(k)-t;
            y(k)=y(k)+t;
        end
       u=u*WN;
    end
end
dout=y;
% ************************end of file**********************************