# ContainEnergy - A QoS and container-based approach for energy saving and performance profiling in multi-core servers
ContainEnergy is a profiling tool designed to generate comprehensive energy and performance profiling data, with an overhead of 1,18%. 

It uses a combination of software containers, performance counters and DVFS to isolate application and allow user to assess execution over different hardware and software setups.

During execution, DVFS governor is adjusted and raw energy/performance data are extracted by performance counters. These raw values are combined and processed, resulting in a comprehensive profiling dataset crafted on top of the target system tuned throughout available configurations

ContainEnergy is parte of the "Improving the Energy Efficiency of Multi-core Virtual Machines and Software-Defined Servers" project, which is a international collaboration project between ESL.EPFL (Switzerland) and LAPPS.UFRN (Brazil), funded by State Secretariat for Education, Research and Innovation SERI (Switzerland). The project goal is to develop software technologies (framework and API) to improve energy efficiency of applications in multi-core virtual machines and software-defined servers.


## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.


### Prerequisites

* Docker
* Git
* Linux perf tools
* [Kvazaar container](https://github.com/ultravideo/kvazaar#docker) - instructions below:

```
git clone https://github.com/ultravideo/kvazaar.git
cd kvazaar
docker build -t kvazaar .
```

## Profiling

The profiling step is done by extracting and parsing Performance Monitoring Units (PMU) values gathered while application is running.

### PMU extraction

As Kvazaar is as H.265 transcoding application, it needs a video as an input (YUV format, wildcards accepted) and generates a video as output (HEVC/H.265 format).

```
./perfstat_pmu.sh <input_video_file1> <input_video_file2> ...
```
As results, a <input_video_file>.hevc will be generated for each input, herewith a directory (named automatically with <_results/date_time_host_threads_runs>) containing .stat files. Their content is the joint stat outputs of perf (PMUs) and Kvazaar, as shown below.

```
Using preset ultrafast: --rd=0 --pu-depth-intra=2-3 --pu-depth-inter=2-3 --me=hexbs --gop=lp-g4d4t1 --ref=1 --bipred=0 --deblock=0:0 --signhide=0 --subme=2 --sao=off --rdoq=0 --rdoq-skip=0 -
-transform-skip=0 --mv-rdo=0 --full-intra-search=0 --smp=0 --amp=0 --cu-split-termination=zero --me-early-termination=sensitive 
Compiled: INTEL, flags: MMX SSE SSE2
Detected: INTEL, flags: MMX SSE SSE2 SSE3 SSSE3 SSE41 SSE42 AVX AVX2
Available: avx(11) avx2(44) sse2(2) sse41(1) 
In use: avx(2) avx2(44) 
--owf=auto value set to 4.
Input: -, output: -
  Video size: 1920x1080 (input=1920x1080)
POC    0 QP 22 (I-frame)    3234920 bits PSNR Y 42.0925 U 43.0222 V 44.4603
POC    1 QP 26 (P-frame)     647224 bits PSNR Y 35.5692 U 41.5065 V 43.6256 [L0 0 ] [L1 ]
POC    2 QP 25 (P-frame)     939784 bits PSNR Y 36.5041 U 41.5294 V 43.5897 [L0 1 ] [L1 ]
POC    3 QP 26 (P-frame)     622168 bits PSNR Y 35.4565 U 41.3498 V 43.4504 [L0 2 ] [L1 ]
POC    4 QP 23 (P-frame)    1727008 bits PSNR Y 38.7735 U 41.9440 V 43.7572 [L0 3 ] [L1 ]
POC    5 QP 26 (P-frame)     703344 bits PSNR Y 35.5868 U 41.3961 V 43.4437 [L0 4 ] [L1 ]
POC    6 QP 25 (P-frame)     952976 bits PSNR Y 36.4877 U 41.4275 V 43.4544 [L0 5 ] [L1 ]
POC    7 QP 26 (P-frame)     677144 bits PSNR Y 35.5399 U 41.2213 V 43.2826 [L0 6 ] [L1 ]
POC    8 QP 23 (P-frame)    1700232 bits PSNR Y 38.7559 U 41.8619 V 43.6352 [L0 7 ] [L1 ]
POC    9 QP 26 (P-frame)     540640 bits PSNR Y 35.3946 U 41.3147 V 43.3194 [L0 8 ] [L1 ]
POC   10 QP 25 (P-frame)     894352 bits PSNR Y 36.4633 U 41.3890 V 43.2926 [L0 9 ] [L1 ]
POC   11 QP 26 (P-frame)     620936 bits PSNR Y 35.4832 U 41.1575 V 43.1296 [L0 10 ] [L1 ]
POC   12 QP 23 (P-frame)    1701920 bits PSNR Y 38.7364 U 41.7994 V 43.5485 [L0 11 ] [L1 ]
POC   13 QP 26 (P-frame)     637368 bits PSNR Y 35.5146 U 41.2644 V 43.2056 [L0 12 ] [L1 ]
POC   14 QP 25 (P-frame)     955272 bits PSNR Y 36.4511 U 41.3078 V 43.2038 [L0 13 ] [L1 ]
POC   15 QP 26 (P-frame)     657568 bits PSNR Y 35.5216 U 41.1302 V 43.0618 [L0 14 ] [L1 ]
POC   16 QP 23 (P-frame)    1640912 bits PSNR Y 38.7368 U 41.8135 V 43.5006 [L0 15 ] [L1 ]
POC   17 QP 26 (P-frame)     503472 bits PSNR Y 35.3886 U 41.2882 V 43.1589 [L0 16 ] [L1 ]
POC   18 QP 25 (P-frame)     921248 bits PSNR Y 36.4920 U 41.3464 V 43.1331 [L0 17 ] [L1 ]
POC   19 QP 26 (P-frame)     537992 bits PSNR Y 35.3535 U 41.1069 V 42.9510 [L0 18 ] [L1 ]
     1.001720870,171778714,,branch-misses:u,32035036216,100.00,,
     1.001720870,878607247,,bus-cycles:u,32032278050,100.00,,
     1.001720870,111710950,,fp_arith_inst_retired.scalar_double:u,32028757293,100.00,,
     1.001720870,37286804623,,instructions:u,32026286213,100.00,,
     1.001720870,42735053,,l2_rqsts.l2_pf_miss:u,32022628243,100.00,,
```

These files need to be parsed with compare_pmu.sh.


### PMU parsing

Files generated with perfstat_pmu.sh are regular, human-readable TXT mixed with CSV content. To be useful for visualization (spreadsheet, graphs), data analytics or automated processing (ML, for instance), data must converted to pure CSV, which is performed by compare_pmu.sh. This script parses the .stat files (wildcards accepted) and generate according CSV in standard output (can be saved through file redirection '>').

```
./compare_pmu.sh <stat_file1> <stat_file2> ...
```

A tipical output of compare_pmu.sh is shown below.


```
../compare_pmu.sh file.stat
time,mean,unit,event,counterruntime-average,counterruntime-pct,stdev,min,max,poc
1.001720870,171778714.000000000,_,event@branch-misses:u@1,_,_,0.00,171778714,171778714,20
1.001720870,37286804623.000000000,_,event@instructions:u@1,_,_,0.00,37286804623,37286804623,20
1.001720870,111710950.000000000,_,event@fp_arith_inst_retired.scalar_double:u@1,_,_,0.00,111710950,111710950,20
1.001720870,878607247.000000000,_,event@bus-cycles:u@1,_,_,0.00,878607247,878607247,20
1.001720870,42735053.000000000,_,event@l2_rqsts.l2_pf_miss:u@1,_,_,0.00,42735053,42735053,20
2.002415707,370308842.000000000,_,event@branch-misses:u@1,_,_,0.00,370308842,370308842,54
2.002415707,83168588867.000000000,_,event@instructions:u@1,_,_,0.00,83168588867,83168588867,54
2.002415707,270419969.000000000,_,event@fp_arith_inst_retired.scalar_double:u@1,_,_,0.00,270419969,270419969,54
2.002415707,1923911460.000000000,_,event@bus-cycles:u@1,_,_,0.00,1923911460,1923911460,54
2.002415707,97546313.000000000,_,event@l2_rqsts.l2_pf_miss:u@1,_,_,0.00,97546313,97546313,54
3.003043918,365703383.000000000,_,event@branch-misses:u@1,_,_,0.00,365703383,365703383,56
3.003043918,84181696355.000000000,_,event@instructions:u@1,_,_,0.00,84181696355,84181696355,56
3.003043918,280068568.000000000,_,event@fp_arith_inst_retired.scalar_double:u@1,_,_,0.00,280068568,280068568,56
3.003043918,1946684789.000000000,_,event@bus-cycles:u@1,_,_,0.00,1946684789,1946684789,56
3.003043918,99699464.000000000,_,event@l2_rqsts.l2_pf_miss:u@1,_,_,0.00,99699464,99699464,56
4.003712942,322664835.000000000,_,event@branch-misses:u@1,_,_,0.00,322664835,322664835,58
4.003712942,77535821031.000000000,_,event@instructions:u@1,_,_,0.00,77535821031,77535821031,58
4.003712942,267279265.000000000,_,event@fp_arith_inst_retired.scalar_double:u@1,_,_,0.00,267279265,267279265,58
4.003712942,1738187847.000000000,_,event@bus-cycles:u@1,_,_,0.00,1738187847,1738187847,58
4.003712942,98199973.000000000,_,event@l2_rqsts.l2_pf_miss:u@1,_,_,0.00,98199973,98199973,58
5.004347017,286677117.000000000,_,event@branch-misses:u@1,_,_,0.00,286677117,286677117,56
5.004347017,69026066140.000000000,_,event@instructions:u@1,_,_,0.00,69026066140,69026066140,56
5.004347017,250173516.000000000,_,event@fp_arith_inst_retired.scalar_double:u@1,_,_,0.00,250173516,250173516,56
5.004347017,1513225548.000000000,_,event@bus-cycles:u@1,_,_,0.00,1513225548,1513225548,56
5.004347017,88852439.000000000,_,event@l2_rqsts.l2_pf_miss:u@1,_,_,0.00,88852439,88852439,56
6.004990529,343498925.000000000,_,event@branch-misses:u@1,_,_,0.00,343498925,343498925,57
6.004990529,79745869219.000000000,_,event@instructions:u@1,_,_,0.00,79745869219,79745869219,57
6.004990529,269224490.000000000,_,event@fp_arith_inst_retired.scalar_double:u@1,_,_,0.00,269224490,269224490,57
6.004990529,1826224838.000000000,_,event@bus-cycles:u@1,_,_,0.00,1826224838,1826224838,57
6.004990529,98886786.000000000,_,event@l2_rqsts.l2_pf_miss:u@1,_,_,0.00,98886786,98886786,57
7.005667671,383888962.000000000,_,event@branch-misses:u@1,_,_,0.00,383888962,383888962,53
7.005667671,84794556550.000000000,_,event@instructions:u@1,_,_,0.00,84794556550,84794556550,53
7.005667671,271007727.000000000,_,event@fp_arith_inst_retired.scalar_double:u@1,_,_,0.00,271007727,271007727,53
7.005667671,1982393429.000000000,_,event@bus-cycles:u@1,_,_,0.00,1982393429,1982393429,53
7.005667671,97827119.000000000,_,event@l2_rqsts.l2_pf_miss:u@1,_,_,0.00,97827119,97827119,53
8.006345733,404273023.000000000,_,event@branch-misses:u@1,_,_,0.00,404273023,404273023,51
8.006345733,86793986242.000000000,_,event@instructions:u@1,_,_,0.00,86793986242,86793986242,51
8.006345733,268292799.000000000,_,event@fp_arith_inst_retired.scalar_double:u@1,_,_,0.00,268292799,268292799,51
8.006345733,2071795571.000000000,_,event@bus-cycles:u@1,_,_,0.00,2071795571,2071795571,51
8.006345733,97394686.000000000,_,event@l2_rqsts.l2_pf_miss:u@1,_,_,0.00,97394686,97394686,51
9.007008073,386427483.000000000,_,event@branch-misses:u@1,_,_,0.00,386427483,386427483,50
9.007008073,83586254448.000000000,_,event@instructions:u@1,_,_,0.00,83586254448,83586254448,50
9.007008073,257644443.000000000,_,event@fp_arith_inst_retired.scalar_double:u@1,_,_,0.00,257644443,257644443,50
9.007008073,1975459325.000000000,_,event@bus-cycles:u@1,_,_,0.00,1975459325,1975459325,50
9.007008073,93668417.000000000,_,event@l2_rqsts.l2_pf_miss:u@1,_,_,0.00,93668417,93668417,50
10.007666698,351639585.000000000,_,event@branch-misses:u@1,_,_,0.00,351639585,351639585,52
10.007666698,81149711702.000000000,_,event@instructions:u@1,_,_,0.00,81149711702,81149711702,52
10.007666698,263151699.000000000,_,event@fp_arith_inst_retired.scalar_double:u@1,_,_,0.00,263151699,263151699,52
10.007666698,1883944771.000000000,_,event@bus-cycles:u@1,_,_,0.00,1883944771,1883944771,52
10.007666698,93944664.000000000,_,event@l2_rqsts.l2_pf_miss:u@1,_,_,0.00,93944664,93944664,52
11.008311500,351767126.000000000,_,event@branch-misses:u@1,_,_,0.00,351767126,351767126,55
11.008311500,81690236027.000000000,_,event@instructions:u@1,_,_,0.00,81690236027,81690236027,55
11.008311500,268932888.000000000,_,event@fp_arith_inst_retired.scalar_double:u@1,_,_,0.00,268932888,268932888,55
11.008311500,1903896983.000000000,_,event@bus-cycles:u@1,_,_,0.00,1903896983,1903896983,55
11.008311500,96696904.000000000,_,event@l2_rqsts.l2_pf_miss:u@1,_,_,0.00,96696904,96696904,55
12.008959044,242759048.000000000,_,event@branch-misses:u@1,_,_,0.00,242759048,242759048,39
12.008959044,56061854670.000000000,_,event@instructions:u@1,_,_,0.00,56061854670,56061854670,39
12.008959044,189823093.000000000,_,event@fp_arith_inst_retired.scalar_double:u@1,_,_,0.00,189823093,189823093,39
12.008959044,1284404999.000000000,_,event@bus-cycles:u@1,_,_,0.00,1284404999,1284404999,39
12.008959044,65400949.000000000,_,event@l2_rqsts.l2_pf_miss:u@1,_,_,0.00,65400949,65400949,39
13.056767131,2677461.000000000,_,event@branch-misses:u@1,_,_,0.00,2677461,2677461,0
13.056767131,385792467.000000000,_,event@instructions:u@1,_,_,0.00,385792467,385792467,0
13.056767131,28415.000000000,_,event@fp_arith_inst_retired.scalar_double:u@1,_,_,0.00,28415,28415,0
13.056767131,9498983.000000000,_,event@bus-cycles:u@1,_,_,0.00,9498983,9498983,0
13.056767131,635386.000000000,_,event@l2_rqsts.l2_pf_miss:u@1,_,_,0.00,635386,635386,0
13.076100797,11904.000000000,_,event@branch-misses:u@1,_,_,0.00,11904,11904,0
13.076100797,5543506.000000000,_,event@instructions:u@1,_,_,0.00,5543506,5543506,0
13.076100797,251.000000000,_,event@fp_arith_inst_retired.scalar_double:u@1,_,_,0.00,251,251,0
13.076100797,120859.000000000,_,event@bus-cycles:u@1,_,_,0.00,120859,120859,0
13.076100797,1679.000000000,_,event@l2_rqsts.l2_pf_miss:u@1,_,_,0.00,1679,1679,0
13.076100797,207.301,,TotalCpuTime
13.076100797,207.298,,EncodingTime
13.076100797,11.270,,EncodingWallTime
13.076100797,1839.45,,EncodingCpuUsage
13.076100797,53.33,,Fps
```

### Filters, App Model, Power Model, ML-Scheduler

TO-DO

## Authors

* **Wellington Souza** - [Lattes CV](http://lattes.cnpq.br/6381572434235852)


## Acknowledgments

* [ESL Team @ EPFL](https://esl.epfl.ch)
* State Secretariat for Education, Research and Innovation SERI (Switzerland)
* [README.md template](https://gist.github.com/PurpleBooth/109311bb0361f32d87a2)

