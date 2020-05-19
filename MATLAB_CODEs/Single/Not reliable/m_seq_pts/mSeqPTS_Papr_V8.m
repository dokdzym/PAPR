%*************给出m序列PTS模块******************8

%===================================发端加m序列PTS,V=8=================**********
%==========================================================================
NumCarr = 4;
Numsymb = 1024;
V=8;                                 %每个符号分8路
BaseDataV8=zeros(NumCarr,V,Numsymb); %Numsymb个符号每个符号256个子载波，每个符号分V路
for n=1:Numsymb
    for m=1:V
       BaseDataV8(((m-1)*NumCarr/V+1):(m*NumCarr/V),m,n)=Data(((m-1)*NumCarr/V+1):(m*NumCarr/V),n);
   end;
end;   
BaseDataIfftV8=BaseDataV8;           % PTS的 V 路信号经过IFFT，大小为：(NumCarr,V,Numsymb)

B=[1,-1] ;                           % bv取两种值
Bkinds=V-1;                          % V－1个m序列
BData=[1 1 -1 -1 -1 1 -1 1;1 1 1 -1 -1 -1 1 -1;1 -1 1 1 -1 -1 -1 1;1 1 -1 1 1 -1 -1 -1;
       1 -1 1 -1 1 1 -1 -1 ;1 -1 -1 1 -1 1 1 -1;1 -1 -1 -1 1 -1 1 1]';                    % 旋转因子的取值

BaseDMuxBV8=zeros(NumCarr,Bkinds);
SigBDataNum=zeros(1,Numsymb);       % 每个符号最终选定的BData的组号
ParNorm=zeros(2,Bkinds);            % 1个符号的7种PAR的值（2，：）及其对应的BData的组号（1，：）
Mean=zeros(1,Bkinds);               % 一个符号对应的各组bv加权之后的ifft变换的PAR均值
Max=zeros(1,Bkinds);                % 一个符号对应的各组bv加权之后的ifft变换的PAR最大值
PTSSignal=zeros(NumCarr,Numsymb);   % 最终选择的PTS符号
SigParNorm=zeros(1,Numsymb);        % 最终选择的PTS符号的PAR值
for n=1:Numsymb     
    for k=1:Bkinds
        for m=1:NumCarr
            BaseDMuxBV8(m,k)=BaseDataIfftV8(m,1,n)*BData(1,k)+BaseDataIfftV8(m,2,n)*BData(2,k)+BaseDataIfftV8(m,3,n)*BData(3,k)+BaseDataIfftV8(m,4,n)*BData(4,k)+BaseDataIfftV8(m,5,n)*BData(5,k)+BaseDataIfftV8(m,6,n)*BData(6,k)+BaseDataIfftV8(m,7,n)*BData(7,k)+BaseDataIfftV8(m,8,n)*BData(8,k);    
        end;
        BaseDMuxBV8(:,k)=ifft(BaseDMuxBV8(:,k));        %在IFFT之前加权，要在IFFT之后计算papr值进行bv赛选，（bv未经线性变换）
        for m=1:NumCarr
            BaseDMuxBV8(m,k)=(norm(BaseDMuxBV8(m,k)))^2;
        end;
        Mean(k)=mean(BaseDMuxBV8(:,k));
        Max(k)=max(BaseDMuxBV8(:,k));   
    end;
    ParNorm(2,:)=Max./Mean;
    MMin=min(ParNorm(2,:));           % 一个符号的Bkinds种加权种选择PAPR最小的一组
   
   SigParNorm(n)=MMin; 
end;        
SigParNorm=10*log10(SigParNorm);