function z=Dht(X)   %哈特莱变换函数
N=length(X);        %依据哈特莱变换与离散傅里叶变换之间关系得到计算方法
y=fft(X);
for m=0:N-1
    a(m+1)=real(y(m+1));
    b(m+1)=imag(y(m+1));
    z(m+1)=a(m+1)-b(m+1);
end