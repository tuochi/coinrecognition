function [meanPrecision Precision] = crossval()
% Crossvalidierung der 8 Euromuenzen Vorder- und Rueckseite
% mode [0]: es wird fuer alle Muenzen durchgefuehrt [1 2]: erste Muneze 
% Precision: gibt den prozentuellen Anteil der richtig klassifizierten
% Muenzen an
addpath('tools/osu-svm');
% if nargin <1
%     mode=[0];
% end

%     for i=i:size(mode,2)
%         
%         
%     end

%% spezifisches TrainingsSet 

colorMode=[1 2 3];
buildTrainingsSet('collection',1,'_low',colorMode,'extended',1);
%laden der Labelings
load (['PC-' getenv('COMPUTERNAME') '-Crossval-labelingStruct'] ,'labelingStruct');
%laden des TrainingsSets
load(['PC-' getenv('COMPUTERNAME') '-Crossval-TrainingSet']);
%SVM wird nun erstellt


%Aufteilung der Daten in Training und TestSet
c = cvpartition(LabelSet,'kfold',400);
%% Nun die jeweiligen Training- und TestSets
Precision=[];
for i=1:c.NumTestSets

    % Trainingset Daten ermitteln
    crossTrainTrainingSetSVM=TrainingSetSVM(c.training(i),:);
    crossTrainTrainingSetEuclid=TrainingSetEuclid(c.training(i),:);
    crossTrainLabelSet=LabelSet(c.training(i),:);
    
    % Testset Daten ermitteln
    crossTestSetSVM=TrainingSetSVM(c.test(i),:); 
    crossTestSetEuclid=TrainingSetEuclid(c.test(i),:);
    crossTestLabelSet=LabelSet(c.test(i),:);
    % SVM erstellen
    %svmConstruction(2, TrainTrainingSetSVM', TrainLabelSet',1);
    %load([getenv('COMPUTERNAME') '-SVMClassifier']);
    
    %SVM erstellen
    disp(['Poly SVM (' num2str(i) '/' num2str(c.NumTestSets) ') wird erstellt'])
    [AlphaY, SVs, Bias, Parameters, nSV, nLabel] = PolySVC(crossTrainTrainingSetSVM', crossTrainLabelSet');    

    %% START TEST
    
    %SVM Klassifikation
    [SVMLabel DecisionValue]=SVMClass(crossTestSetSVM', AlphaY, SVs, Bias, Parameters, nSV, nLabel);
    
    %Auswerten der SVM Klassifikation
    precisionSVM=mean(SVMLabel==crossTestLabelSet');
    werte=[];
    for j=1:size(SVMLabel,2)
        werte=[werte labelingStruct{SVMLabel(j),2}==labelingStruct{crossTestLabelSet(j),2}];
    end
    precisionSVMValue=mean(werte);
    
    %Euclidische Klassifikation
    euclidLabel=[];
    for k=1:size(crossTestSetEuclid,1)
            %Distanz berechnen
            dist=getFeatureDistance(crossTestSetEuclid(k,:),crossTrainTrainingSetEuclid);
            [value,index]=min(dist);
            euclidLabel=[euclidLabel crossTrainLabelSet(index)];
    end

    %Auswerten des Euclid Klassifikation
    precisionEuclid=mean(euclidLabel==crossTestLabelSet');
    werte=[];
    for j=1:size(euclidLabel,2)
        werte=[werte labelingStruct{euclidLabel(j),2}==labelingStruct{crossTestLabelSet(j),2}];
    end
    precisionEuclidValue=mean(werte);
    
    %% Klassifikationsrate 
    Precision=[Precision ; precisionSVMValue precisionSVM precisionEuclidValue precisionEuclid];

end
    Precision
meanPrecision=mean(Precision,1);
%% Ergebnisse speichern

end