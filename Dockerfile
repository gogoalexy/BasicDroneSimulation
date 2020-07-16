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

COPY edit_rcS.bash ${WORKSPACE_DIR}
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
RUN ["/bin/bash", "-c", " \
    cd ${FIRMWARE_DIR} && \
    DONT_RUN=1 make px4_sitl gazebo_solo_cam__sonoma_raceway && \
    DONT_RUN=1 make px4_sitl gazebo_solo_cam__sonoma_raceway \
"]

COPY sitl_rtsp_proxy ${SITL_RTSP_PROXY}
RUN cmake -B${SITL_RTSP_PROXY}/build -H${SITL_RTSP_PROXY}
RUN cmake --build ${SITL_RTSP_PROXY}/build

ENTRYPOINT ["/root/entrypoint.sh"]
