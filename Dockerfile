FROM centos:centos7.4.1708

RUN yum install -y epel-release
RUN yum -y install wget vim which curl tar gzip
RUN yum -y groupinstall "Development tools"
RUN yum -y install binutils
RUN yum -y install dapl dapl-utils ibacm infiniband-diags libibverbs libibverbs-devel libibverbs-utils libmlx4 librdmacm librdmacm-utils mstflint opensm-libs perftest qperf rdma

RUN yum -y install scl-utils
RUN yum -y install centos-release-scl
RUN yum -y install devtoolset-7-toolchain

#### LOAD GNU 7.3.1  General environment variables ###

ENV PATH=/opt/rh/devtoolset-7/root/usr/bin${PATH:+:${PATH}}
ENV MANPATH=/opt/rh/devtoolset-7/root/usr/share/man:${MANPATH}
ENV INFOPATH=/opt/rh/devtoolset-7/root/usr/share/info${INFOPATH:+:${INFOPATH}}
ENV PCP_DIR=/opt/rh/devtoolset-7/root
# Some perl Ext::MakeMaker versions install things under /usr/lib/perl5
# even though the system otherwise would go to /usr/lib64/perl5.
ENV PERL5LIB=/opt/rh/devtoolset-7/root//usr/lib64/perl5/vendor_perl:/opt/rh/devtoolset-7/root/usr/lib/perl5:/opt/rh/devtoolset-7/root//usr/share/perl5/vendor_perl${PERL5LIB:+:${PERL5LIB}}
ENV LD_LIBRARY_PATH=/opt/rh/devtoolset-7/root$rpmlibdir$rpmlibdir32${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
ENV LD_LIBRARY_PATH=/opt/rh/devtoolset-7/root$rpmlibdir$rpmlibdir32:/opt/rh/devtoolset-7/root$rpmlibdir/dyninst$rpmlibdir32/dyninst${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
# duplicate python site.py logic for sitepackages
ENV pythonvers=3.6
ENV PYTHONPATH=/opt/rh/devtoolset-7/root/usr/lib64/python$pythonvers/site-packages:/opt/rh/devtoolset-7/root/usr/lib/python$pythonvers/site-packages${PYTHONPATH:+:${PYTHONPATH}}

############# OpenMPI 2.1.1 installation #############
RUN mkdir /tmpdir && cd /tmpdir
RUN wget https://download.open-mpi.org/release/open-mpi/v2.1/openmpi-2.1.1.tar.gz
RUN tar -xvf openmpi-2.1.1.tar.gz
RUN rm openmpi-2.1.1.tar.gz
RUN cd openmpi-2.1.1
CMD ["./configure --prefix=/usr/local/openmpi --disable-getpwuid --enable-orterun-prefix-by-default"]
RUN make
RUN make install
ENV PATH=/usr/local/openmpi/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/openmpi/lib:${LD_LIBRARY_PATH}
################################################

RUN gcc --version

COPY hello_world_openMP.c /home/

RUN cd /home && gcc -o hello_world_openMP.bin -fopenmp hello_world_openMP.c
ENV OMP_NUM_THREADS=4
CMD ./home/hello_world_openMP.bin

