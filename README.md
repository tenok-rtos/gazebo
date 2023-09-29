# PX4 SITL Gazebo

## Build and Run

Build:

```
git clone https://github.com/Tenok-RTOS/gazebo.git
cd gazebo
git submodule update --init --recursive
cd PX4-Autopilot
make px4_sitl_default gazebo
```

Run:

```
./run_gazebo.sh
```
