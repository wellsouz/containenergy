#!/usr/bin/python3
# -*- coding: utf-8 -*-

import argparse
import ntpath
import re
import sys
import math


#Flags
DEBUG=0
PRINT_TXT_POC_LINE_COUNTING=0
PRINT_CSV_SAMPLED_POC=0
PRINT_CSV_TOTAL_SAMPLED_POC=0
PRINT_CSV_PERF_INPUT_LINES=0
PRINT_CSV_INTRA_SAMPLING_STATISTICS=0
PRINT_CSV_INTER_SAMPLING_STATISTICS=1
PRINT_CSV_KVAZAAR_PER_RUN_STATISTICS=0
PRINT_CSV_KVAZAAR_ALL_RUN_STATISTICS=0


# Global variables
sampling_counter=0
max_sampling_counter=0
run_counter=0

matrix={}
matrix_inter={}
events_array={}

fullfilename=""
prefix=""
filename=""
freq=""
cores=""
sufix=""

def add(a,b):
    return a+b

def addFixedValue(a):
    y = 5
    return y +a

def eprint(*args):
    sys.stderr.write(' '.join(map(str,args)) + '\n')
    
# Function to print statistics related to analysis of an event in different executions, but in the same order
# (event x on the same instant y of each execution). Output in in human readable (commented out) and CSV.
# It iterates through the associative matrix of parsed events, calculating the statistics and printing at end.    
def printInterSamplingStatistics():
    
    for k, v in matrix_inter.items():
        #print(k,v)
        if re.match('.*event@.*', str(v)):
            v_split=v.split("@")
            e_inter=v_split[1]
            s_inter=v_split[2]
            n_inter=v_split[4]

            #n_inter="${matrix_inter[$e_inter@$s_inter,n]}"
            if DEBUG==1:
                #eprint("r:{} e_inter:{} s_inter:{} r_inter:{} n_inter:{}".format(r,e_inter,s_inter,r_inter,n_inter))
                eprint("r:{} e_inter:{} s_inter:{} n_inter:{}".format(v,e_inter,s_inter,n_inter))
            if int(n_inter) > 0:
                matrix_inter[e_inter+"@"+s_inter+",mean"]=float(matrix_inter[e_inter+"@"+s_inter+",sum"])/float(n_inter)
                
                matrix_inter[e_inter+"@"+s_inter+"_poc,mean"]=float(matrix_inter[e_inter+"@"+s_inter+"_poc,sum"])/float(n_inter)

            # Standard Deviation (std)
            # std - 1) Sum of the squared differences in relation to the mean
            for s in range(1,int(n_inter)+1):
                #print (n_inter)
                if DEBUG==1:
                    eprint("s:{} d2:{} mean:{} value:{}".format(str(s), matrix_inter[e_inter+"@"+s_inter+",d2"], matrix_inter[e_inter+"@"+s_inter+",mean"], matrix_inter[e_inter+"@"+s_inter+","+str(s)]))

                matrix_inter[e_inter+"@"+s_inter+",d2"]=matrix_inter[e_inter+"@"+s_inter+",d2"] + ((matrix_inter[e_inter+"@"+s_inter+","+str(s)] - matrix_inter[e_inter+"@"+s_inter+",mean"]) ** 2)

                matrix_inter[e_inter+"@"+s_inter+"_poc,d2"]=matrix_inter[e_inter+"@"+s_inter+"_poc,d2"] + ((matrix_inter[e_inter+"@"+s_inter+"_poc,"+str(s)] - matrix_inter[e_inter+"@"+s_inter+"_poc,mean"]) ** 2)
                

            # std - 2) Final result of Standard Deviation (absolute)
            if matrix_inter[e_inter+"@"+s_inter+",d2"] > 0:
                matrix_inter[e_inter+"@"+s_inter+",std"]=math.sqrt(matrix_inter[e_inter+"@"+s_inter+",d2"] / (float(n_inter) - 1))

            if matrix_inter[e_inter+"@"+s_inter+"_poc,d2"] > 0:
                matrix_inter[e_inter+"@"+s_inter+"_poc,std"]=math.sqrt(matrix_inter[e_inter+"@"+s_inter+"_poc,d2"] / (float(n_inter) - 1))


            # std - 3) Final result of Standard Deviation (percentual - more useful)
            if matrix_inter[e_inter+"@"+s_inter+",mean"] != 0:
                matrix_inter[e_inter+"@"+s_inter+",stdpct"]=matrix_inter[e_inter+"@"+s_inter+",std"] * 100 / matrix_inter[e_inter+"@"+s_inter+",mean"]

            if matrix_inter[e_inter+"@"+s_inter+"_poc,mean"] != 0:
                matrix_inter[e_inter+"@"+s_inter+"_poc,stdpct"]=matrix_inter[e_inter+"@"+s_inter+"_poc,std"] * 100 / matrix_inter[e_inter+"@"+s_inter+"_poc,mean"]

            #Human readable output
            if DEBUG==1:
                eprint(e_inter+"[name] -- "  +str(matrix_inter[e_inter+"@"+s_inter+",name"]))
                eprint(e_inter+"[time] -- "  +str(matrix_inter[e_inter+"@"+s_inter+",time"]))
                eprint(e_inter+"[poc] -- "   +str(matrix_inter[e_inter+"@"+s_inter+",poc"]))
                eprint(e_inter+"[max] -- "   +str(matrix_inter[e_inter+"@"+s_inter+",max"]))
                eprint(e_inter+"[min] -- "   +str(matrix_inter[e_inter+"@"+s_inter+",min"]))
                eprint(e_inter+"[sum] -- "   +str(matrix_inter[e_inter+"@"+s_inter+",sum"]))
                eprint(e_inter+"[mean] -- "  +str(matrix_inter[e_inter+"@"+s_inter+",mean"]))
                eprint(e_inter+"[d2] -- "    +str(matrix_inter[e_inter+"@"+s_inter+",d2"]))
                eprint(e_inter+"[std] -- "   +str(matrix_inter[e_inter+"@"+s_inter+",std"]))
                eprint(e_inter+"[stdpct] -- "+str(matrix_inter[e_inter+"@"+s_inter+",stdpct"]))

    #for e in "${events_array[@]}"; do
    #    for (( s=1; s<=$max_sampling_counter; s++ )); do
    #        for r in "${matrix_inter[@]}"; do
    #            if [[ $r =~ .*event@$e@$s@.* ]]; then
    #                e_inter=$(echo $r | cut -f 2 -d '@')
    #                s_inter=$(echo $r | cut -f 3 -d '@')
    #                r_inter=$(echo $r | cut -f 4 -d '@')
    #                n_inter="${matrix_inter[$e_inter@$s_inter,n]}"

    #                #Print inter sampling statistics - perf CSV style - if enabled
    #                if [ $PRINT_CSV_INTER_SAMPLING_STATISTICS -eq 1 ]; then
    #                    [ $DEBUG -eq 1 ] && echo -e "\nInter-sampling statistics" >&2
    #                    #echo "${matrix_inter[$e_inter@$s_inter,time]}","${matrix_inter[$e_inter@$s_inter,mean]}",_,"${matrix_inter[$e_inter@$s_inter,name]}",_,_,"${matrix_inter[$e_inter@$s_inter,stdpct]}","${matrix_inter[$e_inter@$s_inter,min]}","${matrix_inter[$e_inter@$s_inter,max]}","${matrix_inter[$e_inter@$s_inter,poc]}","${matrix_inter[$e_inter@$s_inter"_poc",mean]}","${matrix_inter[$e_inter@$s_inter"_poc",stdpct]}","${matrix_inter[$e_inter@$s_inter"_poc",min]}","${matrix_inter[$e_inter@$s_inter"_poc",max]}"
    #                    echo $file,$freq,$cores,"${matrix_inter[$e_inter@$s_inter,time]}","${matrix_inter[$e_inter@$s_inter,name]}","${matrix_inter[$e_inter@$s_inter,mean]}","${matrix_inter[$e_inter@$s_inter,stdpct]}","${matrix_inter[$e_inter@$s_inter,min]}","${matrix_inter[$e_inter@$s_inter,max]}","${matrix_inter[$e_inter@$s_inter"_poc",mean]}","${matrix_inter[$e_inter@$s_inter"_poc",stdpct]}","${matrix_inter[$e_inter@$s_inter"_poc",min]}","${matrix_inter[$e_inter@$s_inter"_poc",max]}"
    #                fi
    #            fi
    #        done
    #    done
    #done

    #Print inter sampling statistics - perf CSV style - if enabled
    if PRINT_CSV_INTER_SAMPLING_STATISTICS==1:
        if DEBUG==1:
            eprint("\nInter-sampling statistics")

        tuple_name_mean=""
        tuple_name_stdpct=""
        tuple_name_min=""
        tuple_name_max=""
        for ek, ev in events_array.items():
            tuple_name_mean=tuple_name_mean+","+ev+"@mean"
            tuple_name_stdpct=tuple_name_stdpct+","+ev+"@std"
            tuple_name_min=tuple_name_min+","+ev+"@min"
            tuple_name_max=tuple_name_max+","+ev+"@max"

        print("file,freq,cores,sampling_instant{},poc@min{},poc@max{},poc@std{},poc@mean".format(tuple_name_min,tuple_name_max,tuple_name_stdpct,tuple_name_mean))
        

        #print(sampling_counter)
        #print(max_sampling_counter)
        
        for s in range(1,int(max_sampling_counter)+1):
            name=""
            time=""
            mean=""
            stdpct=""
            min=""
            max=""
            poc_mean=""
            poc_stdpct=""
            poc_min=""
            poc_max=""
            tuple_mean=""
            tuple_stdpct=""
            tuple_min=""
            tuple_max=""
            #print (events_array)
            

            for ek, ev in events_array.items():
                notfound=True
                for rk, rv in matrix_inter.items():
                    #print (rk,rv)
                    #print(".*event@"+ev+"@"+str(s)+"@.*",rk, rv)
                    if re.match(".*event@"+ev+"@"+str(s)+"@.*", str(rv)):
                        notfound=False
                        rv_split=rv.split("@")
                        e_inter=rv_split[1]
                        s_inter=rv_split[2]
                        r_inter=rv_split[3]
                        n_inter=matrix_inter[e_inter+"@"+s_inter+",n"]

                        name=matrix_inter[e_inter+"@"+s_inter+",name"]
                        time=matrix_inter[e_inter+"@"+s_inter+",time"]
                        mean=matrix_inter[e_inter+"@"+s_inter+",mean"]
                        stdpct=matrix_inter[e_inter+"@"+s_inter+",stdpct"]
                        min=matrix_inter[e_inter+"@"+s_inter+",min"]
                        max=matrix_inter[e_inter+"@"+s_inter+",max"]

                        poc_mean=matrix_inter[e_inter+"@"+s_inter+"_poc,mean"]
                        poc_stdpct=str(round(matrix_inter[e_inter+"@"+s_inter+"_poc,stdpct"],2))
                        poc_min=matrix_inter[e_inter+"@"+s_inter+"_poc,min"]
                        poc_max=matrix_inter[e_inter+"@"+s_inter+"_poc,max"]

                        tuple_mean=tuple_mean+","+str(mean)
                        tuple_stdpct=tuple_stdpct+","+str(round(stdpct,2))
                        tuple_min=tuple_min+","+str(min)
                        tuple_max=tuple_max+","+str(max)
                if notfound:
                        tuple_mean=tuple_mean+","
                        tuple_stdpct=tuple_stdpct+","
                        tuple_min=tuple_min+","
                        tuple_max=tuple_max+","

            print("{},{},{},{}{},{}{},{}{},{}{},{}".format(filename,freq,cores,s,tuple_min,poc_min,tuple_max,poc_max,tuple_stdpct,poc_stdpct,tuple_mean,poc_mean))
            #echo $file,$freq,$cores,$s""$tuple_min,$poc_min""$tuple_max,$poc_max""$tuple_stdpct,$poc_stdpct""$tuple_mean,$poc_mean



# Function to print statistics related to one sampling period. Output in in human readable (commented out) and CSV.
# It iterates through the associative matrix of parsed events, calculating the statistics and printing at end.

def printIntraSamplingStatistics():
    #print "printIntraSamplingStatistics"

    #for r in "${matrix[@]}"; do
    for kmintra, vmintra in matrix.items():
        if re.match('.*event@.*', str(vmintra)):
            #print("batata",k,v)
            vmintra_split=vmintra.split("@")
            e_intra=vmintra_split[1]
            s_intra=vmintra_split[2]
            n_intra=vmintra_split[3]
            if int(n_intra) > 0:
                matrix[e_intra+",mean"]=float(matrix[e_intra+",sum"])/float(n_intra)
            
            # Standard Deviation (std)
            # std - 1) Sum of the squared differences in relation to the mean
            for s in range(1, int(n_intra)+1):
                #echo "$e""[$s]" -- "${matrix[$e,$s]}"
                matrix[e_intra+",d2"] = float(matrix[e_intra+",d2"]) + ((float(matrix[e_intra+","+str(s)]) - float(matrix[e_intra+",mean"]))**2)

            # std - 2) Final result of Standard Deviation (absolute)
            if matrix[e_intra+",d2"] > 0:
                matrix[e_intra+",std"]=math.sqrt(matrix[e_intra+",d2"] / (float(n_intra) - 1))

            # std - 3) Final result of Standard Deviation (percentual - more useful)
            if matrix[e_intra+",mean"] != 0:
                matrix[e_intra+",stdpct"]=matrix[e_intra+",std"] * 100 / matrix[e_intra+",mean"]
                
            #Human readable output
            if DEBUG==1:
                eprint(e_intra+"[name] -- "  +str(matrix[e_intra+",name"]))
                eprint(e_intra+"[time] -- "  +str(matrix[e_intra+",time"]))
                eprint(e_intra+"[poc] -- "   +str(matrix[e_intra+",poc"]))
                eprint(e_intra+"[max] -- "   +str(matrix[e_intra+",max"]))
                eprint(e_intra+"[min] -- "   +str(matrix[e_intra+",min"]))
                eprint(e_intra+"[sum] -- "   +str(matrix[e_intra+",sum"]))
                eprint(e_intra+"[mean] -- "  +str(matrix[e_intra+",mean"]))
                eprint(e_intra+"[d2] -- "    +str(matrix[e_intra+",d2"]))
                eprint(e_intra+"[std] -- "   +str(matrix[e_intra+",std"]))
                eprint(e_intra+"[stdpct] -- "+str(matrix[e_intra+",stdpct"]))

            #Print intra sampling statistics - perf CSV style - if enabled
            if PRINT_CSV_INTRA_SAMPLING_STATISTICS==1:
                if DEBUG==1:
                    print("\nIntra-sampling statistics")
                print(str(matrix[e_intra+",time"])+","+str(matrix[e_intra+",mean"])+",_,"+str(matrix[e_intra+",name"])+",_,_,"+str(matrix[e_intra+",stdpct"])+","+str(matrix[e_intra+",min"])+","+str(matrix[e_intra+",max"])+","+str(matrix[e_intra+",poc"]))

            
            
            if PRINT_CSV_INTER_SAMPLING_STATISTICS==1:
                eventvalue=matrix[e_intra+",mean"]
                eventpoc=matrix[e_intra+",poc"]

                # Detects if the event 'e' at instant 't' is new in the matrix_inter
                # If not, add it the the associative matrix_inter in the next index
                newevent=1
                for kminter, vminter in matrix_inter.items():
                    #print(kminter,vminter)
                    if re.match(".*event@"+e_intra+"@"+str(sampling_counter)+"@.*", str(vminter)):
                        vminter_split=vminter.split("@")
                        e_inter=vminter_split[1]
                        s_inter=vminter_split[2]
                        n_inter=int(vminter_split[4])
                        #k_split=k.split("@")
                        #e_inter=k_split[1]
                        #s_inter=k_split[2]
                        #n_inter=k_split[4]
                        n_inter+=1
                        
                        if DEBUG==1:
                            eprint("Old event in matrix_inter: current_run:{} accumulated_samples:{} time:{} value:{} event:{}@{}".format(run_counter,n_inter,matrix[e_intra+",time"],eventvalue, e_inter,s_inter))
                        matrix_inter[e_intra+"@"+str(sampling_counter)+",name"]="event@"+str(e_intra)+"@"+str(sampling_counter)+"@x@"+str(n_inter)
                        matrix_inter[e_intra+"@"+str(sampling_counter)+",run_"+str(run_counter)]=eventvalue
                        matrix_inter[e_intra+"@"+str(sampling_counter)+",poc_"+str(run_counter)]=eventpoc
                        matrix_inter[e_intra+"@"+str(sampling_counter)+",n"]=n_inter
                        matrix_inter[e_intra+"@"+str(sampling_counter)+","+str(n_inter)]=eventvalue
                        matrix_inter[e_intra+"@"+str(sampling_counter)+"_poc,"+str(n_inter)]=eventpoc

                        if (eventvalue > matrix_inter[e_intra+"@"+str(sampling_counter)+",max"]):
                            matrix_inter[e_intra+"@"+str(sampling_counter)+",max"]=eventvalue

                        if (eventvalue < matrix_inter[e_intra+"@"+str(sampling_counter)+",min"]):
                            matrix_inter[e_intra+"@"+str(sampling_counter)+",min"]=eventvalue

                        matrix_inter[e_intra+"@"+str(sampling_counter)+",sum"]+=eventvalue


                        if eventpoc > matrix_inter[e_intra+"@"+str(sampling_counter)+"_poc,max"]:
                            matrix_inter[e_intra+"@"+str(sampling_counter)+"_poc,max"]=eventpoc
                            
                        if eventpoc < matrix_inter[e_intra+"@"+str(sampling_counter)+"_poc,min"]:
                            matrix_inter[e_intra+"@"+str(sampling_counter)+"_poc,min"]=eventpoc                            

                        matrix_inter[e_intra+"@"+str(sampling_counter)+"_poc,sum"]+=eventpoc

                        newevent=0
                        break

                # If the line represents a new event in the period, creates a
                # new marker in the associative matrix
                if newevent==1:
                    if DEBUG==1:
                        eprint("New event in matrix_inter: current_run:{} accumulated_samples:1 time:{} value:{} event:{}@{}".format(run_counter,matrix[e_intra+",time"], eventvalue, e_intra, sampling_counter))
                    matrix_inter[e_intra+"@"+str(sampling_counter)+",name"]="event@"+e_intra+"@"+str(sampling_counter)+"@x@1"
                    matrix_inter[e_intra+"@"+str(sampling_counter)+",run_$run_counter"]=eventvalue
                    matrix_inter[e_intra+"@"+str(sampling_counter)+",n"]=1
                    matrix_inter[e_intra+"@"+str(sampling_counter)+",1"]=eventvalue
                    matrix_inter[e_intra+"@"+str(sampling_counter)+",time"]=matrix[e_intra+",time"]    #TO-DO: mean_time
                    matrix_inter[e_intra+"@"+str(sampling_counter)+",poc"]=matrix[e_intra+",poc"]
                    matrix_inter[e_intra+"@"+str(sampling_counter)+",min"]=eventvalue
                    matrix_inter[e_intra+"@"+str(sampling_counter)+",max"]=eventvalue
                    matrix_inter[e_intra+"@"+str(sampling_counter)+",sum"]=eventvalue
                    matrix_inter[e_intra+"@"+str(sampling_counter)+",mean"]=eventvalue
                    matrix_inter[e_intra+"@"+str(sampling_counter)+",d2"]=0
                    matrix_inter[e_intra+"@"+str(sampling_counter)+",std"]=0
                    matrix_inter[e_intra+"@"+str(sampling_counter)+",stdpct"]=0

                    matrix_inter[e_intra+"@"+str(sampling_counter)+"_poc,1"]=eventpoc
                    matrix_inter[e_intra+"@"+str(sampling_counter)+"_poc,min"]=eventpoc
                    matrix_inter[e_intra+"@"+str(sampling_counter)+"_poc,max"]=eventpoc
                    matrix_inter[e_intra+"@"+str(sampling_counter)+"_poc,sum"]=eventpoc
                    matrix_inter[e_intra+"@"+str(sampling_counter)+"_poc,mean"]=eventpoc
                    matrix_inter[e_intra+"@"+str(sampling_counter)+"_poc,d2"]=0
                    matrix_inter[e_intra+"@"+str(sampling_counter)+"_poc,std"]=0
                    matrix_inter[e_intra+"@"+str(sampling_counter)+"_poc,stdpct"]=0

    return

    for e in events_array:
        for s in range(1,max_sampling_counter+1):
            for k, v in matrix.items():

            #for r in "${matrix[@]}"; do
                if re.match(".*event@"+e+"@"+str(s)+"@.*", k):
                    k_split=k.split("@")
                    e_inter=k_split[1]
                    s_inter=k_split[2]
                    r_inter=k_split[4]
                    n_inter=matrix_inter[e_inter+"@"+str(s_inter)+",n"]

                    #Print intra sampling statistics - perf CSV style - if enabled
                    if PRINT_CSV_INTER_SAMPLING_STATISTICS==1:
                        if DEBUG==1:
                            eprint("\nInter-sampling statistics")
                        print (matrix_inter[e_inter+"@"+s_inter+",time"]+","+matrix_inter[e_inter+"@"+s_inter+",mean"]+",_,"+matrix_inter[e_inter+"@"+s_inter+",name"]+",_,_,"+matrix_inter[e_inter+"@"+s_inter+",stdpct"]+","+matrix_inter[e_inter+"@"+s_inter+",min"]+","+matrix_inter[e_inter+"@"+s_inter+",max"]+","+matrix_inter[e_inter+"@"+s_inter+",poc"])





parser = argparse.ArgumentParser()
parser.add_argument("-v", "--verbosity", action="count", default=0)
parser.add_argument('input_file', nargs='+', help="list of files to process")

# To show the results of the given option to screen.
#for _, value in parser.parse_args()._get_kwargs():
#    if value is not None:
#        print(value)



args = parser.parse_args()
#answer = args.x**args.y
if args.verbosity >= 2:
    print ("Running '{}'".format(__file__))
if args.verbosity >= 1:
    print ("Running '{}'".format(__file__))
#    print "{}^{} ==".format(args.x, args.y),
#print answer

for i in args.input_file:
    #echo -e "\nInput: $i\n">&2
    eprint ("\nInput: {}\n".format(i))

    fullfilename_list=ntpath.basename(i).split("_")
    
    #prefix=$(echo $fullfilename|cut -d '_' -f 1-4);
    prefix='_'.join(fullfilename_list[0:4])
    filename='_'.join(fullfilename_list[4:8])
    freq=fullfilename_list[8]
    cores=fullfilename_list[9]
    runs=fullfilename_list[10]
    sufix='_'.join(fullfilename_list[11:])
    
    #print(prefix)
    #print(filename)
    #print(freq)
    #print(cores)
    #print(runs)
    #print(sufix)
    
    
    #unset matrix_inter
    #declare -A matrix_inter
    matrix_inter = {}
    
    POC=0
    TOTAL_POC=0
    t=float(0)
    key=""
    keys=""
    value=""
    TotalCpuTime=0
    EncodingTime=0
    EncodingWallTime=0
    EncodingCpuUsage=0
    Fps=0
    BeginNextSamplePeriod=2

    
    
    #OIFS="$IFS"
    #IFS=$'\n'

    inputfile=open(i, 'r')
    stats=inputfile.readlines()
    inputfile.close()
    
    stats.append("____\n")
    
    #f2 = open('output.stat.python.csv', 'w')
    
    for line in stats:
        #j =  re.match("s/^ *//;/\(^\)\(.\+\)\(POC.*$\)/N;s/\n/€/;s/\(^\)\(.\+\)\(POC.*\)\(€\)\(.*\)\($\)/\1\3\n\2\5/;s/owf/\n@@@@\n/;$s/$/\n@@@@\n____\n>/", line)
        #j =  re.match("s/owf/\n@@@@\n/", line)
        j = line.strip().replace("RES:","@@@@")
        #print(j)
        if re.match(".*@@@@.*", j) or re.match(".*____.*", j) or re.match("^POC.*", j):
            if BeginNextSamplePeriod==0:
                printIntraSamplingStatistics()
                TOTAL_POC+=POC
                POC=0
                #unset matrix
                #declare -A matrix
                matrix={}
                BeginNextSamplePeriod=1;

            
            #Counts transcoded frames
            if re.match("^POC.*", j):
                POC+=1
                if PRINT_TXT_POC_LINE_COUNTING==1:
                    eprint("POC: {}".format(POC))
                continue
            

            if re.match(".*@@@@.*", j):
                if PRINT_TXT_POC_LINE_COUNTING==1:
                    eprint ("TOTAL POC: {}".format(TOTAL_POC))
                if PRINT_CSV_SAMPLED_POC==1:
                    eprint("{},{},,TOTAL_POC".format(t,TOTAL_POC))
                if max_sampling_counter < sampling_counter:
                    max_sampling_counter=sampling_counter
                #sampling_counter=0
                run_counter+=1
                #TOTAL_POC=0
                continue


            ## CSV output of Kvazaar stats 
            #if [[ $j =~ .*@@@@.* ]]; then
            #    [ $DEBUG -eq 1 ] && \
            #        echo sampling_counter $sampling_counter &&
            #        echo run_counter $run_counter
            #    printIntraSamplingStatistics
            #    if [ $PRINT_CSV_KVAZAAR_PER_RUN_STATISTICS -eq 1 ] && [[ ! -z "${key// }" ]]; then
            #        [ $DEBUG -eq 1 ] && echo KvazaarStats
            #        echo $t,$TotalCpuTime,,TotalCpuTime
            #        echo $t,$EncodingTime,,EncodingTime
            #        echo $t,$EncodingWallTime,,EncodingWallTime
            #        echo $t,$EncodingCpuUsage,,EncodingCpuUsage
            #        echo $t,$Fps,,Fps
            #    fi
            #    [ $DEBUG -eq 1 ] && echo -e "\nNew RUN"
            #    sampling_counter=0
            #    POC=0
            #    run_counter=$(($run_counter+1))
            #    BeginNextSamplePeriod=1;
            #    unset matrix
            #    declare -A matrix
            #fi
            #continue

            if re.match(".*____.*", j):
                if max_sampling_counter < sampling_counter:
                    max_sampling_counter=sampling_counter
                if PRINT_CSV_INTER_SAMPLING_STATISTICS==1:
                    printInterSamplingStatistics()
                continue

        # Parses perf CSV outputs, registering also the total amount of frames since last sampling period
        if re.match("^\ *.*\,\,.*", j):
            j_split=j.split(",") 
            new_t=float(j_split[0])
            eventname=j_split[3]
            eventvalue=j_split[1]
            events_array[eventname]=eventname

            #New sampling period
            if t != new_t: 
                if DEBUG==1:
                    eprint("t: {} new_t: {}".format(t,new_t))
                    eprint("New perf sampling period")

                if BeginNextSamplePeriod==0:
                    printIntraSamplingStatistics()
                    TOTAL_POC+=POC
                    POC=0
                    #unset matrix
                    #declare -A matrix
                    matrix={}
                elif PRINT_CSV_SAMPLED_POC==1:
                    eprint("{},{},,POC".format(new_t,POC))

                if t > new_t:
                    sampling_counter=0
                    #run_counter=$(($run_counter+1))    
                    TOTAL_POC=0
                
                t=new_t
                sampling_counter+=1
                
                #echo ,, $POC
                #POC=0
                BeginNextSamplePeriod=0;


            # Ignores input lines with <not counted> and displays a warning message in stderr
            if re.match(".*not\ counted.*", j):
                #eprint("Ignoring line in input: {}".format(j))
                continue

            #Print perf input lines, if enabled
            if(PRINT_CSV_PERF_INPUT_LINES==1):
                eprint(j)

            # Detects if the line represents a new event in the period
            # If not, add it the the associative matrix in the next index
            newevent=1
            #for r in "${matrix[@]}"; do
            for k, v in matrix.items():
                if re.match(".*event@$eventname@$sampling_counter.*", k):
                    k_split=k.split("@")
                    e_intra=k_split[1]
                    s_intra=k_split[2]
                    n_intra=k_split[3]
                    #echo N=$n_intra
                    n_intra+=1
                    if DEBUG==1:
                        print ("Old event:{}:{}:{} value:{}".format(e_intra,s_intra,n_intra,eventvalue))
                    matrix[e_intra+",name"]="event@"+e_intra+"@"+s_intra+"@"+n_intra
                    matrix[e_intra+","+n_intra]=eventvalue

                    if eventvalue > matrix[e_intra+",max"]:
                        matrix[e_intra+",max"]=eventvalue
                        
                    if eventvalue < matrix[e_intra+",min"]:
                        matrix[e_intra+",min"]=eventvalue


                    matrix[e_intra+",sum"]+=eventvalue
                    newevent=0
                    break

            # If the line represents a new event in the period, creates a
            # new marker in the associative matrix
            if newevent==1:
                if DEBUG==1:
                    eprint("New event:{} n:1 value:{} POC:{}".format(eventname,eventvalue,POC))
                #events_array[eventname]=eventname

                matrix[eventname+",name"]="event@"+eventname+"@"+str(sampling_counter)+"@1"
                matrix[eventname+",time"]=t
                matrix[eventname+",poc"]=POC
                matrix[eventname+",min"]=eventvalue
                matrix[eventname+",max"]=eventvalue
                matrix[eventname+",sum"]=eventvalue
                matrix[eventname+",mean"]=eventvalue
                matrix[eventname+",d2"]=0
                matrix[eventname+",std"]=0
                matrix[eventname+",stdpct"]=0
                matrix[eventname+",1"]=eventvalue

            continue

        # Parsing of Kvazaar stats
       
        if ("Total CPU time" in j) or ("Encoding time" in j) or ("Encoding wall time" in j) or ("Encoding CPU usage" in j) or ("FPS" in j):
            keys=str(re.match("s/^[ \t]*\(.*\):.*/\1/", j))
            value=re.match("s/[^0-9. ]//g", j)
            #value=re.match("s/ \+/ /g", value)
            #value=re.match"s/ .$//g", value) 
            #tr -s ' '| tr -d '[:blank:]')
            key=""
            if keys in "Total CPU time":
                    key="TotalCpuTime"
                    TotalCpuTime=value
            elif keys in "Encoding time":
                    key="EncodingTime"
                    EncodingTime=value
            elif keys in "Encoding wall time":
                    key="EncodingWallTime"
                    EncodingWallTime=value
            elif keys in "Encoding CPU usage":
                    key="EncodingCpuUsage"
                    EncodingCpuUsage=value
            elif keys in "FPS":
                    key="Fps"
                    Fps=value
            continue
exit

    

        
        
    
    #f1 = open('input.stat', 'r')
    #f2 = open('output.stat.python.csv', 'w')
    
    #s= ""
    #for line in f1:
    #    s+=line
    #    f2.write(line.rstrip() + '\n')
    #f1.close()
    #f2.close()
    
    
    #f2 = open('c:\\temp\\launchconfig2.txt', 'r')
    #s2= ""
    #for line in f2:
    #    s2+=line
    #f2.close()
    #list1 = s.split(",")
    #list2 = s2.split(",");
    #print(len(list1))
    #print(len(list2))
        
    
    #difference = list(set(list1).difference(set(list2)))
    
    #print (s)
