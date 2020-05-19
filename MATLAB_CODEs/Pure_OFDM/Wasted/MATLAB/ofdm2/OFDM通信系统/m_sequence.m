%************************beginning of file*****************************
%m_sequence.m
%��������λ�Ĵ�������m����

function [mseq]= m_sequence(fbconnection);

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% fbconnection   ������λ�Ĵ�����ϵ��
% mseq           ���ɵ�m����
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

n = length(fbconnection);
N = 2^n-1;
register = [zeros(1,n - 1) 1];%������λ�Ĵ����ĳ�ʼ״̬
mseq(1)= register(n);
for i = 2:N
    newregister(1)= mod(sum(fbconnection.*register),2);
    for j = 2:n,
        newregister(j)= register(j-1);
    end;
    register = newregister;
    mseq(i) = register(n);
end
% ************************end of file**********************************
