%************************beginning of file*****************************
%seq_train.m
%生成用于同步的训练符号
function dout=seq_train()
%第一帧产生短训练序列，第二帧产生长训练序列
%每个短训练符号由16个子载波组成，短训练序列
%是由伪随机序列经过数字调制后插0后，再经过
%IFFT之后得到的。具体过程如下：首先采用抽头
%系数为[1 0 0 1 ]的4级移位寄存器产生长度为
%15的伪随机序列之后末尾补0，经过QPSK调制之
%后的伪随机序列只在16的整数倍位置上出现，其
%余的位置补0，产生长度为128的序列，此序列再
%补128个0经过数据搬移后做256点的IFFT变换就
%得到16个以16为循环的训练序列，经过加循环前
%后缀就会产生20个相同的短训练序列。长训练序
%列的产生同短训练序列。

global seq_num  

if seq_num==1
   fbconnection=[1 0 0 1];
   QPSKdata_pn=[m_sequence(fbconnection),0];
   QPSKdata_pn=qpsk(QPSKdata_pn);
elseif seq_num==2
   fbconnection=[1 0 0 0 0 0 1];
   QPSKdata_pn=[m_sequence(fbconnection),0];
   QPSKdata_pn=qpsk(QPSKdata_pn);
end

countmod=0;
for k=1:128  
   if seq_num==1 
      if mod(k-1,16)==0                 %生成16位循环的短训练符号   
        countmod=countmod+1;
        trainsp_temp(k)=QPSKdata_pn(countmod);
      else
        trainsp_temp(k)=0;
      end
   elseif seq_num==2 
      if mod(k-1,2)==0
        countmod=countmod+1;
        trainsp_temp(k)=QPSKdata_pn(countmod);
      else
        trainsp_temp(k)=0;
      end
   end
end

dout=trainsp_temp;
% ************************end of file***********************************