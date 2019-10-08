%% With resolution

close all

Data = xlsread('D:\Wellington-Date\Data1.xlsx');
FPS = Data(:,28);
PC = Data(:,[1 2 3 5 7 8 9]);

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
tic
ypred = predict(Mdl, PCtest);
toc
RMSE = sqrt(mean((ypred - FPStest).^2));
figure
plot(FPStest)
hold on
plot(ypred)
xlabel('Frame');
ylabel('FPS');
legend('real data', 'predicted')