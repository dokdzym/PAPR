%QAM16generator_dsp_system
%%产生均匀16qam序列 QAM16UniformGenerator%opti设置为p
%端口初始化
OutputPort1=InputPort1;
OutputPort2=InputPort1;
OutputPort3=InputPort1;

k=1024; %512
p=6*k;%p个序列6144
m=2;
M=16;%Mqam
bitsequence=[];
bitsequence=randi(m,1,p)-1;%产生一串p长度随机比特序列01 
bitsequence1=bitsequence(1,1:3*k);
bitsequence2=bitsequence(1,3*k+1:6*k);%分为两路，串并转换
reshaped_bitsequence1=reshape(bitsequence1,3,k);%i路 
reshaped_bitsequence2=reshape(bitsequence2,3,k);%q路
new64arraysequence1=zeros(1,k);
for ii=1:k%对I路进行2转八进制
    new64arraysequence1(1,ii)=2^2*reshaped_bitsequence1(1,ii)+2^1*reshaped_bitsequence1(2,ii)+2^0*reshaped_bitsequence1(3,ii);%第一行首位，第二行次位
end
new64arraysequence2=zeros(1,k);
for ii=1:k%对Q路进行2转四进制
     new64arraysequence2(1,ii)=2^2*reshaped_bitsequence2(1,ii)+2^1*reshaped_bitsequence2(2,ii)+2^0*reshaped_bitsequence2(3,ii);
end

real_64_I_QAM=new64arraysequence1-3.5;%-3.5,-2.5,-1.5-0.5,
imag_64_Q_QAM=new64arraysequence2-3.5;

save('C:\Users\zym\Desktop\组内\研究生毕设\PAPR\联调\64QAM\work_64_I_Generator.txt','real_64_I_QAM','-ascii');
save('C:\Users\zym\Desktop\组内\研究生毕设\PAPR\联调\64QAM\work_64_Q_Generator.txt','imag_64_Q_QAM','-ascii');
%将iq值输出
OutputPort1.Sequence=real_64_I_QAM;
OutputPort2.Sequence=imag_64_Q_QAM;
OutputPort3.Sequence=bitsequence;%初始代码