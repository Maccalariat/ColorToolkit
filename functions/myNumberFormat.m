function str = myNumberFormat(num)
    %MYNUMBERFORMAT Summary of this function goes here
    %   Detailed explanation goes here
     % Convert the number to a string with 4 decimal places
    str = sprintf('%.4f', num);
    
    % Use a regular expression to insert commas as thousand separators
    str = regexprep(str, '(\d+)(\d{3})(\.|$)', '$1,$2$3');
end

