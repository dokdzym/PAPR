function zhi=J1(para)
x=para(1);
  % x is a Vector with xi between [-5.12, 5.12]
    % min is at (0, 0, ..., 0)
    % Generalized Rastrigin¡¯s Function
   %x=-10:0.001:10;
    n = size(x, 2);
    output=0;
    for i = 1:n
        output=output+x(i)^2;
    end
zhi=output;

