FROM px4io/px4-dev-simulation-bionic:2020-01-29

ENV WORKSPACE_DIR /root
ENV FIRMWARE_DIR ${WORKSPACE_DIR}/Firmware
ENV SITL_RTSP_PROXY ${WORKSPACE_DIR}/sitl_rtsp_proxy

WORKDIR /root

RUN \
  apt-get update && \
  apt-get -y install libgl1-mesa-glx \
                     libgl1-mesa-dri \
                     libgstrtspserver-1.0-dev \
                     gstreamer1.0-libav \
                     xvfb && \
  apt-get -y autoremove python2.7 && \
  rm -rf /var/lib/apt/lists/*

RUN pip3 install packaging

COPY Firmware Firmware
COPY .git .git
COPY custom_model/sitl_gazebo/models/solo_cam Firmware/Tools/sitl_gazebo/models/solo_cam
COPY custom_model/ROMFS/px4fmu_common/init.d-posix Firmware/ROMFS/px4fmu_common/init.d-posix/
RUN sed -i 's/solo/& solo_cam/' Firmware/platforms/posix/cmake/sitl_target.cmake
RUN sed -i 's/empty/& drone_race_track_2018_actual/' Firmware/platforms/posix/cmake/sitl_target.cmake
COPY gazebo_models/world/drone* Firmware/Tools/sitl_gazebo/worlds/
COPY gazebo_models/models Firmware/Tools/sitl_gazebo/models/

COPY edit_rcS.bash ${WORKSPACE_DIR}
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
RUN ["/bin/bash", "-c", " \
    cd ${FIRMWARE_DIR} && \
    DONT_RUN=1 make px4_sitl gazebo_solo_cam__drone_race_track_2018_actual && \
    DONT_RUN=1 make px4_sitl gazebo_solo_cam__drone_race_track_2018_actual \
"]

COPY sitl_rtsp_proxy ${SITL_RTSP_PROXY}
RUN cmake -B${SITL_RTSP_PROXY}/build -H${SITL_RTSP_PROXY}
RUN cmake --build ${SITL_RTSP_PROXY}/build

ENTRYPOINT ["/root/entrypoint.sh"]
