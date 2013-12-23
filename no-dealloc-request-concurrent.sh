#! /bin/bash
cd $HOME/hhvm/hphp/test
mkdir $HOME/ResultsConc/
rm ./www.pid
killall hhvm valgrind massif-amd64-li
echo "Test Date: "$(date) >> $Home/ResultsConc/results


for hhvm_build in hhvm hhvmclean
do
	if [ "$1" == "--USE_VALGRIND" ]; then
		valgrind --tool=massif --massif-out-file=$HOME/ResultsConc/$hhvm_build $HOME/$hhvm_build/hphp/hhvm/hhvm -m s -p 8080 &
		echo "waiting for valgrind/hhvm to start" && sleep 20
	else
		$HOME/$hhvm_build/hphp/hhvm/hhvm -m s -p 8080  &
		echo "waiting for hhvm to start" && sleep 5
	fi
	echo $hhvm_build" center-of-mass test:" >> $HOME/ResultsConc/results
	echo "initial request:"
	/usr/bin/time --output $HOME/ResultsConc/results --append --format %e  wget --timeout=0 127.0.0.1:8080/vm-perf/center-of-mass.php
	T="$(date +%s)"
	INSTANCES=0
	for i in {1..16}
	do
		echo "run: "$i
		/usr/bin/time --output $HOME/ResultsConc/results --append --format %e wget --timeout=0 127.0.0.1:8080/vm-perf/center-of-mass.php &
		sleep 1
	done
	jobs
	wait %2 %3 %4 %5 %6 %7 %8 %9 %10 %11 %12 %13 %14 %15 %16 %17
	T="$(($(date +%s)-T))"
	echo "total time: "$T >> $HOME/ResultsConc/results
		if [ "$1" == "--USE_VALGRIND" ]; then
		/bin/kill -s SIGINT $(pidof valgrind)
		echo "waiting to stop valgrind" && sleep 20
	else
		killall hhvm
		echo "waiting to stop hhvm" && sleep 5
	fi
done
