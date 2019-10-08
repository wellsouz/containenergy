#[File_idle Frequency_idle Cores_idle EncodingCPUUsage_idle FPS_idle EncodingWallTime_idle TimeElapsed_idle ...
#PowerPackage_idle PowerRAM_idle EnergyPackage_idle EnergyRAM_idle] = ...
#textread('20180730_001841_eslsrv10_32_5/perfstat_20180730_001841_eslsrv10.coresidle.csv', ...
#"%f,%d,%d,%f,%f,%f,%f,%f,%f,%f,%f", "headerlines",1);

#[File_lin Frequency_lin Cores_lin EncodingCPUUsage_lin FPS_lin EncodingWallTime_lin TimeElapsed_lin ...
#PowerPackage_lin PowerRAM_lin EnergyPackage_lin EnergyRAM_lin] = ...
#textread('20180729_203815_eslsrv10_32_5/perfstat_20180729_203815_eslsrv10.linearpoweroff.csv', ...
#"%f,%d,%d,%f,%f,%f,%f,%f,%f,%f,%f", "headerlines",1);

#[File_ca Frequency_ca Cores_ca EncodingCPUUsage_ca FPS_ca EncodingWallTime_ca TimeElapsed_ca ...
#PowerPackage_ca PowerRAM_ca EnergyPackage_ca EnergyRAM_ca] = ...
#textread('20180729_154511_eslsrv10_32_5/perfstat_20180729_154511_eslsrv10.coreaware.csv', ...
#"%f,%d,%d,%f,%f,%f,%f,%f,%f,%f,%f", "headerlines",1);


[File_il Frequency_il Cores_il EncodingCPUUsage_il FPS_il EncodingWallTime_il TimeElapsed_il ...
PowerPackage_il PowerRAM_il EnergyPackage_il EnergyRAM_il] = ...
textread('20180730_032944_eslsrv10_32_5/perfstat_20180730_032944_eslsrv10.idle-linear.csv', ...
"%f,%d,%d,%f,%f,%f,%f,%f,%f,%f,%f", "headerlines",1);

[File_ic Frequency_ic Cores_ic EncodingCPUUsage_ic FPS_ic EncodingWallTime_ic TimeElapsed_ic ...
PowerPackage_ic PowerRAM_ic EnergyPackage_ic EnergyRAM_ic] = ...
textread('20180731_173308_eslsrv10_32_5/perfstat_20180731_173308_eslsrv10.idle-coreaware.csv', ...
"%f,%d,%d,%f,%f,%f,%f,%f,%f,%f,%f", "headerlines",1);

[File_pl Frequency_pl Cores_pl EncodingCPUUsage_pl FPS_pl EncodingWallTime_pl TimeElapsed_pl ...
PowerPackage_pl PowerRAM_pl EnergyPackage_pl EnergyRAM_pl] = ...
textread('20180802_125017_eslsrv10_32_5/perfstat_20180802_125017_eslsrv10.poweroff-linear.csv', ...
"%f,%d,%d,%f,%f,%f,%f,%f,%f,%f,%f", "headerlines",1);

[File_pc Frequency_pc Cores_pc EncodingCPUUsage_pc FPS_pc EncodingWallTime_pc TimeElapsed_pc ...
PowerPackage_pc PowerRAM_pc EnergyPackage_pc EnergyRAM_pc] = ...
textread('20180803_113117_eslsrv10_32_5/perfstat_20180803_113117_eslsrv10.poweroff-coreaware.csv', ...
"%f,%d,%d,%f,%f,%f,%f,%f,%f,%f,%f", "headerlines",1);



cores_vector=sort(unique(Cores_il));
frequencies_vector=sort(unique(Frequency_il))/1000;
frequencies_vector(16)=3400;

numFrequencies=size(frequencies_vector,1)
numCores=size(cores_vector,1)
numRowsPerFile=numFrequencies*numCores;
numFiles=size(Cores_il,1)/numRowsPerFile



#for file=0:numFiles-1
for file=0:0

  energymatrix_il=zeros(numCores,numFrequencies);
  energymatrix_ic=zeros(numCores,numFrequencies);
  energymatrix_pl=zeros(numCores,numFrequencies);
  #energymatrix_pc=zeros(numCores,numFrequencies);
  
  fps_per_core_n_il=zeros(numCores,numFrequencies);
  fps_per_core_n_ic=zeros(numCores,numFrequencies);
  fps_per_core_n_pl=zeros(numCores,numFrequencies);
  
  coresmatrix=zeros(numCores,numFrequencies);
  

 

  startrow=file*numRowsPerFile;

  for i=0:numFrequencies-1
    energymatrix_il(:,i+1) = EnergyPackage_il(startrow+numCores*i+1:startrow+numCores*i+numCores);
    energymatrix_ic(:,i+1) = EnergyPackage_ic(startrow+numCores*i+1:startrow+numCores*i+numCores);
    energymatrix_pl(:,i+1) = EnergyPackage_pl(startrow+numCores*i+1:startrow+numCores*i+numCores);
    energymatrix_pc(:,i+1) = EnergyPackage_pc(startrow+numCores*i+1:startrow+numCores*i+numCores);
    
    fps_per_core_n_il(:,i+1) = FPS_il(startrow+numCores*i+1:startrow+numCores*i+numCores);
    fps_per_core_n_ic(:,i+1) = FPS_ic(startrow+numCores*i+1:startrow+numCores*i+numCores);
    fps_per_core_n_pl(:,i+1) = FPS_pl(startrow+numCores*i+1:startrow+numCores*i+numCores);
    fpsmatrix_pc(:,i+1) = EnergyPackage_pc(startrow+numCores*i+1:startrow+numCores*i+numCores);
    
    #energymatrix_il(:,i+1) = EnergyPackage_il(startrow+numCores*i+1:startrow+numCores*i+numCores);
    #energymatrix_ic(:,i+1) = EnergyPackage_ic(startrow+numCores*i+1:startrow+numCores*i+numCores);
    #energymatrix_pl(:,i+1) = EnergyPackage_pl(startrow+numCores*i+1:startrow+numCores*i+numCores);
    #energymatrix_pc(:,i+1) = EnergyPackage_pc(startrow+numCores*i+1:startrow+numCores*i+numCores);
    
    coresmatrix(:,i+1) = cores_vector(:);
  end

  figure()

  h(1)=surf(fps_per_core_n_il, coresmatrix, energymatrix_il,'EdgeColor', 'blue', 'FaceColor', [200,1,255]/255, 'Marker', '.' );
  hold on

  h(2)=surf(fps_per_core_n_ic, coresmatrix, energymatrix_ic,'EdgeColor', 'white', 'FaceColor', [255,100,0]/255, 'Marker', '.' );
  hold off

  #h(3)=surf(fps_per_core_n_il, coresmatrix, energymatrix_pl, 'EdgeColor', 'black', 'FaceColor', [1,255,200]/255, 'Marker', '.'); 
  #hold off

  #h(4)=surf(fps_per_core_n_ic, coresmatrix, energymatrix_pc, 'EdgeColor', 'black', 'FaceColor', [200,1,255]/255, 'Marker', '.'); 
  #hold off




#  h(3)=surf(frequencies_vector, cores_vector, energymatrix_pl, 'EdgeColor', 'black', 'FaceColor', [1,255,200]/255, 'Marker', '.'); 
#  hold on

#  h(4)=surf(frequencies_vector, cores_vector, energymatrix_pc, 'EdgeColor', 'black', 'FaceColor', [200,1,255]/255, 'Marker', '.'); 
#  hold off
  
  xlabel ("FPS");
  ylabel ("Cores (#)");
  
  legend([h(1), h(2)], {'idle-linear', 'idle-coreaware'});
  title ("Energy (J) / Idle Linear X Idle Core-aware");
  
  #legend([h(3), h(4)], {'poweroff-linear', 'poweroff-coreaware'});
  #litle ("Energy (J) / Poweroff Linear X Poweroff Core-aware");

  #legend([h(1), h(3)], {'idle-linear', 'poweroff-linear'});
  #title ("Energy (J) / Idle Linear X Poweroff Linear");

  #legend([h(2), h(4)], {'idle-coreaware', 'poweroff-coreaware'});
  #title ("Energy (J) / Idle Core-aware X Poweroff Core-aware");
  
  
#  legend([h(1), h(2), h(3)], {'idle-linear', 'idle-coreaware', 'poweroff-linear'});

#  legend([h(1), h(3)], {'idle-linear', 'poweroff-linear'});

#  legend([h(3), h(4)], {'poweroff-linear', 'poweroff-coreaware'});
  
end


