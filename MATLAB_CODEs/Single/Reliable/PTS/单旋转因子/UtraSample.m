function index1=UtraSample(X,N)
   [R,C]=size(X);
    index1=zeros(R,C);
    number=(C)*N;
    len=(C);
    index1(1:R,1:(len/2))=X(1:R,1:(len/2));
    index1(1:R,(number-len/2+1):number)=X(1:R,(len/2+1):len);


 end