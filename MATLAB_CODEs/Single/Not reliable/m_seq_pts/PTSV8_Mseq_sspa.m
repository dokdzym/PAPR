%********����m����PTS�㷨ģ��************
%===================================���˼�M-sequence PTSģ��,V=8 =================**********
V=8;                                 %ÿ�����ŷ�8·
BaseDataV8=zeros(NumCarr,V,Numsymb); %Numsymb������ÿ������256�����ز���ÿ�����ŷ�V·
for n=1:Numsymb
    for m=1:V
       BaseDataV8(((m-1)*NumCarr/V+1):(m*NumCarr/V),m,n)=Data(((m-1)*NumCarr/V+1):(m*NumCarr/V),n);
   end;
end;   
BaseDataIfftV8=BaseDataV8;           % PTS�� V ·�źž���IFFT����СΪ��(NumCarr,V,Numsymb)

B=[1,-1] ;                           % bvȡ����ֵ
Bkinds=V-1;                          % V��1��m����
BData=[1 1 -1 -1 -1 1 -1 1;1 1 1 -1 -1 -1 1 -1;1 -1 1 1 -1 -1 -1 1;1 1 -1 1 1 -1 -1 -1;
       1 -1 1 -1 1 1 -1 -1 ;1 -1 -1 1 -1 1 1 -1;1 -1 -1 -1 1 -1 1 1]';                    % ��ת���ӵ�ȡֵ

BaseDMuxBV8=zeros(NumCarr,Bkinds);
SigBDataNum=zeros(1,Numsymb);       % ÿ����������ѡ����BData�����
ParNorm=zeros(2,Bkinds);            % 1�����ŵ�7��PAR��ֵ��2�����������Ӧ��BData����ţ�1������
Mean=zeros(1,Bkinds);               % һ�����Ŷ�Ӧ�ĸ���bv��Ȩ֮���ifft�任��PAR��ֵ
Max=zeros(1,Bkinds);                % һ�����Ŷ�Ӧ�ĸ���bv��Ȩ֮���ifft�任��PAR���ֵ
PTSSignal=zeros(NumCarr,Numsymb);   % ����ѡ���PTS����
SigParNorm=zeros(1,Numsymb);        % ����ѡ���PTS���ŵ�PARֵ
for n=1:Numsymb     
    for k=1:Bkinds
        for m=1:NumCarr
            BaseDMuxBV8(m,k)=BaseDataIfftV8(m,1,n)*BData(1,k)+BaseDataIfftV8(m,2,n)*BData(2,k)+BaseDataIfftV8(m,3,n)*BData(3,k)+BaseDataIfftV8(m,4,n)*BData(4,k)+BaseDataIfftV8(m,5,n)*BData(5,k)+BaseDataIfftV8(m,6,n)*BData(6,k)+BaseDataIfftV8(m,7,n)*BData(7,k)+BaseDataIfftV8(m,8,n)*BData(8,k);    
        end;
        BaseDMuxBV8(:,k)=ifft(BaseDMuxBV8(:,k));        %��IFFT֮ǰ��Ȩ��Ҫ��IFFT֮�����paprֵ����bv��ѡ��bvδ�����Ա任��
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
    for mm=2:Bkinds                          % һ�����ŵ�Bkinds�ּ�Ȩ��ѡ��PAPR��С��һ��
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
% ======================�ն�mSeqence-PTS������===============
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
  
