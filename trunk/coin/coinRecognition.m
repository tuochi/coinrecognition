clear all;

%Name der Image-Datei
imgName ='coin/shoot/IMG_6838.jpg';
minR = 20;
maxR = 100;

%Laden des Images
image = imread(imgName);

%GrauwertBild
gwImage=rgb2gray(image);

%imshow(gwImage)

%Hough-Array
hough = zeros(size(gwImage,1)+2*maxR, size(gwImage,2)+2*maxR, maxR-minR+1);

%F�r jeden Kreispunkt Px,Py liegt der m�gliche Mittelpunkt innerhalb von
%[Px-maxR:Px+maxR, Py-maxR:Py+maxR]
%Daraus folgt das aufgespannte Gitter muss die gr��e [0:2*maxR, 0:2*maxR]
%haben
[GridX GridY]=meshgrid(0:(2*maxR), 0:(2*maxR));

%Berechnen der Radien f�r jeden Punkt innerhalb des Beobachtungsfensters
radiusGrid = round(sqrt((GridX-maxR).^2 + (GridY-maxR).^2));
%Entfernen der m�glichen Radien, die au�erhalb des g�ltigen Bereiches
%liegen
radiusGrid(radiusGrid<minR | radiusGrid>maxR) = 0;

%Kanten der M�nzen ermitteln
kanten = edge(gwImage,'canny',[0.15 0.2]);

%Indizes finden f�r erkannte Kantenpunkte
[kY kX]=find(kanten);
%Indizes finden f�r alle Kreispunkte und Radiuswert r
[mY mX r] = find(radiusGrid);

%F�r jeden gefunden Kantenpunkt werden Kreise mit minR<=r<=maxR betrachtet
%und Hough-Array im entsprechenden Eintrag um 1 erh�ht
for i=1:length(kX)
    i;
    index = sub2ind(size(hough), mY+kY(i)-1, mX+kX(i)-1, r-minR+1);
    hough(index)=hough(index)+1;
end

%zwei PI
zweiPi = 0.9*pi*2;

%Kreis-Objekt mit [x y r **]
kreis=zeros(0,4);

%F�r alle Radien wird der Umfang berechnet und der entsprechende Ausschnitt
%des Hough-Arrays wird betrachtet
for radius = minR:maxR
    umfang = zweiPi*radius;
    ausschnitt=hough( : , : , radius-minR+1);

    %Ausschnitt wird gel�scht wenn nicht gen�gend vom Kreis vorhanden ist
    ausschnitt(ausschnitt<umfang*0.33)=0;
    
    %Indizes der m�glichen Kreismittelpunkte im Hough-Raum mit Akkumulator-
    %wert "a"
    [y x a]=find(ausschnitt);
    
    %Hinzuf�gen von Kreisobjekten [x y radius ???] ?????
    kreis=[kreis; [x-maxR, y-maxR, radius*ones(length(x),1), a/umfang]];
end

%Sortieren der Kreisobjekte
kreis=sortrows(kreis,-4);
i=1;

%Entfernen von �hnlichen Kreisen
while i<size(kreis,1)
    j=i+1;
    while j<=size(kreis,1)
        
        %Wenn der Abstand von Mx, My, Mr kleiner als 36 Pixel ist, dann
        %werden diese Kreise entfernt
        if sum(abs(kreis(i,1:3)-kreis(j,1:3)))<= 80
            kreis(j,:)=[];
        else
            j=j+1;
        end
    end
    i=i+1;
end

%Originalbild
figure
imshow(image)
hold on;

%Zeichnen der Kreise
for i=1:size(kreis,1)
    x = kreis(i,1)-kreis(i,3);
    y = kreis(i,2)-kreis(i,3);
    d = 2*kreis(i,3);
    rectangle('Position',[x y d d], 'EdgeColor', 'yellow', 'Curvature', [1 1]);
end
    