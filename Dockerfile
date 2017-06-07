FROM ubuntu:16.04

MAINTAINER Kshitiz Sharma <kshitizsharma38@gmail.com>

# Install some dependencies
RUN apt-get update && apt-get install -y \
		bc \
		build-essential \
		cmake \
		curl \
		g++ \
		gfortran \
		git \
		libffi-dev \
		libfreetype6-dev \
		libhdf5-dev \
		libjpeg-dev \
		liblcms2-dev \
		libopenblas-dev \
		liblapack-dev \
		libopenjpeg-dev \
		libpng12-dev \
		libssl-dev \
		libtiff5-dev \
		libwebp-dev \
		libzmq3-dev \
		nano \
		pkg-config \
		python-dev \
		software-properties-common \
		unzip \
		vim \
		wget \
		zlib1g-dev \
		qt5-default \
		libvtk6-dev \
		zlib1g-dev \
		libjpeg-dev \
		libwebp-dev \
		libpng-dev \
		libtiff5-dev \
		libjasper-dev \
		libopenexr-dev \
		libgdal-dev \
		libdc1394-22-dev \
		libavcodec-dev \
		libavformat-dev \
		libswscale-dev \
		libtheora-dev \
		libvorbis-dev \
		libxvidcore-dev \
		libx264-dev \
		yasm \
		libopencore-amrnb-dev \
		libopencore-amrwb-dev \
		libv4l-dev \
		libxine2-dev \
		libtbb-dev \
		libeigen3-dev \
		python-dev \
		python-tk \
		python-numpy \
		python3-dev \
		python3-tk \
		python3-numpy \
		ant \
		unzip \
		rsync \
		default-jdk \
		doxygen \
		libfreetype6-dev \
		libboost-all-dev \
		libgflags-dev \
		libgoogle-glog-dev \
		libleveldb-dev \
		libhdf5-dev \
		liblmdb-dev \
		libopencv-dev \
		libprotobuf-dev \
		libsnappy-dev \
		protobuf-compiler \
		python-numpy \
		python-scipy \
		python-nose \
		python-h5py \
		python-skimage \
		python-matplotlib \
		python-pandas \
		python-sklearn \
		python-sympy \
		&& \
		apt-get clean && \
		apt-get autoremove && \
		rm -rf /var/lib/apt/lists/* && \
		update-alternatives --set libblas.so.3 /usr/lib/openblas-base/libblas.so.3 && \
		curl -O https://bootstrap.pypa.io/get-pip.py && \
		python get-pip.py && \
		rm get-pip.py && \
		pip --no-cache-dir install --upgrade ipython && \
		pip --no-cache-dir install \
		ipython \
		pyopenssl \
		ndg-httpsclient \
		pyasn1 \
		Cython \
		ipykernel \
		jupyter \
		path.py \
		futures \
		tqdm \
		flask \
		instagram-scraper \
		clarifai \
		Pillow \
		pygments \
		six \
		sphinx \
		wheel \
		zmq


# Install TensorFlow, Theano, Keras, Caffe
RUN python -m ipykernel.kernelspec && \
	pip --no-cache-dir install \
	https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.1.0-cp27-none-linux_x86_64.whl && \
	pip --no-cache-dir install git+git://github.com/Theano/Theano.git@rel-0.9.0 && \
	echo "[global]\ndevice=cpu\nfloatX=float32\nmode=FAST_RUN \
		\n[lib]\ncnmem=0.95 \
		\n[nvcc]\nfastmath=True \
		\n[blas]\nldflag = -L/usr/lib/openblas-base -lopenblas \
		\n[DebugMode]\ncheck_finite=1" \
	> /root/.theanorc && \
	pip --no-cache-dir install git+git://github.com/fchollet/keras.git@2.0.4 && \
	git clone -b master --depth 1 https://github.com/BVLC/caffe.git /root/caffe && \
	cd /root/caffe && \
	cat python/requirements.txt | xargs -n1 pip install && \
	mkdir build && cd build && \
	cmake -DCPU_ONLY=ON -DBLAS=Open .. && \
	make -j"$(nproc)" all && \
	make install && \
	echo "/root/caffe/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig && \
	git clone --depth 1 https://github.com/opencv/opencv.git /root/opencv && \
	cd /root/opencv && \
	mkdir build && \
	cd build && \
	cmake -DWITH_QT=ON -DWITH_OPENGL=ON -DFORCE_VTK=ON -DWITH_TBB=ON -DWITH_GDAL=ON -DWITH_XINE=ON -DBUILD_EXAMPLES=ON .. && \
	make -j"$(nproc)"  && \
	make install && \
	ldconfig && \
	echo 'ln /dev/null /dev/raw1394' >> ~/.bashrc

# Set up Caffe environment variables
ENV CAFFE_ROOT=/root/caffe
ENV PYCAFFE_ROOT=$CAFFE_ROOT/python
ENV PYTHONPATH=$PYCAFFE_ROOT:$PYTHONPATH \
	PATH=$CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH

# Set up notebook config
COPY jupyter_notebook_config.py /root/.jupyter/

# Jupyter has issues with being run directly: https://github.com/ipython/ipython/issues/7062
COPY run_jupyter.sh /root/

# Expose Ports for TensorBoard (6006), Ipython (8888), Flask (5000)
EXPOSE 6006 8888 5000

WORKDIR "/root"
CMD ["/bin/bash"]
