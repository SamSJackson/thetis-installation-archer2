#!/usr/bin/env bash

set -e

# setup:
#  environment modules
#  environment variables
#  firedrake configure script
BUILD_DIR=/work/<project>/<project>/<user>

FDVERSION=2025.10.2
FDVENV=fd-default

export PETSC_DIR=${BUILD_DIR}/petsc
export PETSC_ARCH=arch-${FDVENV}
PETSC4PY_DIR=${PETSC_DIR}/src/binding/petsc4py

FIREDRAKE_CONFIGURE=${BUILD_DIR}/firedrake-configure-${FDVERSION}
export PIP_CONSTRAINT=${BUILD_DIR}/constraints.txt

if [ ! -f $FIREDRAKE_CONFIGURE ] ; then
  echo "Firedrake configuration file not found"
  echo "Cancelling run..."
  exit 1;
fi

if [ ! -f $PIP_CONSTRAINT ] ; then
  echo "Temporary constraints.txt to solve PETSc4py issue not found"
  echo "Cancelling run..."
  exit 1;
fi

module load PrgEnv-gnu/8.4.0
module load cray-python/3.10.10
module load cray-hdf5-parallel/1.12.2.7
module load cmake/3.29.4
module load cray-libsci/23.09.1.1
module list

# # Change to the build directory
cd ${BUILD_DIR}

# # Create the firedrake venv
# We want to use system packages like mpi4py and numpy so that they
# are linked to the vendor libraries (e.g. MPI and BLAS/LAPACK)
python3 -m venv --system-site-packages ${FDVENV}

# # Activate the firedrake venv
. ${FDVENV}/bin/activate

# # Clean up pip environment
echo -e "\nClean up pip cache\n"
pip cache purge

# Need to add the petsc and mpich paths manually
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${PETSC_DIR}/${PETSC_ARCH}/lib/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${CRAY_MPICH_DIR}/lib-abi-mpich

export CC=mpicc CXX=mpicxx

# Clone Firedrake
echo -e "\nClone Firedrake\n"
cd ${VIRTUAL_ENV}
git clone --depth 1 --branch ${FDVERSION} \
    https://github.com/firedrakeproject/firedrake.git \
    ${VIRTUAL_ENV}/src/firedrake

# make sure we build a parallel h5py
export HDF5_MPI=ON

# build a recent enough mpi4py version
pip install --verbose --no-binary mpi4py mpi4py==4.1.1

# Fortran flags for libsupermesh
export FFLAGS='-O3 -march=native -mtune=native -fPIC -fallow-argument-mismatch'

echo -e "\nInstall Firedrake\n"
echo -e "Output will be written to build-firedrake.log\n"
unbuffer pip install --verbose \
    --no-binary h5py \
    --editable \
    "${VIRTUAL_ENV}/src/firedrake[check]" \
    | tee build-firedrake.log
