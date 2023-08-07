#!/bin/bash

function spawn_model() {
        #robot model: "iris", "plane", "standard_vtol", "rover", "r1_rover", "typhoon_h480"
	MODEL="iris"

        #spawn position
	X=0
	Y=0
        Z=0.83

	set -- ${@} ${GAZEBO_CLASSIC}/scripts/jinja_gen.py
	set -- ${@} ${GAZEBO_CLASSIC}/models/${MODEL}/${MODEL}.sdf.jinja
	set -- ${@} ${GAZEBO_CLASSIC}/
        set -- ${@} --mavlink_tcp_port 4560 
	set -- ${@} --output-file /tmp/${MODEL}.sdf

	python3 ${@}

	echo "Spawning ${MODEL} at (${X}, ${Y})"

	gz model --spawn-file=/tmp/${MODEL}.sdf --model-name=${MODEL} -x ${X} -y ${Y} -z ${Z}
}

function cleanup() {
	pkill gzclient
	pkill gzserver
}

world=empty.world

GAZEBO_CLASSIC=${PWD}/PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_gazebo-classic
GAZEBO_BUILD=${PWD}/PX4-Autopilot/build/px4_sitl_default/build_gazebo-classic

export GAZEBO_PLUGIN_PATH=${GAZEBO_PLUGIN_PATH}:${GAZEBO_BUILD}
export GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH}:${GAZEBO_CLASSIC}/models
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${GAZEBO_CLASSIC}

echo -e "GAZEBO_PLUGIN_PATH ${GAZEBO_PLUGIN_PATH}"
echo -e "GAZEBO_MODEL_PATH ${GAZEBO_MODEL_PATH}"
echo -e "LD_LIBRARY_PATH ${LD_LIBRARY_PATH}"
echo -e ""

trap "cleanup" SIGINT SIGTERM EXIT

echo "Starting gazebo server"
gzserver ${GAZEBO_CLASSIC}/worlds/${world} --verbose &
sleep 5

spawn_model

echo "Starting gazebo client"
gzclient
