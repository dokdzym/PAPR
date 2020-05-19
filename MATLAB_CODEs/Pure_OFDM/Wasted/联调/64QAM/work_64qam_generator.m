%QAM16generator_dsp_system
%%��������16qam���� QAM16UniformGenerator%opti����Ϊp
%�˿ڳ�ʼ��
OutputPort1=InputPort1;
OutputPort2=InputPort1;
OutputPort3=InputPort1;

k=1024; %512
p=6*k;%p������6144
m=2;
M=16;%Mqam
bitsequence=[];
bitsequence=randi(m,1,p)-1;%����һ��p���������������01 
bitsequence1=bitsequence(1,1:3*k);
bitsequence2=bitsequence(1,3*k+1:6*k);%��Ϊ��·������ת��
reshaped_bitsequence1=reshape(bitsequence1,3,k);%i· 
reshaped_bitsequence2=reshape(bitsequence2,3,k);%q·
new64arraysequence1=zeros(1,k);
for ii=1:k%��I·����2ת�˽���
    new64arraysequence1(1,ii)=2^2*reshaped_bitsequence1(1,ii)+2^1*reshaped_bitsequence1(2,ii)+2^0*reshaped_bitsequence1(3,ii);%��һ����λ���ڶ��д�λ
end
new64arraysequence2=zeros(1,k);
for ii=1:k%��Q·����2ת�Ľ���
     new64arraysequence2(1,ii)=2^2*reshaped_bitsequence2(1,ii)+2^1*reshaped_bitsequence2(2,ii)+2^0*reshaped_bitsequence2(3,ii);
end

real_64_I_QAM=new64arraysequence1-3.5;%-3.5,-2.5,-1.5-0.5,
imag_64_Q_QAM=new64arraysequence2-3.5;

save('C:\Users\zym\Desktop\����\�о�������\PAPR\����\64QAM\work_64_I_Generator.txt','real_64_I_QAM','-ascii');
save('C:\Users\zym\Desktop\����\�о�������\PAPR\����\64QAM\work_64_Q_Generator.txt','imag_64_Q_QAM','-ascii');
%��iqֵ���
OutputPort1.Sequence=real_64_I_QAM;
OutputPort2.Sequence=imag_64_Q_QAM;
OutputPort3.Sequence=bitsequence;%��ʼ����