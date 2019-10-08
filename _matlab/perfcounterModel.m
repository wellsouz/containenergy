%% Without considering resolution
close all
Data = xlsread('D:\Wellington-Date\Data.xlsx');
FPS = Data(:,27);
PC = Data(:,[1 2 4 6 7 8]);
TrainTestRatio = 0.75;
rnd = randperm(length(Data),floor(TrainTestRatio * length(Data)));
rnd = sort(rnd);
FPStrain = FPS(rnd,:);
PCtrain = PC(rnd,:);
PCtest = PC;
PCtest(rnd,:) = [];
FPStest = FPS;
FPStest(rnd,:) = [];
Mdl = TreeBagger(100,PCtrain,FPStrain,'Method','regression');
ypred = predict(Mdl, PCtest);
RMSE = sqrt(mean((ypred - FPStest).^2));
figure
plot(FPStest)
hold on
plot(ypred)
xlabel('Frame');
ylabel('FPS');
legend('real data', 'predicted')