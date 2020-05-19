%********给出m序列PTS算法模块************
%===================================发端加M-sequence PTS模块,V=8 =================**********
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
        BaseDMuxBV8(:,k)=ifft(BaseDMuxBV8(:,k));        %在IFFT之前加权，要在IFFT之后计算papr值进行bv赛选（bv未经线性变换）
        for m=1:NumCarr
            BaseDMuxBV8(m,k)=(norm(BaseDMuxBV8(m,k)))^2;
        end;
        Mean(k)=mean(BaseDMuxBV8(:,k));
        Max(k)=BaseDMuxBV8(1,k);
        for l=2:NumCarr
            if BaseDMuxBV8(l,k)>Max(k)
                Max(k)=BaseDMuxBV8(l,k);
            end;
        end;
       
        ParNorm(1,k)=k;
        ParNorm(2,k)=Max(k)/Mean(k);
    end;
    MMin=ParNorm(2,1);
    SigBDataNum(n)=ParNorm(1,1);
    for mm=2:Bkinds                          % 一个符号的Bkinds种加权种选择PAPR最小的一组
        if ParNorm(2,mm)< MMin
            MMin=ParNorm(2,mm);
            SigBDataNum(n)=ParNorm(1,mm);
        end;
    end;
    for m=1:NumCarr
        PTSSignal(m,n)=BaseDataIfftV8(m,1,n)*BData(1,SigBDataNum(n))+BaseDataIfftV8(m,2,n)*BData(2,SigBDataNum(n))+BaseDataIfftV8(m,3,n)*BData(3,SigBDataNum(n))+BaseDataIfftV8(m,4,n)*BData(4,SigBDataNum(n))+BaseDataIfftV8(m,5,n)*BData(5,SigBDataNum(n))+BaseDataIfftV8(m,6,n)*BData(6,SigBDataNum(n))+BaseDataIfftV8(m,7,n)*BData(7,SigBDataNum(n))+BaseDataIfftV8(m,8,n)*BData(8,SigBDataNum(n));
    end;
   SigParNorm(n)=MMin; 
end;        
    
BaseSignal = ifft(PTSSignal);     % Generating baseband signal using IFFT 

%=======================
%=======================
%=======================
% ======================收端mSeqence-PTS解扰码===============
  for n=1:Numsymb
      for i=1:Bkinds 
          if  SigBDataNum(n)==i
              for m=1:V
                  symbwaves(((m-1)*NumCarr/V+1):(m*NumCarr/V),n)=symbwaves(((m-1)*NumCarr/V+1):(m*NumCarr/V),n)/BData(m,i);         
              end;
              break;
          end;
     end;
  end;
              
  RxSpectrums = symbwaves;	  % Find the spectrum of the symbols    
  
