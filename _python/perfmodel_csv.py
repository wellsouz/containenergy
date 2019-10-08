#!/usr/bin/python3
'''
Created on 12 nov. 2018

@author: wsilva
'''

import csv
import math
import argparse
import sys
def eprint(*args):
    sys.stderr.write(' '.join(map(str,args)) + '\n')
    

parser = argparse.ArgumentParser()
parser.add_argument("-v", "--verbosity", action="count", default=0)
parser.add_argument("-o", "--output", action="store_true", help="for each input_file automatically generates input_file.perfmodel.csv output file, otherwise outputs to stdout")
parser.add_argument('input_file', nargs='+', help="list of files to process")

args = parser.parse_args()
if args.verbosity >= 2:
    print ("Running '{}'".format(__file__))
if args.verbosity >= 1:
    print ("Running '{}'".format(__file__))

outputfile="sys.stdout"

for inputfile in args.input_file:

    if args.output:
        outputfile=inputfile+".perfmodel.csv"

    eprint ("\nInput: {}".format(inputfile))
    eprint ("Output: {}".format(outputfile))        
        
    #echo -e "\nInput: $i\n">&2


    #fullfilename_list=ntpath.basename(inputfile).split("_")
    
    #prefix=$(echo $fullfilename|cut -d '_' -f 1-4);
    #prefix='_'.join(fullfilename_list[0:4])
    #filename='_'.join(fullfilename_list[4:8])
    #freq=fullfilename_list[8]
    #cores=fullfilename_list[9]
    #runs=fullfilename_list[10]
    #sufix='_'.join(fullfilename_list[11:])
        
    #path="/home/wsilva/seri/esl.lapps/_matlab/"
    #input='perfstat_20181010_115324_eslsrv10_ALL_mem_load_uops_retire.container.stat.csv'
    #inputfile='perfstat_20181010_115324_eslsrv10_ALL_branch-misses:u,bus-.container.stat.csv'
    #outputfile=inputfile+".perfmodel.csv"
    
    d = {}
    rows={}
    milestones={}
    
    a=[]
    
    dictReader = csv.DictReader(open(inputfile, 'r'), delimiter = ',')
    
    rownum=0
    filename=""
    freq=""
    cores=""
    sampling_instant=""
    
    for row in dictReader:
        if (filename!=row['file']) or (freq!=row['freq']) or (cores!=row['cores']):
            
            if rownum!=0:
                milestones[filename+"@"+freq+"@"+cores+"@last_row"]=rownum-1
                milestones[filename+"@"+freq+"@"+cores+"@last_sampling_instant"]=d['sampling_instant'][rownum-1]
            
            filename=row['file']
            freq=row['freq']
            cores=row['cores']
            milestones[filename+"@"+freq+"@"+cores+"@init_row"]=rownum
    
        filename=row['file']
        freq=row['freq']
        cores=row['cores']
        sampling_instant=row['sampling_instant']
        rows[filename+"@"+freq+"@"+cores+"@"+sampling_instant]=row
        
    
        for key in row:
            if rownum==0:
                d[key]=[]
            d[key].append(row[key])
            #if key=="freq":
            #    print "Key: {}   Value:{}".format(key, row[key])
        rownum+=1
        #if rownum>1: break;
    milestones[filename+"@"+freq+"@"+cores+"@last_row"]=rownum-1
    milestones[filename+"@"+freq+"@"+cores+"@last_sampling_instant"]=d['sampling_instant'][rownum-1]
    
    files=sorted(set(d['file']))
    frequencies=sorted(set(d['freq']),key=int)
    cores=sorted(set(d['cores']),key=int)
    sampling_instants=sorted(set(d['sampling_instant']),key=int)
    
    max_resolution=0
    for filename in files:
        w_res=int(filename.split("_")[2].split("x")[0])
        h_res=int(filename.split("_")[2].split("x")[1])
        resolution=w_res*h_res
        if resolution > max_resolution:
            max_resolution=resolution
  

    
    fieldnames=dictReader.fieldnames
    fieldnames.insert(1,"norm_resolution")
    fieldnames.append("freq_Y")
    fieldnames.append("cores_Y")
    fieldnames.append("poc@mean_Y")
    
    dictWriter=csv.DictWriter
    
    #if args.output:
    #    dictWriter = csv.DictWriter(open(outputfile, 'w'), fieldnames=fieldnames)
    #else:
    #    dictWriter = csv.DictWriter(sys.stdout, fieldnames=fieldnames)
        
    
    
    #files=['B_Kimono1_1920x1080_24.yuv']
    rownum=0
    for filename in files:
        dictWriter = csv.DictWriter(open(inputfile+"."+filename+".perfmodel.csv", 'w'), fieldnames=fieldnames)
        dictWriter.writeheader()
        w_res=int(filename.split("_")[2].split("x")[0])
        h_res=int(filename.split("_")[2].split("x")[1])
        norm_resolution=float(w_res*h_res)/float(max_resolution)
        
        
        for freq_X in frequencies:
            for cores_X in cores:
                samplings_X=int(milestones[filename+"@"+freq_X+"@"+cores_X+"@last_sampling_instant"])
                for freq_Y in frequencies:
                    #if int(freq_Y)>1600000: exit(1);
                    for cores_Y in cores:
                        for sampling_instant_X in range(1,samplings_X+1):
                            samplings_Y=int(milestones[filename+"@"+freq_Y+"@"+cores_Y+"@last_sampling_instant"])
                            sampling_instant_Y=int(math.ceil(float(sampling_instant_X*samplings_Y)/float(samplings_X)))
                            poc_X=rows[filename+"@"+freq_X+"@"+cores_X+"@"+str(sampling_instant_X)]['poc@mean']
                            poc_Y=rows[filename+"@"+freq_Y+"@"+cores_Y+"@"+str(sampling_instant_Y)]['poc@mean']
                            pmu_X=rows[filename+"@"+freq_X+"@"+cores_X+"@"+str(sampling_instant_X)]
                            
                            #print (freq_X, cores_X, sampling_instant_X, "PMUs(x)", freq_Y, cores_Y, "FPS(y)")
                            #print ("{} X:{} Y:{} FPS(X):{} FPS(Y):{} PMU(X):{}".format(filename,
                            #                                                freq_X+"@"+cores_X+"@"+str(sampling_instant_X),
                            #                                                freq_Y+"@"+cores_Y+"@"+str(sampling_instant_Y),
                            #                                                poc_X, poc_Y, pmu_X,
                            #                                                #""
                            #                                                ))
                            
                            if ((float(poc_Y)>20) and (float(poc_Y)<30)):
                            #if 1:
                                pmu_X['norm_resolution']=norm_resolution
                                pmu_X['freq_Y']=freq_Y
                                pmu_X['cores_Y']=cores_Y
                                pmu_X['poc@mean_Y']=poc_Y
                                dictWriter.writerow(pmu_X)
                                rownum+=1
                            
                            
    eprint("Rows:{}".format(rownum))
                            
    
                        
                        
    






    
    
        



    
        
        
