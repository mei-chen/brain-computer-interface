function [Result ReCell]=CSP_DifferentFrequencyBand(mTypeOne,mTypeTwo,TimeInterval,FreqBands)
Result=zeros(1,size(FreqBands,1));
ReCell={};
for i=1:size(FreqBands,1)
    [Allaccu,R]=CSP_ClassificationExtentTenFold(mTypeOne,mTypeTwo,TimeInterval,FreqBands(i,:));
    Result(i)=Allaccu(end);
    ReCell{i}=R;
    disp(Result);
end