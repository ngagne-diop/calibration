#!/bin/zsh

# Author: Moez Kilani
# Project: MURDASP
# Date: April 2021
# Last edited: June 2021

#OAR -l /core=48,walltime=200:00:00
#OAR -p host="orval17"
#OAR -n Calibration10
#OAR -q murdasp

(( itmax = 9 ));
(( n = 0 )); 

JV='/usr/bin/java';
matsim='../../matsim-12.0/matsim-12.0.jar';

# Main files (configuration and output)
OutFile='calibration10_1-';
ConfBase='../configs/calibration10_1-';
InitConf=$ConfBase'0.xml'; 
OutBase='/workdir/lem/mkilani/'$OutFile;
tmp_config='cal10_1.xml';
PlanFile='output_plans.xml.gz';

# run a first simulation
$JV -Xmx96g -cp $matsim org.matsim.run.Controler $InitConf ;

#echo $JV, $matsim, $InitConf

#Main loop
for ((n=0; n<itmax; n+=1)); do

  # file where mode shares of the last iteration are available
  file_mode=$OutBase$n'/modestats.txt';
  
  old_config=$ConfBase$n'.xml';
  new_config=$ConfBase$((n+1))'.xml';
  echo "OLD CONFIG---> " $old_config ;
   
  echo $(tail -1 $file_mode) > $tmp_config;
  sed -i 's/ /"/g' $tmp_config;
  cat $old_config >> $tmp_config;
  str1=$OutFile$n;
  str2=$OutFile$((n+1));
  sed -i "s/$str1/$str2/g" $tmp_config;
  
  pln=$OutBase$n"/"$PlanFile;
  awk -F'"' -f config.awk -v plan="$pln" $tmp_config > $new_config;
  $JV -Xmx96g -cp $matsim org.matsim.run.Controler $new_config ;

done




