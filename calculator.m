function [ result ] = calculator( labeling )
%CALCULATOR Summary of this function goes here
%   Detailed explanation goes here

%Labeling laden
load LabelStruct

erg=0;
for i=1:size(labelingStruct,1)
    
    %Indexing
    index=find(labeling==i);
    
    %Anzahl der einzelnen Labels
    if isempty(index)
        count=0;
    else
        count=size(index,1);
    end
    
    erg=erg+count*labelingStruct{i,2};
end

%Euro
euro=floor(double(erg));
%Cent
cent=(erg-euro)*100;

result= [num2str(euro) ' Euro ' num2str(cent) ' Cent'];

end
