#!/bin/bash

function spawn_model() {
	MODEL="iris"
	N=1
	X=0
	Y=0

	set --
	set -- ${@} $PWD/PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_gazebo-classic/scripts/jinja_gen.py
	set -- ${@} $PWD/PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_gazebo-classic/models/${MODEL}/${MODEL}.sdf.jinja
	set -- ${@} $PWD/PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_gazebo-classic 
	set -- ${@} --mavlink_tcp_port 4560 
	set -- ${@} --output-file /tmp/${MODEL}.sdf

	python3 ${@}

	echo "Spawning ${MODEL}_${N} at (${X}, ${Y})"

	gz model --spawn-file=/tmp/${MODEL}.sdf --model-name=${MODEL} -x ${X} -y ${Y} -z 0.83
}

function cleanup() {
	pkill gzclient
	pkill gzserver
}

world=empty

export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:$PWD/PX4-Autopilot/build/px4_sitl_default/build_gazebo-classic
export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$PWD/PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_gazebo-classic/models
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/PX4-Autopilot/build/px4_sitl_default/build_gazebo-classic

echo -e "GAZEBO_PLUGIN_PATH $GAZEBO_PLUGIN_PATH"
echo -e "GAZEBO_MODEL_PATH $GAZEBO_MODEL_PATH"
echo -e "LD_LIBRARY_PATH $LD_LIBRARY_PATH"
echo -e ""

trap "cleanup" SIGINT SIGTERM EXIT

echo "Starting gazebo server"
gzserver $PWD/PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_gazebo-classic/worlds/${world}.world --verbose &
sleep 5

spawn_model

echo "Starting gazebo client"
gzclient
