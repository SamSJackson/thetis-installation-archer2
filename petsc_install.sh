#!/usr/bin/env bash
## Script to build PETSc for Firedrake on Archer2

set -e

# setup:
#  environment variables
#  firedrake configure script
#  environment modules
BUILD_DIR=/work/<project>/<project>/<user>/

export PETSC_DIR=${BUILD_DIR}/petsc
export PETSC_ARCH=arch-fd-default
FIREDRAKE_CONFIGURE=${BUILD_DIR}/firedrake-configure-2025.10.2

if [ ! -f $FIREDRAKE_CONFIGURE ] ; then
  echo "Firedrake configuration file not found"
  echo "Cancelling run..."
  exit 1;
fi

cd ${BUILD_DIR}

# Set up the build environment with system modules

module load PrgEnv-gnu/8.4.0
module load cray-python/3.10.10
module load cmake/3.29.4
module load cray-fftw/3.3.10.5
module load cray-hdf5-parallel/1.12.2.7
module load cray-libsci/23.09.1.1
module load cray-parallel-netcdf/1.12.3.7
module load hypre/2.33.0
module load metis/5.1.0
module load mumps/5.8.1
module load parmetis/4.0.3
module load scotch/7.0.10
module load superlu/7.0.1
module load superlu-dist/9.1.0
module list

# Clone PETSc if it does not already exist 
if [ ! -d petsc ] ; then
   git clone https://gitlab.com/petsc/petsc.git
fi

# Checkout firedrake-configure branch
cd petsc
git checkout $(python3 ${FIREDRAKE_CONFIGURE} --no-package-manager --show-petsc-version)

# Configure PETSc, using the default Firedrake configuration
# as a guide but picking up all externals from system modules
# (dropping suitsparse as unavailable)

OPTFLAGS='-O3 -march=native -mtune=native -fPIC'

./configure --PETSC_ARCH=${PETSC_ARCH} \
            --COPTFLAGS="${OPTFLAGS}" \
            --CXXOPTFLAGS="${OPTFLAGS}" \
            --FOPTFLAGS="${OPTFLAGS}" \
            --with-blaslapack=1 \
            --with-c2html=0 \
            --with-debugging=0 \
            --with-fortran-bindings=0 \
            --with-shared-libraries=1 \
            --with-strict-petscerrorcode \
            --with-fftw=1 \
            --with-fftw-include=${FFTW_INC} \
            --with-fftw-lib="-L${FFTW_DIR}" \
            --with-hdf5=1 \
            --with-hdf5-include=${HDF5_DIR}/include \
            --with-hdf5-lib="-L${HDF5_DIR}/include" \
            --with-hypre=1 \
            --with-hypre-include=${HYPRE_DIR}/include \
            --with-hypre-lib="-L${HYPRE_DIR}/lib"  \
            --with-make-np=8 \
            --with-make-test-np=8 \
            --with-make-load=8 \
            --with-metis=1 \
            --with-metis-include=${METIS_DIR}/include \
            --with-metis-lib="-L${METIS_DIR}/lib" \
            --with-mpiexec=srun \
            --with-mumps=1 \
            --with-mumps-include=${MUMPS_DIR}/include \
            --with-mumps-lib="-L${MUMPS_DIR}/lib -lcmumps_gnu_mpi -ldmumps_gnu_mpi -lmumps_common_gnu_mpi -lpord_gnu_mpi -lsmumps_gnu_mpi -lzmumps_gnu_mpi -lesmumps_gnu -lptesmumps_gnu_mpi" \
            --with-parmetis=1 \
            --with-parmetis-include=${PARMETIS_DIR}/include \
            --with-parmetis-lib="-L${PARMETIS_DIR}/lib" \
            --with-pnetcdf=1 \
            --with-pnetcdf-include=${PNETCDF_DIR}/include \
            --with-pnetcdf-lib="-L${PNETCDF_DIR}/lib" \
            --with-ptscotch=1 \
            --with-ptscotch-include=${SCOTCH_DIR}/include \
            --with-ptscotch-lib="-L${SCOTCH_DIR}/lib -lptscotcherr_gnu_mpi -lptscotch_gnu_mpi -lscotcherr_gnu -lscotch_gnu" \
            --with-scalapack=1 \
            --with-superlu=1 \
            --with-superlu-include=${SUPERLU_DIR}/include \
            --with-superlu-lib="-L${SUPERLU_DIR}/lib"  \
            --with-superlu_dist=1 \
            --with-superlu_dist-include=${SUPERLU_DIST_DIR}/include \
            --with-superlu_dist-lib="-L${SUPERLU_DIST_DIR}/lib" 

# Build PETSc
make all
