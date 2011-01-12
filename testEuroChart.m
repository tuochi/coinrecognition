addpath('tools/osu-svm');


chart='coin/eurochart.png';
img=imread(chart);
gray=rgb2gray(img);

%figure
i=1;
L=[];
S=[];
for l=1:3% Land 1 == Universell, 2== AT, ..
    for t=1:8 % Type, 1cent, 2cent, 5cent, 10cent, 20cent, 50cent, 1euro, 2euro 
        
        %subplot(2,8,i);
        
        img=(gray(l+1+(l-1)*94:l+95+(l-1)*94,t+1+(t-1)*94:t+95+(t-1)*94));
        
        [all feature]=buildFeatureVector(img,50,15);
       
        
        %imshow(img)
        %plot(feature);
        i=i+1;
        
        
        % Labe und Feature erstellen
        L=[L,t];
        S=[S,feature'];
        
    end

end


%getFeatureDistance(f1,f3)

%
