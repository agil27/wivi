function [ str ] = bin2string( binary )
%UNTITLED2 �˴���ʾ�йش˺�����ժҪ
%   �Ѷ����ƴ�ת��Ϊ�ַ���
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


