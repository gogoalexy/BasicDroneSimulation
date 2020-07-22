FROM gazebo:libgazebo9-bionic

ENV WORKSPACE_DIR /root
WORKDIR /root

RUN \
  apt-get update && \
  apt-get -y install libgl1-mesa-glx \
                     libgl1-mesa-dri

COPY model/* .gazebo/models/solo_cam/
COPY model/meshes/* .gazebo/models/solo_cam/meshes/
ENTRYPOINT gazebo
