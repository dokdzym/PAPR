function z=Dht(X)   %�������任����
N=length(X);        %���ݹ������任����ɢ����Ҷ�任֮���ϵ�õ����㷽��
y=fft(X);
for m=0:N-1
    a(m+1)=real(y(m+1));
    b(m+1)=imag(y(m+1));
    z(m+1)=a(m+1)-b(m+1);
end