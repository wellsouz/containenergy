[File Frequency Cores EncodingCPUUsage FPS EncodingWallTime TimeElapsed ...
PowerPackage PowerRAM EnergyPackage EnergyRAM] = ...
#textread('20180627_170140_eslpc39/perfstat_20180627_170140_eslpc39.sorted.csv', ...
#textread('perfstat_20180717_181601_eslpc39.poweroff.csv', ...
#textread('perfstat_20180629_174034_eslsrv10.6.sorted.csv', ...
#textread('20180729_154511_eslsrv10_32_5/perfstat_20180729_154511_eslsrv10_D_RaceHorses_416x240_30.yuv.csv', ...
#textread('20180729_203815_eslsrv10_32_5/perfstat_20180729_203815_eslsrv10_D_RaceHorses_416x240_30.yuv.csv', ...
textread('20180730_032944_eslsrv10_32_5/perfstat_20180730_032944_eslsrv10.idle.csv', ...
"%f,%d,%d,%f,%f,%f,%f,%f,%f,%f,%f", "headerlines",1);


cores_vector=sort(unique(Cores));
frequencies_vector=sort(unique(Frequency))/1000;
frequencies_vector(16)=3400;
#frequencies_vector(16)=3800;

numFrequencies=size(frequencies_vector,1)
numCores=size(cores_vector,1)
numRowsPerFile=numFrequencies*numCores;
numFiles=size(Cores,1)/numRowsPerFile

for file=0:numFiles-1
#for file=0:20  
  powermatrix=zeros(numCores,numFrequencies);
  fpsmatrix=zeros(numCores,numFrequencies);
  energymatrix=zeros(numCores,numFrequencies);
  colormapfpsmatrix=zeros(numCores,numFrequencies);
  walltimematrix=zeros(numCores,numFrequencies);
  cpuusagematrix=zeros(numCores,numFrequencies);


  #cmaparray=(["default"; "jet"; "cubehelix"; "hsv"; "rainbow"; "hot"; "cool"; "spring"; "summer"; "autumn"; "winter"; "gray"; "bone"; "copper"; "pink"; "ocean"; "colorcube"; "flag"; "lines"; "prism"; "white"]);
  cmaparray=(["jet"]);


  for c=1:size(cmaparray,1)

    figure()

    colormap("default");
  
    cmapitem=colormap(deblank(cmaparray(c,:)));
    
    combinedcolormap=[hot;hsv(64);hsv(64)];
    combinedcolormap(129,:)=[0.66667,0.66667,0.66667];
    combinedcolormap(192,:)=[1.00000,1.00000,1.00000];
    colormap(combinedcolormap);
   
    startrow=file*numRowsPerFile;

    for i=0:numFrequencies-1
      powermatrix(:,i+1) = PowerPackage(startrow+numCores*i+1:startrow+numCores*i+numCores);
      fpsmatrix(:,i+1) = FPS(startrow+numCores*i+1:startrow+numCores*i+numCores);
      energymatrix(:,i+1) = EnergyPackage(startrow+numCores*i+1:startrow+numCores*i+numCores);
      walltimematrix(:,i+1) = EncodingWallTime(startrow+numCores*i+1:startrow+numCores*i+numCores);
      cpuusagematrix(:,i+1) = EncodingCPUUsage(startrow+numCores*i+1:startrow+numCores*i+numCores);
    end
    
    m = 64;  % 64-elements is each colormap
    
    cmin = min(energymatrix(:));
    cmax = max(energymatrix(:));
    C1 = 0+min(m,round((m-1)*(energymatrix-cmin)/(cmax-cmin))+1); 
    
    cmin = min(fpsmatrix(:));
    cmax = max(fpsmatrix(:));
    C2 = 64+min(m,round((m-1)*(fpsmatrix-cmin)/(cmax-cmin))+1); 
    
    C3 = zeros(8,16);
    
    for i=1:numCores
      for j=1:numFrequencies
        fps=fpsmatrix(i,j);
        #colormapfpsmatrix (i+1,j+1) = fps;
        if (fps<24) C3(i,j)=129;
          elseif (fps>28) C3(i,j)=192;
          else C3 (i,j) = 128+min(m,round((m-1)*(fps-cmin)/(cmax-cmin))+1);
        end
      end
    end
    
    
    cmin = min(powermatrix(:));
    cmax = max(powermatrix(:));
    C4 = 0+min(m,round((m-1)*(powermatrix-cmin)/(cmax-cmin))+1); 
    
    cmin = min(walltimematrix(:));
    cmax = max(walltimematrix(:));
    C5 = 64+min(m,round((m-1)*(walltimematrix-cmin)/(cmax-cmin))+1); 

    cmin = min(cpuusagematrix(:));
    cmax = max(cpuusagematrix(:));
    C6 = 64+min(m,round((m-1)*(cpuusagematrix-cmin)/(cmax-cmin))+1); 
    
         
    subplot(2,3,file*0+1);
    #h(1)=surf(frequencies_vector, cores_vector, energymatrix,'Marker','p',"markeredgecolor",'blue');
    h(1)=surf(frequencies_vector, cores_vector, energymatrix);
    
    title ("Energy (J)");
    xlabel ("Frequency (MHz)");
    ylabel ("Cores (#)");
    caxis([min(C1(:)) max(C3(:))])
    
    subplot(2,3,file*0+2);
    #h(2)=surf(frequencies_vector, cores_vector, fpsmatrix,'Marker','p',"markeredgecolor",'blue');
    h(2)=surf(frequencies_vector, cores_vector, fpsmatrix);
    
    title ("FPS");
    xlabel ("Frequency (MHz)");
    ylabel ("Cores (#)");
    caxis([min(C1(:)) max(C3(:))])
    
    subplot(2,3,file*0+3);
    
    #h(3)=surf(frequencies_vector, cores_vector, energymatrix, colormapfpsmatrix,'Marker','p',"markeredgecolor",'blue');
    h(3)=surf(frequencies_vector, cores_vector, energymatrix);
    
    title ("Energy/FPS");
    xlabel ("Frequency (MHz)");
    ylabel ("Cores (#)");
    caxis([min(C1(:)) max(C3(:))])
    
    
    subplot(2,3,file*0+4);
    h(4)=surf(frequencies_vector, cores_vector, powermatrix);
    title ("Power (W)");
    xlabel ("Frequency (MHz)");
    ylabel ("Cores (#)");
    caxis([min(C1(:)) max(C3(:))])

    subplot(2,3,file*0+5);
    h(5)=surf(frequencies_vector, cores_vector, walltimematrix);
    title ("Encoding Wall Time (s)");
    xlabel ("Frequency (MHz)");
    ylabel ("Cores (#)");
    caxis([min(C1(:)) max(C3(:))])
    
    subplot(2,3,file*0+6);
    h(6)=surf(frequencies_vector, cores_vector, cpuusagematrix);
    title ("Encoding CPU usage (%)");
    xlabel ("Frequency (MHz)");
    ylabel ("Cores (#)");
    caxis([min(C1(:)) max(C3(:))])


    
    set(h(1),'cdata',C1);
    set(h(2),'cdata',C2);
    set(h(3),'cdata',C3);
    set(h(4),'cdata',C4);
    set(h(5),'cdata',C5);
    set(h(6),'cdata',C6);

    
  end
end


