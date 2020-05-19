clc
clear all
tic
m=2;%ά��
n=50;%ө������
a=3;
b=-3;
jis=0;
L0=5;%ӫ���س�ֵ

beta=0.08;%��̬������ĸ�����
nt=5;% ���������ֵ
s=0.05;%����
%s=0.03;%����
gama=0.6;%ӫ���ظ�����
p=0.4;%ӫ������ʧ��
t=2;%������ֵ  
iter_max=200;%����������
R0=3;%��̬������Rd�ĳ�ֵ
Rs=5;%��֪��RS>=Rd
L=zeros(n,iter_max);
Rd=zeros(n);
P=zeros(n,n);

Nei=cell(n,iter_max);

%����������ӫ���ؼ���̬������
for i=1:n
    L(i,1)=L0;
    Rd(i)=R0;
end


%��iө�����tʱ�̵�λ�ó�ʼ��



for i=1:n  
   X(i,1:m)=(a-b)*rand(1,m)+b;  
   plot(X(i,1),X(i,2),'sk');
    hold on
end

while t<iter_max
%ӫ���صĸ���
for i=1:n
    L(i,t)=(1-p)*L(i,(t-1))+gama*J1(X(i,1:m));
end
    
%λ���ƶ�����
for i=1:n
    for j=1:n
    if (norm(X(j,1:m)-X(i,1:m))<Rd(i))&&(L(i,t)<L(j,t))
       Nei{i,t}=[j,Nei{i,t}];%��ȡ����Nei
    end
    end
end


tempsum=zeros(n);
for i=1:n
    for j=Nei{i,t}
       tempsum(i)=L(j,t)-L(i,t)+tempsum(i);
    end
end

%�ƶ����ʵļ���
for i=1:n
    for j=Nei{i,t}
        P(i,j)=(L(j,t)-L(i,t))/tempsum(i);
    end
end

for i=1:n
    if isempty(Nei{i,t})
        X(i,1:m)= X(i,1:m);
        Rd(i)=min(Rs,max(0,Rd(i)+beta*(nt-length(Nei{i,t})))); 
         plot(X(i,1),X(i,2),'*k');
       hold on
    else     
    for j=Nei{i,t}
       if  P(i,j)==max(P(i,:))&&P(i,j)~=0
           SeJ=j;%ѡ����õ��ƶ�����
          %λ�ø���
           X(i,1:m)= X(i,1:m)+s.*(X(SeJ,1:m)-X(i,1:m))/norm(X(SeJ,1:m)-X(i,1:m)); 
         %��̬���������
         Rd(i)=min(Rs,max(0,Rd(i)+beta*(nt-length(Nei{i,t})))); 
         
         plot(X(i,1),X(i,2),'*k');
     hold on
       end
    end
     P(i,:)=zeros(1,n);
    end
end
if t<=150
s=s-0.0003;
end
t=t+1

end
%ȡֵ
for i=1:n
    num=0;
    for j=i+1:n
      if norm(X(i,1:m)-X(j,1:m))<0.05
          num=num+1;
          if num<=1
             jis=jis+1; 
              if J1(X(i,1:m))<J1(X(j,1:m))
                 fuzhu(jis,1:m)=X(j,1:m);
                 
              else
                 fuzhu(jis,1:m)=X(i,1:m);
              end
              X(j,1:m)=[inf];
          else
              if J1(X(i,1:m))<J1(X(j,1:m))
                 fuzhu(jis,1:m)=X(j,1:m);
              end
              X(j,1:m)=[inf];
              
          end
      end
    end
end

fuzhu
%��ͼ
toc
for i=1:n
plot(X(i,1),X(i,2),'or');
hold on
end
grid on


