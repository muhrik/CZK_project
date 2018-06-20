#PARAMETERS
#$1 t(s) the timeout
#$2 lambda according to t in {regular,median} regular mean lambda = 1/t, and median means t will be the median value of exp(lambda)
#$3 the engine in {event,explicit,hybrid,storm}
#compute steady state probabilities for various k values.
#This script must remain in CZK_project/Script !!!
#There is only one parameter - floating point number specifying the timeout.
#Lambda is derived as (ln 2 / timeout).



#check parameter
reNum='^[-+]?[0-9]+\.?[0-9]*$'
if ! [[ $1 =~ $reNum ]]; then
  echo "Please specify number \"timeout\" as the first parameter!"
  exit 1
fi

if [ -z "$2" ]
  then
    echo "kind of lambda not supplied, choose in {regular,median}"
    exit 1
fi

if [ -z "$3" ]
  then
    echo "engine not supplied, choose in {event,explicit,hybrid}"
    exit 1
fi

#Constant computation
engine="$3"


PRISM_PATH_FROM_OUTPUT="../../../../prism-gsmp/prism/bin"
CLASSIC_PRISM_PATH_FROM_OUTPUT="../../../../prism-4.4-src/bin"
MODEL_PATH_FROM_PRISM="../../../CZK_project/Model"
MODEL_PATH_FROM_CLASSIC_PRISM="../../CZK_project/Model"
OUTPUT_PATH_FROM_PRISM="../../../CZK_project/Output"
OUTPUT_PATH_FROM_CLASSIC_PRISM="../../CZK_project/Output"

sequence=$(seq 1 1 9; seq 10 10 90; seq 100 100 900; seq 1000 1000 4000; seq 5000 5000 50000);
#~ sequence=$(seq 900000 100000 900000; seq 1000000 1000000 10000000);

#lambda and path setting
ln_2="0.6931471805599453094" #20 digits
if [ "$2" == "regular" ]; then
	lambda=$(echo "scale=20;1/$1" | bc)
	path="t=$1_regular_standart"
else
	lambda=$(echo "scale=20;${ln_2}/$1" | bc)
	path="t=$1_median_standart"
fi
echo lambda = $lambda
echo path = $path


#changing directory
cd '../Output'

mkdir $path
cd $path
if [ $engine == "event" ]; then
	mkdir "explicit"
	cd "explicit"
else
	mkdir $engine
	cd $engine
fi




#STARTING COMPUTATION


if [ $engine == "event" ]; then
	cd $PRISM_PATH_FROM_OUTPUT
	echo engine epsilon_computation
	#compute explicit event
	echo event $eps
	./prism -explicit -epsilon ${eps_precise} -maxiters 100000000 -power -absolute -const timeout=$1,lambda=$lambda "$MODEL_PATH_FROM_PRISM/timeoutqueue.sm" -ss -exportss "$OUTPUT_PATH_FROM_PRISM/${path}/explicit/ev_10_k_${eps_precise}" > "$OUTPUT_PATH_FROM_PRISM/${path}/explicit/ev_10_k_${eps_precise}.log"
	echo event $eps_precise
	./prism -explicit -epsilon ${eps} -maxiters 100000000 -power -absolute -const timeout=$1,lambda=$lambda "$MODEL_PATH_FROM_PRISM/timeoutqueue.sm" -ss -exportss "$OUTPUT_PATH_FROM_PRISM/${path}/explicit/ev_10_k_${eps}" > "$OUTPUT_PATH_FROM_PRISM/${path}/explicit/ev_10_k_${eps}.log"
	cd -
	
elif [ $engine == "explicit" ]; then
	cd $PRISM_PATH_FROM_OUTPUT
	echo engine k     epsilon_computation epsilon 
	for k in $sequence
		do
			echo explicit $k standart_epsilon 
			./prism -explicit -maxiters 100000000 -power -absolute -const k=$k,timeout=$1,lambda=$lambda "$MODEL_PATH_FROM_PRISM/queue_withptf_gsmp.sm" -ss -exportss "$OUTPUT_PATH_FROM_PRISM/${path}/${engine}/ph_10_${k}_standart" > "$OUTPUT_PATH_FROM_PRISM/${path}/${engine}/ph_10_${k}_standart.log"
		done
	cd -
	#write a readme file for explicit computations
	touch readme.txt
	echo "t=$1" >> readme.txt
	echo "lambda=$lambda" >> readme.txt
	echo "n=10" >> readme.txt
	echo "naming: ev/ph_n_k_epsilon" >> readme.txt
	echo "steady state distributions using the GSMP (ctmc with phase type) explicit engine
	for termination epsilon 1.0E-5 for phase type, and termination epsilon 1.0E-8 and 1.0E-6 for event. 
	For each computation a full log file is also created with the extention .log" >> readme.txt

			
elif [ $engine == "hybrid" ]; then
	#~ cd $PRISM_PATH_FROM_OUTPUT
	cd $CLASSIC_PRISM_PATH_FROM_OUTPUT
	echo engine k     epsilon_computation epsilon 
	#compute hybrid phase type
	for k in $sequence;
	do
		echo hybrid $k standart epsilon
		./prism -hybrid -maxiters 100000000 -power -absolute -const k=$k,timeout=$1,lambda=$lambda "$MODEL_PATH_FROM_CLASSIC_PRISM/queue_withptf_ctmc.sm" -ss -exportss "$OUTPUT_PATH_FROM_CLASSIC_PRISM/${path}/${engine}/ph_10_${k}_standart" > "$OUTPUT_PATH_FROM_CLASSIC_PRISM/${path}/${engine}/ph_10_${k}_standart.log"
	done
	cd -
	#write a readme file for hybrid computations
	touch readme.txt
	echo "t=$1" >> readme.txt
	echo "lambda=ln(2)/timeout" >> readme.txt
	echo "n=10" >> readme.txt
	echo "naming: ph_n_k_epsilon" >> readme.txt
	echo "steady state distributions using the CTMC with phase type on hybrid engine with Power method
	absolute termination criteria for termination epsilon 1.0E-5 for phase type." >> readme.txt


elif [ $engine == "storm" ]; then
	#~ cd $PRISM_PATH_FROM_OUTPUT
	cd $CLASSIC_PRISM_PATH_FROM_OUTPUT
	echo engine k     epsilon_computation epsilon 
	#compute hybrid phase type
	for k in $sequence;
		do
			echo storm $k standart_epsilon
			storm --prism "$MODEL_PATH_FROM_CLASSIC_PRISM/queue_withptf_ctmc.sm" --prop "$MODEL_PATH_FROM_CLASSIC_PRISM/storm_prop.csl" -e sparse -pc --constants k="$k",timeout="$1",lambda="$lambda" > "$OUTPUT_PATH_FROM_CLASSIC_PRISM/${path}/${engine}/ph_10_${k}_standart.log"
	done
	cd -
	#write a readme file for hybrid computations
	touch readme.txt
	echo "t=$1" >> readme.txt
	echo "lambda=ln(2)/timeout" >> readme.txt
	echo "n=10" >> readme.txt
	echo "naming: ph_n_k_epsilon" >> readme.txt
	echo "steady state distributions using the CTMC with phase type on hybrid engine with Power method
	absolute termination criteria for termination epsilon 1.0E-5 for phase type." >> readme.txt


fi







