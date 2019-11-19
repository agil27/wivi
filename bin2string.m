function [ str ] = bin2string( binary )
%UNTITLED2 此处显示有关此函数的摘要
%   把二进制串转化为字符串
L = length(binary);
str = [];
binary = reshape(binary',[8,L/8]);
binary = binary';
for i=1:L/8
    s= 0;
    for j = 1:8
        s = s+2^(8-j)*binary(i,j);
    end
    str = [str,char(s)];
end
end


