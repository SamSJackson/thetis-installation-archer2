# Installing Thetis on Archer2

The following are instructions that were valid as of 19/02/26. Please contact me on Slack if things are no longer working. 

The general workflow is:

1. Login to Archer2 and copy the zipped file from local PC.

2. Edit and move relevant files to the work directory (firedrake-configure, constraints.txt, both slurm files)

3. Run `sh petsc_install.sh` 

4. In the work directory, run `sbatch petsc_check.slurm` and ensure it passes (ignoring errors due to busy nodes)

5. Run `sh firedrake_install.sh` 

6. In the work directory, run `sbatch firedrake_check.slurm` and ensure it passes the `firedrake-check`

7. Activate the Firedrake python environment and install Thetis with pip.

## Archer2 Access

*If you already have access to Archer2, you can ignore this step.*

Gaining access to Archer2 may be the longest step but there is an allocation for Edinburgh researchers. 

The documentation and method of requesting access is here: [Archer2 - Getting Access](https://www.archer2.ac.uk/support-access/access.html)

## Login to Archer2

SSH into Archer2 with the account you have been provided. Follow instructions here: [Archer2 - Docs](https://docs.archer2.ac.uk/user-guide/connecting-totp/).
The account that you get will be assigned a particular `project` and `username`, relevant for later.

For me, after setting up SSH keys, this is:
`ssh sjackson@login.archer2.ac.uk`

## Moving Files

In a separate terminal, you will copy over the downloaded zip file using `scp` (Secure Copy). 

`scp thetis_installation.zip <username>@login.archer2.ac.uk:/home/<project>/<project>/<username>`

**Important:** Some of these files have variables that must be changed to adapt for your system.

Unzip this file and you have to move certain files to your work directory:
```
export WORK_DIR=/work/<project>/<project>/<username>
mv thetis_installation/constraints.txt $WORK_DIR
mv thetis_installation/firedrake-configure-2025.10.2 $WORK_DIR
mv thetis_installation/firedrake_check.slurm $WORK_DIR
mv thetis_installation/petsc_check.slurm $WORK_DIR
mv thetis_installation/thetis_example.slurm $WORK_DIR
```

## PETSc Install

Edit the `petsc_install.sh` file and change the variable `BUILD_DIR` to include your project and username.

Then, run the file `sh petsc_install.sh`.

### PETSc Check

Confirm that PETSc has installed correctly with the `petsc_check.slurm` script.

Edit the `petsc_check.slurm` script from the work directory, ensuring that the lines starting with the following variables are updated:
```
#SBATCH --account=<project>
BUILD_DIR=
```
Note that `<project>` in the SBATCH case is **different** from the norm and refers to your custom budget code, as found in SAFE (refer to docs: [Archer2 - Budget Code](https://docs.archer2.ac.uk/faq/#checking-budgets))

Then, run the script with `sbatch petsc_check.slurm`.

## Firedrake Install

This is following instructions from [Firedrake - Install](https://www.firedrakeproject.org/install.html#install-firedrake), including a current setuptools issue fix, with our constraints.txt file.

Edit the `firedrake_install.sh` file and change the variable `BUILD_DIR` to include your project and username.

Then, run the file `sh firedrake_install.sh`.

### Firedrake Check

Once again, verify that Firedrake has installed correctly with the `firedrake_check.slurm` script. 

Edit the `firedrake_check.slurm` script from the work directory, ensuring that the lines starting with the following variables are updated:
```
#SBATCH --account=<project>
BUILD_DIR=
```
Note that `<project>` in the SBATCH case is **different** from the norm and refers to your custom budget code, as found in SAFE (refer to docs: [Archer2 - Budget Code](https://docs.archer2.ac.uk/faq/#checking-budgets))

Then, run the script with `sbatch firedrake_check.slurm`.

## Thetis Install 

To install Thetis, you must activate the generated Firedrake python environment and then you can install Thetis as normal as per website: [Thetis - Installation](https://thetisproject.org/download.html#installing-thetis) (but make sure this is completed in the work directory).

I would suggest installing the editable version as it comes with the examples:
```
cd $WORK_DIR
git clone https://github.com/thetisproject/thetis
cd thetis
git checkout v2025.10.1
pip install -e .
```

### Thetis Example

Using the supplied `thetis_example.slurm` script, you can submit jobs. It must be edited for the desired Thetis simulation that you wish to run and be placed within the right directory. 

