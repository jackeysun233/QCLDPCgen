% 指定范围
lower_limit = 60; % 最小素数
upper_limit = 100; % 最大素数

% 初始化一个空数组来存储素数
prime_numbers = [];

% 循环遍历指定范围内的每个数字
for num = lower_limit:upper_limit
    % 检查当前数字是否为素数
    is_prime = true;
    for divisor = 2:sqrt(num)
        if rem(num, divisor) == 0
            is_prime = false;
            break;
        end
    end
    
    % 如果是素数，将其添加到列表中
    if is_prime
        prime_numbers = [prime_numbers, num];
    end
end

% 打印素数列表
disp(prime_numbers);
