# Dockerfile (Ubuntu 18.04 + ROS Melodic)
# Ubuntu 18.04 LTS (Bionic Beaver)
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    wget \
    unzip \
    libgoogle-glog-dev \
    libatlas-base-dev \
    libsuitesparse-dev \
    libgflags-dev \
    liblapack-dev \
    libblas-dev \
    pkg-config \
    dirmngr \
    gnupg \
    lsb-release \
    ca-certificates \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------------
# ROS Melodic (ROS1)
# ----------------------------------------------------------------------------
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
    apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 && \
    apt-get update && \
    apt-get install -y --no-install-recommends  \
    ros-melodic-desktop-full \
    ros-melodic-pcl-ros  \
    && \
    echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc && \
    echo "export ROS_MASTER_URI=http://localhost:11311" >> ~/.bashrc && \
    echo "export ROS_HOSTNAME=localhost" >> ~/.bashrc && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------------
# Eigen 3.3.7
# ----------------------------------------------------------------------------
RUN wget -q https://gitlab.com/libeigen/eigen/-/archive/3.3.7/eigen-3.3.7.zip -O eigen-3.3.7.zip && \
    unzip eigen-3.3.7.zip && \
    mkdir -p eigen-3.3.7/build && \
    cd eigen-3.3.7/build && \
    cmake .. && \
    make install && \
    cd / && \
    rm -rf eigen-3.3.7* eigen-3.3.7.zip

# ----------------------------------------------------------------------------
# OpenCV 3.4.14
# ----------------------------------------------------------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libv4l-dev \
    libxvidcore-dev \
    libx264-dev \
    libgtk-3-dev \
    libatlas-base-dev \
    gfortran \
    libtbb-dev \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q https://github.com/opencv/opencv/archive/3.4.14.zip -O opencv-3.4.14.zip && \
    wget -q https://github.com/opencv/opencv_contrib/archive/3.4.14.zip -O opencv_contrib-3.4.14.zip && \
    unzip opencv-3.4.14.zip && \
    unzip opencv_contrib-3.4.14.zip && \
    mkdir -p opencv-3.4.14/build && \
    cd opencv-3.4.14/build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-3.4.14/modules \
          -D BUILD_PYTHON_SUPPORT=OFF \
          -D WITH_QT=OFF \
          -D WITH_GTK=ON \
          -D WITH_CUDA=OFF \
          -D WITH_TBB=ON \
          -D BUILD_EXAMPLES=OFF \
          -D BUILD_TESTS=OFF \
          -D BUILD_PERF_TESTS=OFF \
          .. && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    cd / && \
    rm -rf opencv-3.4.14* opencv_contrib-3.4.14* opencv-3.4.14.zip opencv_contrib-3.4.14.zip

# ----------------------------------------------------------------------------
# Ceres Solver 1.14.0
# ----------------------------------------------------------------------------
RUN wget -q http://ceres-solver.org/ceres-solver-1.14.0.tar.gz -O ceres-solver-1.14.0.tar.gz && \
    tar -xzf ceres-solver-1.14.0.tar.gz && \
    mkdir -p ceres-solver-1.14.0/build && \
    cd ceres-solver-1.14.0/build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local \
             -DBUILD_SHARED_LIBS=ON \
             -DMINIGLOG=ON \
             -DCXSPARSE=OFF \
             -DOPENMP=OFF \
             -DNO_SUITESPARSE=OFF \
             -DNO_LAPACK=OFF \
             -DBUILD_EXAMPLES=OFF \
             -DBUILD_TESTING=OFF && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    cd / && \
    rm -rf ceres-solver-1.14.0* ceres-solver-1.14.0.tar.gz

# ----------------------------------------------------------------------------
# System env setting
# ----------------------------------------------------------------------------
WORKDIR /root

# ROS 환경을 자동으로 source하도록 설정
ENV SHELL=/bin/bash
CMD ["/bin/bash", "-c", "source /opt/ros/melodic/setup.bash && exec bash"]