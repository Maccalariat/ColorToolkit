function formattedString = thousandSeparatorFormat(inputNumber)
    %THOUSANDSEPARATORFORMAT Summary of this function goes here
    %   Detailed explanation goes here
    formattedString =  fliplr(regexprep(fliplr(num2str(inputNumber)),'\d{3}(?=\d)', '$0,'))
end

